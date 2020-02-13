{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableFzfHistory = true;
    #enableFzfCompletion = true;

    #autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    interactiveShellInit = ''
      ZSH_THEME="candy"
      ENABLE_CORRECTION="true"

      # Search history with Ctrl-P/N
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey '^P' up-line-or-beginning-search
      bindkey '^N' down-line-or-beginning-search

      # Edit command line
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^\' edit-command-line

      # Command line navigation
      bindkey '^J' backward-word
      bindkey '^K' forward-word

      # Use the vi navigation keys besides cursor keys in menu completion
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      bindkey -M menuselect 'h' vi-backward-char        # left
      bindkey -M menuselect 'k' vi-up-line-or-history   # up
      bindkey -M menuselect 'l' vi-forward-char         # right
      bindkey -M menuselect 'j' vi-down-line-or-history # bottom
    '';

    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
    };
  };
}
