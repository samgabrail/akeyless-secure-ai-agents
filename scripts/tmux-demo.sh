#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# tmux-demo.sh - Launch the Akeyless Secure AI Agents demo session
#
# Creates a tmux session "akeyless-demo" with three panes:
#   Pane 0 (bottom, small) : kubectl port-forward for MySQL
#   Pane 1 (left,  main)   : "The Old Way" - insecure Claude Code demo
#   Pane 2 (right, main)   : "The Secretless Way" - Akeyless MCP demo
# ---------------------------------------------------------------------------

SESSION="akeyless-demo"

# Resolve project root relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Kill any existing session with the same name
tmux kill-session -t "${SESSION}" 2>/dev/null || true

# --- Create session ----------------------------------------------------------
# Start with the first pane (will become the left main pane).
tmux new-session -d -s "${SESSION}"

# Split a small horizontal pane at the bottom for port-forwarding (5 lines tall)
tmux split-window -t "${SESSION}" -v -l 5

# The bottom pane is now active (pane 1). Start port-forward there.
tmux send-keys -t "${SESSION}" \
  "kubectl port-forward svc/demo-mysql -n akeyless 3306:3306" Enter

# Go back to the top pane (pane 0) and split it vertically into two equal halves
tmux select-pane -t "${SESSION}.0"
tmux split-window -t "${SESSION}" -h -p 50

# ---------------------------------------------------------------------------
# At this point the layout is:
#   pane 0 = top-left   (the original pane)
#   pane 1 = top-right  (just created by the horizontal split)
#   pane 2 = bottom     (port-forward, small)
# ---------------------------------------------------------------------------

# --- Left main pane (pane 0): "The Old Way" ---------------------------------
tmux send-keys -t "${SESSION}.0" "cd ${PROJECT_DIR}" Enter
tmux send-keys -t "${SESSION}.0" "clear" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo ''" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo '========================================'" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo '       === THE OLD WAY ==='" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo '========================================'" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo ''" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo '  Run: claude'" Enter
tmux send-keys -t "${SESSION}.0" \
  "echo ''" Enter

# --- Right main pane (pane 1): "The Secretless Way" -------------------------
tmux send-keys -t "${SESSION}.1" "cd ${PROJECT_DIR}" Enter
tmux send-keys -t "${SESSION}.1" "clear" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo ''" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo '========================================'" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo '    === THE SECRETLESS WAY ==='" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo '========================================'" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo ''" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo '  Run: claude'" Enter
tmux send-keys -t "${SESSION}.1" \
  "echo ''" Enter

# Focus on the left main pane to start
tmux select-pane -t "${SESSION}.0"

# --- Pre-presentation reminders ----------------------------------------------
echo ""
echo "============================================================"
echo "  AKEYLESS DEMO SESSION READY"
echo "============================================================"
echo ""
echo "  Pre-presentation checklist:"
echo ""
echo "    1. Increase terminal font size to 18pt+"
echo "    2. Launch 'claude' in both main panes"
echo "    3. Disable desktop notifications"
echo "    4. Open Akeyless Console with 3 browser tabs:"
echo "       - Audit Log"
echo "       - AI Insights"
echo "       - Dynamic Secret configuration"
echo ""
echo "============================================================"
echo ""

# Attach to the session
exec tmux attach-session -t "${SESSION}"
