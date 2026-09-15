#!/bin/bash

# Shared tmux window layout, matching the `leader t` layout (~/.tmux/session1).
# Sourced by the session launchers rather than run directly.
#
#   left column (40%):  vim (top) + lazygit (bottom)
#   right column (60%): main command (top) + spare shell (bottom)

# setup_window_layout <target-window> [top-right-command] [vim-pane-label]
#
# Focus is left on the top-left vim pane so the window is ready to edit when
# selected. An empty top-right command leaves that pane as a bare shell.
setup_window_layout() {
  local target="$1"
  local top_right_cmd="${2-claude}"
  local label="${3:-vim}"

  tmux send-keys -t "$target" "vim ." C-m
  tmux select-pane -t "$target" -T "📝 $label"

  tmux split-window -h -p 60 -t "$target" -c "#{pane_current_path}"
  tmux split-window -v -p 50 -t "$target" -c "#{pane_current_path}"
  tmux split-window -v -p 50 -t "${target}.{top-left}" -c "#{pane_current_path}"

  tmux send-keys -t "${target}.{bottom-left}" "lazygit" C-m
  tmux select-pane -t "${target}.{bottom-left}" -T "🌳 lazygit"

  if [ -n "$top_right_cmd" ]; then
    tmux send-keys -t "${target}.{top-right}" "$top_right_cmd" C-m
  fi
  tmux select-pane -t "${target}.{top-right}" -T "🚀 ${top_right_cmd:-commands}"

  tmux select-pane -t "${target}.{bottom-right}" -T "💻 terminal"
  tmux select-pane -t "${target}.{top-left}"
}
