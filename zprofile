if [ -d /opt/homebrew ] ; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="/usr/local/cargo/bin:/usr/local/go/bin:$PATH"
