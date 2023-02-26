# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
	zsh-history-substring-search
	)

source $ZSH/oh-my-zsh.sh
fpath=(~/.zsh/zsh-completions/src $fpath)

# User configuration

# Aliases ZSH
alias pf="paru && flatpak update && sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias mu="sudo reflector --verbose --latest 20 --sort rate --country Brazil,US,UK --save /etc/pacman.d/mirrorlist && sudo pacman -Syy"
alias intel="sudo intel_gpu_top"


# PATH
. /opt/asdf-vm/asdf.sh
export PATH=/home/santosbpm/.local/bin:$PATH

# start 

if [[ "$(tty)" == "/dev/tty1" ]]; then
	export DESKTOP_SESSION=i3
	pgrep i3 || startx
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [[ $DESKTOP_SESSION == "i3" ]]; then
	cp ~/.p10k-i3.zsh ~/.p10k.zsh
else
	cp ~/.p10k-tty.zsh ~/.p10k.zsh
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
