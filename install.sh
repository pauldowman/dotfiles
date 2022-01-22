#/bin/bash

DOTFILEDIR=`dirname $0`

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install powerleve10k zsh theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

for FILE in `ls $DOTFILEDIR` ; do 
  echo $FILE
  rm ~/.$FILE
  ln -s $DOTFILEDIR/$FILE ~/.$FILE
done
