pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../shared"
import "../toolbar"

FocusScope {
    id: login

    property Item backdrop: null
    property string userName: "Frederik Handberg"
    property bool locked: true
    property date now: new Date()
    property string statusMessage: ""
    signal unlocked()
    signal systemAction(string action)

    visible: locked || opacity > 0
    enabled: locked
    opacity: locked ? 1 : 0
    focus: locked

    Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.InOutQuad } }

    onLockedChanged: {
        password.clear();
        statusMessage = "";
        if (locked)
            password.forceActiveFocus(Qt.OtherFocusReason);
    }

    function unlock() {
        if (!password.text.length) {
            password.forceActiveFocus();
            return;
        }
        password.clear();
        login.unlocked();
    }

    Timer {
        interval: 1000
        running: login.visible
        repeat: true
        onTriggered: login.now = new Date()
    }

    // Soften the same wallpaper used by the desktop, with no enclosing card.
    GlassSurface {
        anchors.fill: parent
        backdrop: login.backdrop
        sampleOrigin: Qt.point(0, 0)
        radius: 0
        tintOpacity: 0.25
        fallbackOpacity: 0.65
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#10121b35" }
            GradientStop { position: 1; color: "#88111527" }
        }
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: Math.max(28, login.height * 0.085)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        visible: login.height >= 480

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(login.now, "dddd, MMMM d")
            color: "#d9dceb"
            font.pixelSize: 15
            font.weight: Font.Medium
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(login.now, "hh:mm")
            color: "#f3f2fa"
            font.pixelSize: 68
            font.weight: Font.Light
            font.letterSpacing: -2
        }
    }

    Column {
        id: profile

        width: 240
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: login.height >= 480 ? 32 : -25
        spacing: 0

        Image {
            id: avatar

            anchors.horizontalCenter: parent.horizontalCenter
            width: login.height >= 480 ? 88 : 72
            height: width
            source: "Avatar.svg"
            sourceSize: Qt.size(width * 2, height * 2)
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: avatar.width
                    height: avatar.height
                    radius: width / 2
                }
            }
            Accessible.ignored: true
        }

        Text {
            width: parent.width
            topPadding: 15
            bottomPadding: 21
            text: login.userName
            horizontalAlignment: Text.AlignHCenter
            color: "#f7f6fc"
            font.pixelSize: 23
            font.weight: Font.Medium
        }

        TextField {
            id: password

            objectName: "loginPassword"
            width: parent.width
            height: 40
            focus: true
            leftPadding: 15
            rightPadding: 43
            color: "#ffffff"
            placeholderTextColor: "#bfc1d3"
            placeholderText: "Enter password"
            echoMode: TextInput.Password
            passwordCharacter: "●"
            selectByMouse: true
            font.pixelSize: 13
            font.letterSpacing: text.length > 0 ? 1.5 : 0
            Accessible.name: "Password"
            onAccepted: login.unlock()
            onTextChanged: login.statusMessage = ""

            background: Rectangle {
                radius: 20
                color: password.activeFocus ? "#28ffffff" : "#1cffffff"
                border.width: 1
                border.color: password.activeFocus ? "#77e2ddff" : "#28ffffff"
            }

            Button {
                id: submit

                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                enabled: password.text.length > 0
                hoverEnabled: true
                Accessible.name: "Sign in"
                onClicked: login.unlock()
                background: Rectangle {
                    radius: 14
                    color: submit.down ? "#80ffffff" : submit.hovered ? "#60ffffff" : "#30ffffff"
                    opacity: submit.enabled ? 1 : 0.4
                    border.color: submit.visualFocus ? "#ffffff" : "transparent"
                }
                contentItem: ToolbarGlyph {
                    symbol: "right"
                    size: 16
                    opacity: submit.enabled ? 1 : 0.4
                }
            }
        }

        Text {
            width: parent.width
            topPadding: 11
            text: login.statusMessage
            horizontalAlignment: Text.AlignHCenter
            color: "#a9adc4"
            font.pixelSize: 11
        }
    }

    Row {
        id: powerControls

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: login.height >= 480 ? 30 : 14
        spacing: 26

        Repeater {
            model: [
                { label: "Sleep", symbol: "sleep", action: "sleep" },
                { label: "Restart", symbol: "restart", action: "restart" },
                { label: "Shut Down", symbol: "power", action: "shutdown" }
            ]

            delegate: Button {
                id: powerButton

                required property var modelData
                width: 64
                height: 64
                hoverEnabled: true
                Accessible.name: modelData.label
                onClicked: {
                    login.statusMessage = modelData.label + " requested · preview only";
                    login.systemAction(modelData.action);
                }
                background: Item {}
                contentItem: Column {
                    spacing: 8

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 36
                        height: 36
                        radius: 18
                        color: powerButton.down ? "#40ffffff" : powerButton.hovered ? "#28ffffff" : "#13ffffff"
                        border.color: powerButton.visualFocus ? "#e5dfff" : "#0fffffff"

                        ToolbarGlyph {
                            anchors.centerIn: parent
                            width: 17
                            height: 17
                            symbol: powerButton.modelData.symbol
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: powerButton.modelData.label
                        color: "#d0d2e1"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
