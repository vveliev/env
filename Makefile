init-osx:
	sh bin/install-brew.sh
	brew bundle --file workspace/osx/Brewfile

install:
	brew bundle --file workspace/osx/Brewfile

osx-sync:
	brew bundle dump --file workspace/osx/Brewfile

osx-update:
	brew update && brew upgrade && brew cleanup

link-dots:
	ln -s -f $(shell pwd)/.zshrc ~/.zshrc
	ln -s -f $(shell pwd)/.gitignore ~/.gitignore
	ln -s -f $(shell pwd)/.gitconfig ~/.gitconfig
	ln -s -f $(shell pwd)/.gitexcludes ~/.gitexcludes
	ln -s -f $(shell pwd)/.npmrc ~/.npmrc


move-dots:
	ln -s -f $(shell pwd)/.zshrc ~/.zshrc
	ln -s -f $(shell pwd)/.gitignore ~/.gitignore
	ln -s -f $(shell pwd)/.gitconfig ~/.gitconfig	
	ln -s -f $(shell pwd)/.gitexcludes ~/.gitexcludes
	ln -s -f $(shell pwd)/.npmrc ~/.npmrc