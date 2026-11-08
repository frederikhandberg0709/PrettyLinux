pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import "../shared"

Rectangle {
    id: window

    required property var windowData
    property bool active: false
    signal activated()
    signal closeRequested()
    signal newRequested()

    radius: 14
    color: "#20232e"
    border.color: active ? "#756d99" : "#414552"
    clip: true
    Accessible.role: Accessible.Window
    Accessible.name: windowData.title

    TapHandler { onTapped: window.activated() }

    Rectangle {
        id: titlebar
        x: 1
        y: 1
        width: parent.width - 2
        height: 42
        radius: 13
        color: window.active ? "#343646" : "#2b2e39"

        DragHandler {
            target: window
            xAxis.minimum: 0
            xAxis.maximum: Math.max(0, window.parent.width - window.width)
            yAxis.minimum: 0
            yAxis.maximum: Math.max(0, window.parent.height - window.height)
            onActiveChanged: if (active) window.activated()
        }

        AppTile {
            x: 13
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: width
            appData: window.windowData.app
        }

        Text {
            x: 45
            width: parent.width - 130
            anchors.verticalCenter: parent.verticalCenter
            text: window.windowData.title
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: "#edeef6"
            font.pixelSize: 12
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Button {
                text: "+"
                width: 28
                height: 28
                Accessible.name: "New " + window.windowData.app.name + " window"
                onClicked: window.newRequested()
            }
            Button {
                text: "×"
                width: 28
                height: 28
                Accessible.name: "Close " + window.windowData.title
                onClicked: window.closeRequested()
            }
        }
    }

    Item {
        id: body
        anchors.top: titlebar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 18

        Rectangle {
            width: 102
            height: parent.height
            radius: 8
            color: "#181b24"

            Column {
                x: 12
                y: 15
                spacing: 17
                Repeater {
                    model: ["WORKSPACE", "Overview", "Projects", "Favorites"]
                    Text {
                        required property string modelData
                        text: modelData
                        color: modelData === "WORKSPACE" ? "#848ba4" : "#c4c8db"
                        font.pixelSize: 10
                    }
                }
            }
        }

        Column {
            x: 120
            width: Math.max(0, body.width - x)
            spacing: 12

            Rectangle {
                width: parent.width
                height: 25
                radius: 6
                color: "#151822"
                Text {
                    x: 9
                    anchors.verticalCenter: parent.verticalCenter
                    text: window.windowData.app.name === "Browser"
                          ? "https://" + (window.windowData.ordinal % 2 ? "design.example" : "wayland.example")
                          : window.windowData.app.name + " / Workspace"
                    color: "#a5adc4"
                    font.pixelSize: 10
                }
            }

            Text {
                width: parent.width
                text: window.windowData.title
                textFormat: Text.PlainText
                color: "#f1f0fa"
                font.pixelSize: 21
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width
                height: 95
                radius: 9
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.lighter(window.windowData.app.accent, 1.4) }
                    GradientStop { position: 1; color: window.windowData.ordinal % 2 ? "#4e3b78" : "#193c58" }
                }
                Text {
                    anchors.centerIn: parent
                    text: window.windowData.app.name === "Terminal" ? "$ npm run dev\n› Ready on localhost:3000"
                          : window.windowData.ordinal % 2 ? "A space for your next idea." : "Build something beautiful."
                    color: "#f3f4ff"
                    font.pixelSize: 13
                }
            }

            TextEdit {
                objectName: "windowEditor"
                width: parent.width
                height: 48
                text: "Window " + window.windowData.windowId + " · " + window.windowData.app.name
                      + "\nEdit this text to see the live preview update."
                color: "#b4bbd1"
                font.pixelSize: 11
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                onActiveFocusChanged: if (activeFocus) window.activated()
            }
        }
    }
}
