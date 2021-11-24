# I'm using this theme on wsl to make both vim and terminal light so the 
# cursor colour works across both.
# Recommend setting a solarized theme for the terminal for this to work
# copy this to ~/.oh-my-zsh/themes/robbyrussell-light.zsh-theme
# update the theme in .zshrc to "robbyrussel-light.zsh-theme


PROMPT="%(?:%{$fg_bold[green]%}Γ₧£ :%{$fg_bold[red]%}Γ₧£ )"
PROMPT='${ret_status} %{$fg[black]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[red]%}Γ£ù"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

