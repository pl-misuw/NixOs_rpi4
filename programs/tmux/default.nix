{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;

    extraConfig = ''
      # Status bar
      set -g status-justify centre
      set -g status-bg black

      # Left status bar
      set -g status-left "#[bg=brightgreen] #H #[default]#[bg=brightblack] #[fg=white]#(cut -d ' ' -f 1-3 /proc/loadavg) #[default]"
      set -g status-left-length 30

      # Right status bar
      set -g status-right-length 20
      set -g status-right "#[bg=brightblack] #[fg=white]%H:%M #[bg=brightwhite] #[fg=black]%a %m-%d #[default]"

      # Center status bar
      setw -g window-status-format "#[fg=white] #I #W #[default]"
      setw -g window-status-current-format "#[default]#[bg=brightblack]#[fg=white,bold] #I #W #[default]"

      # Reduce <Esc> escaping time
      set -s escape-time 100

      # Dynamic window renaming
      set  -g set-titles on
      set  -g set-titles-string '#S:#I.#P #W'
      setw -g automatic-rename on

      # History
      set -g history-limit 1000

      # Start window numbering at 1
      set -g base-index 1

      # Set the prefix to Ctrl-A.
      set -g prefix ^A
      unbind ^A
      unbind ^B

      # Command sequence for nested tmux sessions
      bind a send-prefix

      # Go to last active window
      bind ^A last-window

      # Rename current title
      bind A command-prompt "Rename-window %%"

      # Create a new window
      unbind c
      bind   c new-window

      # Detach from current server
      unbind ^D
      bind   ^D detach
      unbind d
      bind   d detach

      # List all attached clients
      unbind *
      bind   * list-clients

      # Move among windows
      unbind n
      bind   n next-window
      unbind p
      bind   p previous-window

      # Kill current window (useful in terminating zombie processes)
      unbind k
      bind   k confirm-before "kill-window"

      # Kill current session
      unbind i
      bind   i confirm-before "kill-session"

      # List windows (useful when have more than 10 windows)
      unbind b
      bind   b list-windows

      # Split window horizontally
      bind | split-window -h
    '';
  };
}
