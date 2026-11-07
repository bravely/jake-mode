# Verbose transcript during voice conversations

A VoiceMode voice conversation lives inside `converse` tool calls, which the desktop app's normal transcript view collapses, so I see nothing of what we said. Bracket each voice conversation with the transcript view, using `mcp__ccd_view__get_layout` and `mcp__ccd_view__set_transcript_view` (desktop app only; possibly deferred, load them with ToolSearch):

- **Open:** before the first `converse` call, note `transcript_view` from `get_layout`, then set `view: "verbose"`.
- **Close:** when the voice conversation ends (I ask for text, you make a final speak-only call, or you answer in text again), set the view back to the one you noted. Restore only while it is still verbose; any other view by then is my own choice and stands.
- **Not open in any window:** keep talking, retry on the next `converse` call, and mention it in text afterwards if it never took.
