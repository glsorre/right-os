zsh-setup:
    #!/usr/bin/env bash
    set -euxo pipefail
    sudo chmod -s $(which zsh) $USER
    echo "ZSH is now the default shell for $USER"

antidote-setup:
    #!/usr/bin/env bash
    set -euxo pipefail
    git clone --depth=1 https://github.com/mattmc3/antidote.git $HOME/.antidote
    echo "Antidote is now installed"

dotfiles-setup:
    #!/usr/bin/env bash
    set -euxo pipefail
    git clone --depth=1 https://github.com/glsorre/dotfiles.git $HOME/.dotfiles
    ln -s $HOME/.dotfiles/zshrc $HOME/.zshrc
    ln -s $HOME/.dotfiles/gitconfig $HOME/.gitconfig
    ln -s $HOME/.dotfiles/gitignore-global $HOME/.gitignore-global
    echo "Dotfiles are now installed"

shell-setup:
    just zsh-setup
    just antidote-setup
    just dotfiles-setup
