# omarchy-workspaces

![screenshot](screenshot.png)

An Omarchy shell bar-widget plugin that shows workspace indicators, cloned
from the built-in `omarchy.workspaces` widget with one change: workspaces
11-22 are labeled with their actual numbers (`11`-`22`) instead of the
function-key shorthand (`F1`-`F12`) used when they're bound to `SUPER+F1`..`F12`.

## Install

```bash
omarchy plugin add https://github.com/houz42/omarchy-workspaces.git --enable
```

## Settings

Extended workspaces 11-22 are hidden from the bar by default. To show them,
set `showExtended` on the widget's entry in `~/.config/omarchy/shell.json`:

```json
{
  "id": "jhou.workspaces",
  "showExtended": true
}
```
