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

    component DockButton: Button {
        id: control
        font.pixelSize: 14
        palette.buttonText: shell.gold
        background: Rectangle {
            radius: 8
            color: control.hovered ? "#29425a" : "#101b2b"
            border.color: "#4c6072"
            border.width: 1
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
            spacing: 8
            DockButton {
                text: "☀  MayaOS"
                onClicked: { shell.launcherOpen = !shell.launcherOpen; shell.settingsOpen = false }
            }
            DockButton { text: "Files"; onClicked: mayaBridge.launch("files") }
            DockButton { text: "Terminal"; onClicked: mayaBridge.launch("terminal") }
            DockButton { text: "Settings"; onClicked: mayaBridge.launch("settings") }
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                clip: true
                contentWidth: windowsRow.implicitWidth
                Row {
                    id: windowsRow
                    spacing: 5
                    Repeater {
                        model: mayaBridge.windows
                        delegate: Row {
                            spacing: 2
                            DockButton {
                                text: modelData.title
                                onClicked: mayaBridge.activate(modelData.wid)
                            }
                            DockButton {
                                text: "–"
                                onClicked: mayaBridge.minimize(modelData.wid)
                            }
                        }
                    }
                }
            }
            DockButton {
                text: "Quick Settings"
                onClicked: { shell.settingsOpen = !shell.settingsOpen; shell.launcherOpen = false }
            }
            Text { text: mayaBridge.clock; color: shell.textColor; font.pixelSize: 13 }
        }
    }

    Window {
        id: launcher
        visible: shell.launcherOpen
        title: "MayaOS Launcher"
        flags: Qt.Tool | Qt.WindowStaysOnTopHint
        color: "#101b2b"
        width: 360
        height: 390
        x: 12
        y: Screen.height - height - shell.height - 10
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12
            Text { text: "MayaOS Applications"; color: shell.gold; font.pixelSize: 20 }
            TextField { id: search; Layout.fillWidth: true; placeholderText: "Search applications" }
            Repeater {
                model: [
                    { label: "Files", key: "files" },
                    { label: "Terminal", key: "terminal" },
                    { label: "Settings", key: "settings" },
                    { label: "Sound", key: "sound" },
                    { label: "Network", key: "network" },
                    { label: "Notifications", key: "notifications" }
                ]
                delegate: DockButton {
                    required property var modelData
                    visible: modelData.label.toLowerCase().includes(search.text.toLowerCase())
                    text: modelData.label
                    Layout.fillWidth: true
                    onClicked: { mayaBridge.launch(modelData.key); shell.launcherOpen = false }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
    Window {
        id: quickSettings
        visible: shell.settingsOpen
        title: "MayaOS Quick Settings"
        flags: Qt.Tool | Qt.WindowStaysOnTopHint
        color: "#101b2b"
        width: 390
        height: 240
        x: Screen.width - width - 12
        y: Screen.height - height - shell.height - 10
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
