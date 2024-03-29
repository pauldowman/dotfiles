#/bin/bash

DOTFILEDIR=$(realpath $(dirname $0))

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

for FILE in `ls $DOTFILEDIR` ; do 
  echo $FILE
  rm -f ~/.$FILE
  ln -s $DOTFILEDIR/$FILE ~/.$FILE
done
