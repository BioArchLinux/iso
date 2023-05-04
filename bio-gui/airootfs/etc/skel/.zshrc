# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Created by newuser for 5.8
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

# alias
alias fetch="fastfetch -l /etc/fastfetch/bioarchlinux-color.logo"
alias fastfetch="fastfetch -l /etc/fastfetch/bioarchlinux.logo"

# autologin
[ "$(tty)" = "/dev/tty1" ] && \
bash ~/.config/tilix/load.sh && \
gsettings set org.gnome.desktop.interface icon-theme 'Tela' &&\
exec wayfire  

# tilix
if [[ $TILIX_ID ]]; then
        source /etc/profile.d/vte.sh
	fetch
fi
