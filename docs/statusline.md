# Status line

`claude/statusline.sh` is symlinked to `~/.claude/statusline.sh` and registered via the `statusLine` key, so edits in the repo take effect immediately with no reinstall. It renders:

```
ai-skills · ⎇ ABC-1 · Opus5·hi · ctx 33% 65k · 5h 12% ↻1.3h
```

Directory and git worktree, model and reasoning effort (`lo`/`md`/`hi`/`xh`), context window (percentage plus absolute tokens), and the 5-hour rate-limit window with a countdown to its reset. Percentages turn yellow at 50% and red at 80%, rounded so the colour never disagrees with the number beside it.

## Fitting the terminal

The line is built to fit 80 columns — or `$COLUMNS`, if the terminal exports it. Should it overrun — a long branch on a narrow terminal — the branch is truncated with an ellipsis, then dropped entirely if fewer than three characters would survive, and only then is the directory trimmed, to a floor of eight characters. The fixed-width segments are never sacrificed. Model and effort stay abbreviated (`Opus5·hi`) rather than spelled out, which keeps roughly nine columns in reserve for long branch names.

## Countdowns

Reset countdowns always round *up*, to one decimal where the unit warrants it — `1.1h`, `1.1d` — because under-reporting time remaining is the costly direction. A trailing `.0` is dropped, so exact values stay compact (`2h`, `7d`), and the unit only changes at a full 1.0, so 23 hours reads `23h` rather than `0.9d`. Anything under a minute renders `<1m` instead of rounding up to `1m`, which would imply headroom that isn't there.

## Data sources

Every value comes from the JSON the harness pipes in on stdin — nothing is scraped or estimated. Segments whose fields are absent drop out silently rather than rendering placeholders: `rate_limits` is missing until the first API response of a session and for non-subscription auth, and `context_window.current_usage` is null immediately after `/compact`. `refreshInterval: 60` is set because the reset countdowns are time-based and the harness otherwise re-renders only on events, which would leave them stale while idle.

One limit worth knowing, a property of the data rather than the script: Fable 5 is metered against dollar-denominated usage credits rather than a percentage window, so no Fable figure can appear here at all. Use `/usage` and `/usage-credits` for that, and for the per-model breakdown the rate-limit fields do not carry.
