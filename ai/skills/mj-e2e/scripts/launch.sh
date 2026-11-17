#!/usr/bin/env bash
# Start `/mj-e2e execute <manifest>` in a new Claude Code session with Remote Control, in a window of
# the tmux session "e2e", so the run can be watched from the Claude app or with `tmux attach -t e2e`.
#
#   launch.sh e2e/<feature>/manifest.yaml [rerun]
#
# Run it from the app's repo. The session works in auto permission mode and ends when it's done.
set -euo pipefail

manifest=${1:?usage: launch.sh MANIFEST [rerun]}
mode=${2:-execute}
[[ -f $manifest ]] || { echo "no such manifest: $manifest" >&2; exit 1; }
repo=$(git rev-parse --show-toplevel)
feature=$(basename "$(dirname "$manifest")")
app=$(sed -n 's/^app:[[:space:]]*\([a-z0-9-]*\).*/\1/p' "$manifest" | head -1)
name="e2e ${app:-app} ${feature}"
window="${feature:0:30}"

prompt="/mj-e2e execute ${manifest}"
[[ $mode == rerun ]] && prompt="${prompt} (rerun: reuse walkthrough.mjs as it is)"

claude_bin=$(command -v claude || echo "$HOME/.local/bin/claude")
cmd=$(printf '%q --remote-control %q --permission-mode auto %q' "$claude_bin" "$name" "$prompt")

if tmux has-session -t e2e 2>/dev/null; then
  tmux new-window -d -t e2e: -n "$window" -c "$repo" "$cmd"
else
  tmux new-session -d -s e2e -n "$window" -c "$repo" "$cmd"
fi
echo "Started \"$name\" in tmux window e2e:$window (watch: tmux attach -t e2e)"
