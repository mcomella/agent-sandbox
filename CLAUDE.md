# Agent Rules
- Any agent that writes files must call `EnterWorktree` before its first edit. When the job finishes, commit so the work survives worktree cleanup
