#!/bin/bash
set -e
[[ $OSTYPE = darwin* ]] && IS_MAC=true

SCRIPT_DIR=$( pwd -P )
VIMPLUGINDIR=~/.vim/bundle
DEVELOPMENT=~/Development
mkdir -p "$VIMPLUGINDIR"

for d in swap backup undo; do                # make vim dirs
  [[ -d ~/.vim/$d ]] || mkdir -p ~/.vim/"$d"
done
[[ -d $VIMPLUGINDIR/Vundle.vim ]] ||
 git clone https://github.com/gmarik/Vundle.vim.git "$VIMPLUGINDIR"/Vundle.vim

if [[ -d $VIMPLUGINDIR/ultisnips/ftdetect && ! -d ~/.vim/ftdetect ]]; then
  mkdir ~/.vim/ftdetect
  ln -s ~/.vim/bundle/ultisnips/ftdetect/* ~/.vim/ftdetect/
fi

has_brew() {
  command -v brew >/dev/null
}

link_config_file() {
  local file=$1
  local destination=${2-$file}
  if [[ ! -L ~/.$destination && ! -f ~/.$destination.keep ]]; then
    if [[ -f ~/.$destination ]]; then
      echo "creating backup of existing file to .$destination.bak"
      mv ~/".$destination" ~/".$destination.bak"
    fi
    echo "ln -s $SCRIPT_DIR/$file ~/.$destination"
    ln -s "$SCRIPT_DIR/$file" ~/".$destination"
  fi
}

FILES=(
  vimrc
  nvimrc
  bashrc
  gemrc
  gitconfig
  gitignore
  tmux.conf
  bash_profile
  tigrc
  my.cnf
  pryrc
  editrc
  inputrc
  rspec
  jshintrc
  smb_mount.sh
)
for i in "${FILES[@]}"
do
    link_config_file "$i"
done

# installing irssi customizations
test -d ~/.irssi || mkdir ~/.irssi
link_config_file "irssirc" "irssi/config"
link_config_file "sshconfig" "ssh/config"

if [[ -f ~/.gitignore_global && ! -L ~/.gitignore_global ]]
then
  if ! [[ -f ~/.gitignore ]]; then
    mv ~/.gitignore_global ~/.gitignore
  else
    mv ~/.gitignore_global ~/.gitignore_global.bak
  fi
fi

[[ -L ~/.gitignore_global ]] ||
  ln -s "$(readlink -f ~/.gitignore)" ~/.gitignore_global
if [[ -f ~/.gitignore_global.bak ]]; then
  echo "move gitignore_globals and delete bak."
  diff -u ~/.gitignore_global ~/.gitignore_global.bak
fi
if [[ -f ~/.gitignore.bak ]]; then
  echo "move gitignores and delete bak."
  diff -u ~/.gitignore ~/.gitignore.bak
fi

# installing coreutils to get the latest gnu tools, lscolors, etc.
if [[ ! -d /usr/local/opt/coreutils ]] && has_brew; then
  brew install coreutils
fi

# install tmux themes
if command -v tmux >/dev/null; then
	[[ -d $DEVELOPMENT/tmux-colors-solarized ]] ||
  git clone https://github.com/seebi/tmux-colors-solarized.git $DEVELOPMENT/tmux-colors-solarized
fi 

# install dircolors themes
[[ -d $DEVELOPMENT/dircolors-solarized ]] ||
  git clone https://github.com/seebi/dircolors-solarized.git "$DEVELOPMENT/dircolors-solarized"
[[ -f ~/.dir_colors_dark ]] ||
  ln -s "$DEVELOPMENT/dircolors-solarized/dircolors.ansi-dark" ~/.dir_colors_dark
[[ -f ~/.dir_colors_light ]] ||
  ln -s "$DEVELOPMENT/dircolors-solarized/dircolors.ansi-light" ~/.dir_colors_light

#Install dupes
if has_brew; then
	test -d /usr/local/Library/Taps/homebrew-dupes || brew tap homebrew/dupes
fi

#brew utils
install_package() {
  package=$1
  echo "checking for package $i"
  if has_brew; then
  	[[ -d /usr/local/Cellar/$package ]] || brew install "$package"
  fi
  if  IFS== read -r _ lsb _ </etc/lsb-release &&
      [[ $lsb = Ubuntu ]]; then
    apt-get install $package
  fi
  if ][ -f /etc/redhat-release ]]; then
  	yum install $package
  fi
}

PACKAGES=(
  tree
  the_silver_searcher
  tig
  pstree
  tmux
  wget
  grep
  pv
  reattach-to-user-namespace
  iojs
  bash-completion
  jq
)
for i in ${PACKAGES[*]}; do
  install_package $i
done;

# install neovim
if has_brew; then
  brew tap neovim/homebrew-neovim
  brew install --HEAD neovim
fi

node_packages=(
  jscs
  jshint
  js-yaml
)
for i in "${node_packages[@]}"; do
  npm install -g $i
done;

if ][ ! -d $DEVELOPMENT/base-16/shell ]]; then
  git clone https://github.com/chriskempson/base16-shell.git "$DEVELOPMENT/base-16/shell"
fi

# link in jsc
if [[ $IS_MAC = true ]]; then
	if [[ -x /System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc &&
      ! -L /usr/local/bin/jsc ]]; then
	 ln -s /System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/Resources/jsc /usr/local/bin/jsc
	fi

	# link vmware's ovftool
	if [[ ! -L /usr/local/bin/ovftool ]]; then
	  ln -s '/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool' /usr/local/bin
	fi
fi
