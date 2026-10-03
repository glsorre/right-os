zsh-setup:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo chmod -s $(which zsh) $USER
    echo "ZSH is now the default shell for $USER"

antidote-setup:
    #!/usr/bin/env bash
    set -euxo pipefail
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
    echo "Antidote is now installed"

dotfiles-setup:
    #!/usr/bin/env bash
    set -euxo pipefail
    git clone --depth=1 https://github.com/glsorre/dotfiles.git ${ZDOTDIR:-$HOME}/.dotfiles
    ln -s ${ZDOTDIR:-$HOME}/.dotfiles/zshrc ${ZDOTDIR:-$HOME}/.zshrc
    ln -s ${ZDOTDIR:-$HOME}/.dotfiles/gitignore ${ZDOTDIR:-$HOME}/.gitignore
    ln -s ${ZDOTDIR:-$HOME}/.dotfiles/gitconfig ${ZDOTDIR:-$HOME}/.gitconfig
    ln -s ${ZDOTDIR:-$HOME}/.dotfiles/gitignore-global ${ZDOTDIR:-$HOME}/.gitignore-global
    echo "Dotfiles are now installed"

shell-setup:
    zsh-setup
    antidote-setup
    dotfiles-setup
