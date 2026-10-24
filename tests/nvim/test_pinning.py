"""Run with: python3 -m unittest discover -s tests/nvim -v"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class PinningTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config = self.root / "config"
        self.config.mkdir()
        self.data = self.root / "data"
        self.repo = self.root / "upstream"
        self.repo.mkdir()
        self.git("init", "-q", "--initial-branch=main")
        module = self.repo / "lua/lazy/init.lua"
        module.parent.mkdir(parents=True)
        module.write_text('return { setup = function() _G.loaded_revision = "locked" end }\n')
        self.git("add", ".")
        self.git("commit", "-qm", "Locked version")
        self.commit = self.git("rev-parse", "HEAD")
        module.write_text('error("Unpinned code executed")\n')
        self.git("commit", "-qam", "New upstream version")
        self.write_lock({"lazy.nvim": {"commit": self.commit}})

    def git(self, *args):
        return subprocess.check_output(
            ["git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid", "-C", str(self.repo), *args],
            text=True,
            stderr=subprocess.PIPE,
        ).strip()

    def write_lock(self, value):
        (self.config / "lazy-lock.json").write_text(json.dumps(value))

    def lua(self, source):
        script = self.root / "test.lua"
        script.write_text(source)
        env = dict(os.environ, XDG_CONFIG_HOME=str(self.root / "xdg-config"), XDG_DATA_HOME=str(self.root / "xdg-data"), XDG_STATE_HOME=str(self.root / "xdg-state"), XDG_CACHE_HOME=str(self.root / "xdg-cache"))
        result = subprocess.run(
            ["nvim", "--headless", "-u", "NONE", "-i", "NONE", "-l", str(script)],
            capture_output=True,
            text=True,
            timeout=20,
            env=env,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def bootstrap(self, assertions, upstream=None):
        self.lua(f"""
local original_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind)
  if kind == "config" then return {json.dumps(str(self.config))} end
  if kind == "data" then return {json.dumps(str(self.data))} end
  return original_stdpath(kind)
end
local system = vim.fn.system
local calls = {{}}
vim.fn.system = function(args)
  calls[#calls + 1] = vim.deepcopy(args)
  if args[2] == "clone" then
    assert(vim.list_contains(args, "--no-checkout"))
    for i, arg in ipairs(args) do
      if arg == "https://github.com/folke/lazy.nvim.git" then
        args[i] = {json.dumps(str(upstream or self.repo))}
      end
    end
  end
  return system(args)
end
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local ok, err = pcall(dofile, {json.dumps(str(ROOT / 'config/nvim/lua/config/lazy.lua'))})
{assertions}
""")

    def test_bootstrap_loads_lockfile_commit_instead_of_upstream_head(self):
        self.bootstrap(f"""
assert(ok, err)
assert(_G.loaded_revision == "locked")
assert(#calls == 2)
assert(vim.trim(system({{ "git", "-C", lazypath, "rev-parse", "HEAD" }})) == {json.dumps(self.commit)})
""")

    def test_existing_install_does_not_fetch_or_change_revision(self):
        target = self.data / "lazy/lazy.nvim/lua/lazy"
        target.mkdir(parents=True)
        (target / "init.lua").write_text('return { setup = function() _G.loaded_revision = "existing" end }')
        (self.config / "lazy-lock.json").unlink()
        self.bootstrap('assert(ok, err); assert(#calls == 0); assert(_G.loaded_revision == "existing")')

    def test_missing_lockfile_fails_before_downloading_or_loading_code(self):
        (self.config / "lazy-lock.json").unlink()
        self.bootstrap('assert(not ok); assert(#calls == 0); assert(_G.loaded_revision == nil)')

    def test_invalid_lockfile_fails_before_downloading_or_loading_code(self):
        for lock in ({}, {"lazy.nvim": {"commit": "stable"}}, {"lazy.nvim": {"commit": "g" * 40}}):
            with self.subTest(lock=lock):
                self.write_lock(lock)
                self.bootstrap('assert(not ok); assert(#calls == 0); assert(_G.loaded_revision == nil)')

    def test_malformed_json_fails_before_downloading(self):
        (self.config / "lazy-lock.json").write_text("{")
        self.bootstrap('assert(not ok); assert(#calls == 0)')

    def test_checkout_failure_removes_partial_install_and_can_retry(self):
        self.write_lock({"lazy.nvim": {"commit": "0" * 40}})
        self.bootstrap('assert(not ok); assert(#calls == 2); assert(not vim.uv.fs_stat(lazypath)); assert(_G.loaded_revision == nil)')
        self.write_lock({"lazy.nvim": {"commit": self.commit}})
        self.bootstrap('assert(ok, err); assert(_G.loaded_revision == "locked")')

    def test_clone_failure_does_not_load_code(self):
        self.bootstrap(
            'assert(not ok); assert(#calls == 1); assert(not vim.uv.fs_stat(lazypath)); assert(_G.loaded_revision == nil)',
            upstream=self.root / "missing-upstream",
        )

    def test_mason_pins_cover_all_tools_and_preserve_language_conditions(self):
        self.lua(f"""
local base = {{ "bash-language-server", "black", "codelldb", "debugpy", "eslint_d", "isort", "json-lsp", "lua-language-server", "marksman", "prettier", "pyright", "ruff", "shellcheck", "shfmt", "stylua", "taplo", "typescript-language-server", "yaml-language-server" }}
for _, go in ipairs({{ false, true }}) do
  for _, rust in ipairs({{ false, true }}) do
    vim.fn.executable = function(name)
      return ((name == "go" and go) or (name == "rustc" and rust)) and 1 or 0
    end
    local specs = dofile({json.dumps(str(ROOT / 'config/nvim/lua/plugins/lsp.lua'))})
    local opts = specs[3].opts()
    assert(opts.auto_update == false)
    assert(opts.run_on_start == false)
    assert(specs[2].opts.automatic_installation == false)
    local expected = vim.deepcopy(base)
    if go then vim.list_extend(expected, {{ "delve", "goimports", "gofumpt", "golangci-lint", "gopls" }}) end
    if rust then expected[#expected + 1] = "rust-analyzer" end
    local seen = {{}}
    for _, tool in ipairs(opts.ensure_installed) do
      assert(type(tool) == "table", "Unpinned tool")
      assert(type(tool.version) == "string" and tool.version:match("^v?%d[%d%.%-]*$"), "Version must be exact")
      assert(not seen[tool[1]], "Duplicate tool")
      assert(vim.list_contains(expected, tool[1]), "Unexpected tool")
      seen[tool[1]] = true
    end
    assert(vim.tbl_count(seen) == #expected, "Missing tools")
  end
end
""")

    def test_lsp_setup_preserves_server_names_and_language_settings(self):
        self.lua(f"""
package.loaded["cmp_nvim_lsp"] = {{ default_capabilities = function() return {{}} end }}
for _, go in ipairs({{ false, true }}) do
  for _, rust in ipairs({{ false, true }}) do
    vim.fn.executable = function(name)
      return ((name == "go" and go) or (name == "rustc" and rust)) and 1 or 0
    end
    local configured = {{}}
    vim.lsp.config = function(name, opts)
      assert(type(name) == "string", "LSP server names must be strings")
      assert(vim.json.encode(opts))
      configured[name] = opts
    end
    vim.lsp.enable = function(servers)
      local expected = {{ "bashls", "jsonls", "lua_ls", "marksman", "pyright", "taplo", "ts_ls", "yamlls" }}
      if go then expected[#expected + 1] = "gopls" end
      if rust then expected[#expected + 1] = "rust_analyzer" end
      assert(vim.deep_equal(servers, expected))
    end
    dofile({json.dumps(str(ROOT / 'config/nvim/lua/plugins/lsp.lua'))})[4].config()
    assert((configured.gopls ~= nil) == go)
    assert((configured.rust_analyzer ~= nil) == rust)
    if rust then assert(configured.rust_analyzer.settings["rust-analyzer"].cargo.allFeatures) end
  end
end
""")


if __name__ == "__main__":
    unittest.main()
