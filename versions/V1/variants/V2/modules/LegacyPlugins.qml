import QtQuick
import Quickshell.Io

// Omarchy bar plugins Rise does not ship. Drawn with the same Material icon,
// size, and idle color as the buttons beside them. The click talks to the
// Omarchy shell, which still has the real widgets loaded.
Item {
    id: legacy
    required property var root
    property int iconSpacing: 4

    implicitWidth: iconRow.implicitWidth
    implicitHeight: 28

    Process {
        id: runner
        command: ["true"]
    }

    function launch(cmd) {
        runner.command = cmd
        runner.running = false
        runner.running = true
    }

    component LegacyButton: Item {
        id: button
        required property var host
        required property string tipText
        required property string iconName
        required property var command

        implicitWidth: 22
        implicitHeight: 28

        IconText {
            anchors.centerIn: parent
            text: button.iconName
            font.pixelSize: 14
            font.weight: Font.Normal
            color: mouse.containsMouse
                ? button.host.root.seal
                : Qt.rgba(button.host.root.ink.r, button.host.root.ink.g, button.host.root.ink.b, 0.65)
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        TooltipMixin { id: tip; root: button.host.root; owner: button; text: button.tipText }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: tip.show()
            onExited: tip.hide()
            onClicked: {
                tip.hide()
                button.host.launch(button.command)
            }
        }
    }

    Row {
        id: iconRow
        spacing: legacy.iconSpacing
        anchors.verticalCenter: parent.verticalCenter

        LegacyButton {
            host: legacy
            iconName: "bolt"
            tipText: "Flux"
            command: ["omarchy-shell", "shell", "toggle", "flux", "{}"]
        }
        LegacyButton {
            host: legacy
            iconName: "folder"
            tipText: "Omafile"
            command: ["omarchy-shell", "shell", "toggle", "xyzlab.omafile", "{}"]
        }
        LegacyButton {
            host: legacy
            iconName: "monitoring"
            tipText: "Agent Activity"
            command: ["omarchy-shell", "shell", "toggle", "agf.agent-activity", "{}"]
        }
        LegacyButton {
            host: legacy
            iconName: "view_column"
            tipText: "Workspace Layout"
            command: ["omarchy-shell", "shell", "toggle", "bjarneo.workspace-layout", "{}"]
        }
        LegacyButton {
            host: legacy
            iconName: "grid_view"
            tipText: "Tailscale"
            command: ["omarchy-shell", "shell", "toggle", "omarchy.tailscale", "{}"]
        }
        LegacyButton {
            host: legacy
            iconName: "account_tree"
            tipText: "CI"
            command: ["omarchy-shell", "shell", "toggle", "alex.ci", "{}"]
        }
        LegacyButton {
            host: legacy
            iconName: "memory"
            tipText: "Hardware"
            command: ["omarchy-launch-or-focus-tui", "btop"]
        }
        LegacyButton {
            host: legacy
            iconName: "smart_toy"
            tipText: "Agents"
            command: ["omarchy-shell", "shell", "toggle", "omarchy.agents", "{}"]
        }
    }
}
