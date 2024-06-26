#/bin/bash

DOTFILEDIR=$(realpath $(dirname $0))

for FILE in `ls $DOTFILEDIR` ; do 
  echo $FILE
  rm -f ~/.$FILE
  ln -s $DOTFILEDIR/$FILE ~/.$FILE
done
