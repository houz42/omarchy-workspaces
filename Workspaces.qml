import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "houz42.workspaces"

  readonly property bool showExtended: setting("showExtended", false)

  // The workspaces this bar shows are numbered globally, but the one that reads
  // as current is the one this bar's own monitor shows, whichever monitor has
  // keyboard focus.
  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? String(root.monitor.name || "") : ""

  function activeWorkspaceId() {
    return root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : -1
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // The workspaces the bar shows, by their absolute numbers: the first five
  // always, and every other one that exists within the shown range.
  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values
    var maxId = root.showExtended ? 22 : 10

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= maxId && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  // Ten closes the block the keyboard's 0 reaches.
  function workspaceLabel(id) {
    if (id === 10) return "0"
    return String(id)
  }

  // Focus is asked for by absolute number, so a click on any bar targets the
  // workspace its label shows.
  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  // A wheel notch moves one workspace along the row, and a touchpad adds up its
  // smaller deltas until they make a notch's worth. It holds at either end
  // rather than wrapping, so a long swipe stops on the last workspace shown.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return

    var ids = root.workspaceIds()
    var index = ids.indexOf(root.activeWorkspaceId())
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(target)
  }

  function refresh() {
    Hyprland.refreshMonitors()
    Hyprland.refreshWorkspaces()
  }

  // The layout commands act on the focused workspace, so a click on another
  // monitor's bar focuses that monitor first.
  function cycleLayout() {
    if (!root.bar) return
    var command = "omarchy-hyprland-workspace-layout-toggle"
    if (root.monitor && !root.monitor.focused && root.monitorName !== "") {
      command = "hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ monitor = \"" + root.monitorName + "\" })") + " >/dev/null && " + command
    }
    root.bar.run(command)
  }


  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "configreloaded") root.refresh()
      // Quickshell credits every workspace switch to the focused monitor, as
      // the event doesn't say which one switched, and misses the workspace a
      // monitor falls back to when its own is moved away. Moving workspaces
      // between monitors switches the others, so ask Hyprland for the truth.
      // Every bar shares what Hyprland answers, so one asks after a plain
      // switch.
      var switched = name === "workspacev2" && root.monitor !== null && root.monitor.focused
      if (switched || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }


  // The built-in widget's target and method, so the layout commands'
  // `omarchy-shell omarchy.workspaces refresh` reaches this one instead.
  ShellIpc {
    target: "omarchy.workspaces"

    function refresh(): void { root.broadcast("refresh") }
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      Item {
        id: cell
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool current: root.activeWorkspaceId() === modelData

        implicitWidth: button.implicitWidth
        implicitHeight: button.implicitHeight

        WidgetButton {
          id: button
          bar: root.bar
          text: root.workspaceLabel(cell.modelData)
          foreground: cell.current ? Commons.Color.accent : (bar ? bar.barForeground : Commons.Color.foreground)
          opacity: cell.occupied || cell.current ? 1 : 0.5
          horizontalMargin: 6
          verticalPadding: 6
          fixedWidth: root.vertical ? root.barSize : Style.space(20)
          fixedHeight: root.barSize
          onPressed: function() {
            // The current workspace has nowhere to go, so a click on it runs
            // the stock layout cycle instead.
            if (cell.current) root.cycleLayout()
            else root.focusWorkspace(cell.modelData)
          }
          onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
        }

        Rectangle {
          visible: cell.current
          color: Commons.Color.accent
          height: 2
          radius: 1
          width: Style.space(12)
          anchors.horizontalCenter: button.horizontalCenter
          anchors.bottom: button.bottom
          anchors.bottomMargin: 1
        }
      }
    }
  }
}
