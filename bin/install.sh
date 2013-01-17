#! /bin/bash
# Install the "VIMISE" vim and vimperator distribution.

# Link the repository to $HOME, so you can put this repository anywhere.
if [ ! -d $HOME/vimise ]; then
    ln -sfn $PWD $HOME
fi
VIMISE_PATH="$HOME/vimise"
cd $VIMISE_PATH

echo "Starting installation..."
echo "Linking files..."
ln -sfn $VIMISE_PATH/vim $HOME/.vim
ln -sf $VIMISE_PATH/vimrc $HOME/.vimrc
ln -sf $VIMISE_PATH/gvimrc $HOME/.gvimrc
ln -sfn $VIMISE_PATH/vimperator $HOME/.vimperator
ln -sf $VIMISE_PATH/vimperatorrc $HOME/.vimperatorrc

# Cloning bundles.
bin/git.sh -C

echo "Finish installation."
