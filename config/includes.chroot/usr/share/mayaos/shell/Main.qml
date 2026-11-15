import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: shell
    visible: true
    title: "MayaOS Native Preview"
    color: "#17263a"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    width: Screen.width
    height: 64
    x: 0
    y: Screen.height - height

    property color gold: "#e9c979"
    property color ink: "#17263a"
    property color textColor: "#f6f3eb"
    property bool launcherOpen: false
    property bool settingsOpen: false
    property bool hubOpen: false
    property bool reduceMotion: true
    property int dockButtonWidth: shell.width < 950 ? 110 : 150
    Shortcut {
        sequences: ["Ctrl+Space"]
        onActivated: {
            shell.launcherOpen = !shell.launcherOpen
            shell.settingsOpen = false
        }
    }
    Shortcut {
        sequences: ["Escape"]
        onActivated: {
            shell.launcherOpen = false
            shell.settingsOpen = false
        }
    }

    component DockButton: Button {
        id: control
        font.pixelSize: 14
        focusPolicy: Qt.StrongFocus
        Accessible.name: text
        ToolTip.visible: hovered
        ToolTip.text: text
        ToolTip.delay: 700
        palette.buttonText: shell.gold
        background: Rectangle {
            radius: 8
            color: control.hovered ? "#29425a" : "#101b2b"
            border.color: control.activeFocus ? shell.gold : "#4c6072"
            border.width: control.activeFocus ? 2 : 1
        }
        implicitHeight: 42
        leftPadding: 14
        rightPadding: 14
    }

    Rectangle {
        anchors.fill: parent
        color: shell.ink
        RowLayout {
            anchors.fill: parent
            anchors.margins: 9
            spacing: shell.width < 950 ? 4 : 8
            DockButton {
                text: "☀  MayaOS"
                onClicked: { shell.launcherOpen = !shell.launcherOpen; shell.settingsOpen = false }
            }
            DockButton { text: "Files"; onClicked: mayaBridge.launch("files") }
            DockButton { text: "Terminal"; onClicked: mayaBridge.launch("terminal") }
            DockButton { text: "Settings"; visible: shell.width >= 800; onClicked: { shell.hubOpen = !shell.hubOpen; shell.launcherOpen = false; shell.settingsOpen = false } }
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                clip: true
                contentWidth: windowsRow.implicitWidth
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentWidth > width
                Row {
                    id: windowsRow
                    spacing: 5
                    Repeater {
                        model: mayaBridge.windows
                        delegate: Row {
                            spacing: 2
                            DockButton {
                                text: modelData.title
                                width: shell.dockButtonWidth
                                onClicked: mayaBridge.activate(modelData.wid)
                            }
                            DockButton {
                                text: "–"
                                Accessible.name: "Minimize " + modelData.title
                                ToolTip.text: "Minimize " + modelData.title
                                leftPadding: 8
                                rightPadding: 8
                                onClicked: mayaBridge.minimize(modelData.wid)
                            }
                        }
                    }
                }
            }
            DockButton {
                text: shell.width < 800 ? "Controls" : "Quick Settings"
                onClicked: { shell.settingsOpen = !shell.settingsOpen; shell.launcherOpen = false }
            }
            Text { text: mayaBridge.clock; color: shell.textColor; font.pixelSize: shell.width < 850 ? 11 : 13 }
        }
    }

    Window {
        id: launcher
        visible: shell.launcherOpen
        onVisibleChanged: if (visible) search.forceActiveFocus()
        title: "MayaOS Launcher"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "#101b2b"
        width: Math.min(400, Screen.width - 24)
        height: Math.min(420, Screen.height - shell.height - 30)
        x: Math.max(8, shell.x + 9)
        y: Math.max(8, shell.y - height - 8)
        Rectangle { anchors.fill: parent; radius: 12; color: "transparent"; border.color: "#4c6072"; border.width: 2 }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12
            Text { text: "MayaOS Applications"; color: shell.gold; font.pixelSize: 20 }
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search applications"
                Accessible.name: "Search MayaOS applications"
                Keys.onEscapePressed: shell.launcherOpen = false
            }
            Repeater {
                model: [
                    { label: "Files", key: "files" },
                    { label: "Terminal", key: "terminal" },
                    { label: "System Settings", key: "maya-settings" },
                    { label: "Sound", key: "sound" },
                    { label: "Network", key: "network" },
                    { label: "Notifications", key: "notifications" }
                ]
                delegate: DockButton {
                    required property var modelData
                    visible: modelData.label.toLowerCase().includes(search.text.toLowerCase())
                    text: modelData.label
                    Layout.fillWidth: true
                    onClicked: { if (modelData.key === "maya-settings") { shell.hubOpen = true } else { mayaBridge.launch(modelData.key) }; shell.launcherOpen = false }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
    // Phase 3.0: MayaOS-owned settings dashboard, with safe XFCE-backed controls.
    Window {
        id: settingsHub
        visible: shell.hubOpen
        title: "MayaOS System Settings"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "#101b2b"
        width: Math.min(540, Screen.width - 24)
        height: Math.min(460, Screen.height - shell.height - 24)
        x: Math.max(8, Math.floor((Screen.width - width) / 2))
        y: Math.max(8, Math.floor((Screen.height - height - shell.height) / 2))
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: 12
            border.color: "#4c6072"
            border.width: 2
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            RowLayout {
                Layout.fillWidth: true
                Text { text: "MayaOS System Settings"; color: shell.gold; font.pixelSize: 22; Layout.fillWidth: true }
                DockButton { text: "Close"; onClicked: shell.hubOpen = false }
            }
            Text {
                text: "Desktop and device controls"
                color: shell.textColor
                font.pixelSize: 14
            }
            Text {
                text: mayaBridge.status
                color: shell.textColor
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
            GridLayout {
                columns: settingsHub.width < 430 ? 1 : 2
                columnSpacing: 12
                rowSpacing: 12
                Layout.fillWidth: true
                DockButton { text: "Appearance"; Layout.fillWidth: true; onClicked: mayaBridge.launch("appearance") }
                DockButton { text: "Display"; Layout.fillWidth: true; onClicked: mayaBridge.launch("display") }
                DockButton { text: "Network"; Layout.fillWidth: true; onClicked: mayaBridge.launch("network") }
                DockButton { text: "Sound"; Layout.fillWidth: true; onClicked: mayaBridge.launch("sound") }
                DockButton { text: "Notifications"; Layout.fillWidth: true; onClicked: mayaBridge.launch("notifications") }
                DockButton { text: "All XFCE Settings"; Layout.fillWidth: true; onClicked: mayaBridge.launch("settings") }
            }
            Item { Layout.fillHeight: true }
            Text {
                text: "MayaOS 3.0 preview • Settings open the installed system tools."
                color: "#b5c2cf"
                font.pixelSize: 12
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    Window {
        id: quickSettings
        visible: shell.settingsOpen
        title: "MayaOS Quick Settings"
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "#101b2b"
        width: Math.min(390, Screen.width - 24)
        height: 240
        x: Math.max(8, shell.x + shell.width - width - 12)
        y: Math.max(8, shell.y - height - 8)
        Rectangle { anchors.fill: parent; radius: 12; color: "transparent"; border.color: "#4c6072"; border.width: 2 }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12
            Text { text: "Quick Settings"; color: shell.gold; font.pixelSize: 20 }
            Text { text: mayaBridge.status; color: shell.textColor; wrapMode: Text.Wrap; Layout.fillWidth: true }
            RowLayout {
                DockButton { text: "Network"; onClicked: mayaBridge.launch("network") }
                DockButton { text: "Sound"; onClicked: mayaBridge.launch("sound") }
            }
            DockButton { text: "Notifications"; onClicked: mayaBridge.launch("notifications") }
            DockButton { text: "Session"; onClicked: mayaBridge.launch("session") }
            Item { Layout.fillHeight: true }
        }
    }
}
