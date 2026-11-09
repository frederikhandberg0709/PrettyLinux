pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: eq
    required property AudioState audio
    required property int appIndex
    readonly property var app: audio.apps[appIndex]
    signal advancedRequested()
    implicitHeight: body.implicitHeight + 20
    radius: 12
    color: "#38000000"

    ColumnLayout {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 5
        RowLayout {
            Switch {
                id: toggle
                objectName: "inlineEqToggle" + eq.appIndex
                text: "EQ"
                font.pixelSize: 11
                checked: eq.app.eqEnabled
                Accessible.name: eq.app.name + " equalizer enabled"
                onToggled: eq.audio.updateApp(eq.appIndex, "eqEnabled", checked)
                indicator: Rectangle {
                    x: toggle.leftPadding
                    y: (toggle.height - height) / 2
                    implicitWidth: 30
                    implicitHeight: 18
                    radius: 9
                    color: toggle.checked ? "#b6a0f0" : "#484957"
                    border.color: toggle.visualFocus ? "white" : "transparent"
                    Rectangle { x: toggle.checked ? 15 : 3; y: 3; width: 12; height: 12; radius: 6; color: "white" }
                }
                contentItem: Text {
                    text: "EQ"
                    color: "#f1f0fa"
                    font.pixelSize: 11
                    leftPadding: 36
                    verticalAlignment: Text.AlignVCenter
                }
            }
            ComboBox {
                objectName: "inlineEqPreset" + eq.appIndex
                Layout.fillWidth: true
                implicitHeight: 26
                font.pixelSize: 10
                model: eq.audio.presetNames
                currentIndex: eq.app.preset
                Accessible.name: eq.app.name + " equalizer preset"
                onActivated: eq.audio.applyPreset(eq.appIndex, currentIndex)
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            opacity: eq.app.eqEnabled ? 1 : 0.4
            Repeater {
                model: eq.audio.frequencies
                delegate: ColumnLayout {
                    id: band
                    required property int index
                    required property string modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.maximumWidth: Infinity
                    spacing: 3
                    Slider {
                        id: slider
                        objectName: "inlineBand" + eq.appIndex + "_" + band.index
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 20
                        implicitHeight: 86
                        orientation: Qt.Vertical
                        from: -12
                        to: 12
                        stepSize: 1
                        value: eq.app.gains[band.index]
                        enabled: eq.app.eqEnabled
                        Accessible.name: eq.app.name + " " + band.modelData + " Hz gain in dB"
                        onMoved: eq.audio.setBand(eq.appIndex, band.index, value)
                        background: Rectangle {
                            x: (slider.width - width) / 2
                            y: slider.topPadding
                            width: 3
                            height: slider.availableHeight
                            radius: 2
                            color: "#35ffffff"
                            Rectangle { x: -3; width: 9; height: 1; anchors.verticalCenter: parent.verticalCenter; color: "#55ffffff" }
                        }
                        handle: Rectangle {
                            x: (slider.width - width) / 2
                            y: slider.topPadding + slider.visualPosition * (slider.availableHeight - height)
                            implicitWidth: 11
                            implicitHeight: 11
                            radius: 6
                            color: slider.pressed ? "#c6b8ff" : "#f4f0ff"
                            border.width: slider.visualFocus ? 2 : 0
                            border.color: "#9d85d4"
                        }
                        ToolTip.visible: hovered || pressed
                        ToolTip.text: value + " dB"
                    }
                    Text { text: band.modelData; color: "#adb0c4"; font.pixelSize: 9; Layout.alignment: Qt.AlignHCenter }
                }
            }
        }
        Button {
            id: advanced
            objectName: "advancedEq" + eq.appIndex
            Layout.alignment: Qt.AlignRight
            text: "Custom curves & preamp  ›"
            flat: true
            font.pixelSize: 10
            contentItem: Text { text: advanced.text; color: "#bdb0e1"; font: advanced.font }
            onClicked: eq.advancedRequested()
        }
    }
}
