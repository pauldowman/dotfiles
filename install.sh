#/bin/bash

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

for FILE in `ls ~/dotfiles` ; do 
  ln -sf ~/dotfiles/$FILE ~/.$FILE
done
