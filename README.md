# omarchy-workspaces

![screenshot](screenshot.png)

An Omarchy 4.5 shell bar-widget plugin cloned from the built-in
`omarchy.workspaces`.

The built-in widget follows Omarchy's per-monitor workspaces: each monitor
owns a block of ten, and each bar shows its own block numbered 1-10. This
plugin instead keeps one flat strip of global, absolute workspace numbers:
1-22, plus any other workspace that exists, with workspace 10 labeled `0` as
on the keyboard. Workspaces 11-22 stay hidden until `showExtended` is set.

It carries the 4.5 bar's workspace behavior onto that numbered strip:

- The current workspace is the one this bar's monitor shows, marked with the
  accent color and an underline.
- A small glyph above the current workspace's label shows its layout: a
  square tiles, a circle scrolls, and a triangle floats. Clicking the current
  workspace runs the stock layout cycle
  (`omarchy-hyprland-workspace-layout-toggle`); clicking any other workspace
  focuses that absolute number.
- The wheel scrolls one workspace per notch through the numbers shown, and
  holds at either end instead of wrapping.
- `omarchy-shell omarchy.workspaces refresh` updates it, and it watches the
  saved layout files so tools that change a layout without asking the bar to
  refresh still update the glyph.

## Install

```bash
omarchy plugin add https://github.com/houz42/omarchy-workspaces.git --enable
```

This widget replaces the built-in `omarchy.workspaces` and answers its IPC
target. Disable or remove the built-in widget from the bar rather than
placing both at once.

## Settings

Extended workspaces 11-22 are hidden from the bar by default. To show them,
set `showExtended` on the widget's entry in `~/.config/omarchy/shell.json`:

```json
{
  "id": "houz42.workspaces",
  "showExtended": true
}
```
