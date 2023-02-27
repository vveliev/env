init: 
	@$(MAKE) install-brew
	@$(MAKE) install
	@$(MAKE) move-dots

install-brew:
	sh bin/install-brew.sh

install:
	brew bundle --file workspace/osx/Brewfile

osx-sync:
	brew bundle dump --force --describe  --file workspace/osx/Brewfile

osx-update:
	brew update && brew upgrade && brew cleanup

move-dots:
	cp workspace/unix/.zshrc ~/.zshrc
	cp workspace/unix/.gitexcludes ~/.gitexcludes
	cp workspace/unix/.gitconfig ~/.gitconfig	
	cp workspace/unix/.gitexcludes ~/.gitexcludes
	cp workspace/unix/.npmrc ~/.npmrc