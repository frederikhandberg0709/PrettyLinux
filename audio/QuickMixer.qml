pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../toolbar"

ScrollView {
    id: mixer
    required property AudioState audio
    signal settingsRequested(int appIndex)
    property int expandedApp: -1
    implicitHeight: 506
    contentWidth: availableWidth
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    palette.text: "#f1f0fa"
    palette.buttonText: "#f1f0fa"
    palette.base: "#292c3c"
    palette.button: "#343748"
    palette.highlight: "#63577d"

    component Caption: Text {
        color: "#aeb3c7"
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 1
    }
    component Action: Button {
        id: action
        implicitHeight: 26
        font.pixelSize: 10
        hoverEnabled: true
        background: Rectangle {
            radius: 7
            color: action.checked ? "#38c6b8ff" : action.hovered ? "#24ffffff" : "#10ffffff"
            border.color: action.visualFocus ? "#c6b8ff" : "transparent"
        }
    }
    component DeviceChoice: ComboBox {
        id: choice
        Layout.fillWidth: true
        implicitHeight: 26
        font.pixelSize: 11
        background: Rectangle {
            radius: 6
            color: choice.hovered ? "#22ffffff" : "#0affffff"
            border.color: choice.visualFocus ? "#c6b8ff" : "transparent"
        }
    }
    component VolumeRow: RowLayout {
        id: row
        required property string label
        required property real level
        required property bool muted
        signal moved(int value)
        signal muteRequested()
        spacing: 8
        Action {
            objectName: row.objectName + "Mute"
            implicitWidth: 28
            checked: row.muted
            Accessible.name: row.label + (row.muted ? " unmute" : " mute")
            onClicked: row.muteRequested()
            contentItem: Item {
                ToolbarGlyph { anchors.centerIn: parent; symbol: row.muted || row.level === 0 ? "mute" : "volume"; size: 15 }
            }
        }
        Slider {
            id: slider
            objectName: row.objectName + "Level"
            Layout.fillWidth: true
            implicitHeight: 24
            from: 0
            to: 100
            stepSize: 1
            value: row.level
            Accessible.name: row.label + " volume"
            onMoved: row.moved(Math.round(value))
            background: Rectangle {
                x: slider.leftPadding
                y: (slider.height - height) / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: "#32ffffff"
                Rectangle { width: parent.width * slider.visualPosition; height: 4; radius: 2; color: row.muted ? "#77798b" : "#c6b8ff" }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: (slider.height - height) / 2
                implicitWidth: 12
                implicitHeight: 12
                radius: 6
                color: "#f4f0ff"
                border.width: slider.visualFocus ? 2 : 0
                border.color: "#9d85d4"
            }
        }
        Text { text: Math.round(row.level) + "%"; color: "#b8b7cc"; font.pixelSize: 11; Layout.preferredWidth: 32; horizontalAlignment: Text.AlignRight }
    }
    ColumnLayout {
        width: mixer.availableWidth
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Sound"; color: "#f1f0fa"; font.pixelSize: 17; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Action { objectName: "audioSettings"; text: "Settings  ›"; onClicked: mixer.settingsRequested(-1) }
        }
        Repeater {
            model: ["OUTPUT", "INPUT"]
            delegate: ColumnLayout {
                id: device
                required property int index
                required property string modelData
                readonly property bool output: index === 0
                Layout.fillWidth: true
                spacing: 2
                RowLayout {
                    Caption { text: device.modelData }
                    DeviceChoice {
                        objectName: device.output ? "outputDevice" : "inputDevice"
                        model: device.output ? mixer.audio.outputs : mixer.audio.inputs
                        currentIndex: device.output ? mixer.audio.outputDevice : mixer.audio.inputDevice
                        Accessible.name: device.modelData + " device"
                        onActivated: {
                            if (device.output) mixer.audio.outputDevice = currentIndex;
                            else mixer.audio.inputDevice = currentIndex;
                        }
                    }
                }
                VolumeRow {
                    objectName: device.output ? "output" : "input"
                    Layout.fillWidth: true
                    label: device.modelData
                    level: device.output ? mixer.audio.outputVolume : mixer.audio.inputVolume
                    muted: device.output ? mixer.audio.outputMuted : mixer.audio.inputMuted
                    onMoved: value => {
                        if (device.output) mixer.audio.outputVolume = value;
                        else mixer.audio.inputVolume = value;
                    }
                    onMuteRequested: {
                        if (device.output) mixer.audio.outputMuted = !mixer.audio.outputMuted;
                        else mixer.audio.inputMuted = !mixer.audio.inputMuted;
                    }
                }
            }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#24ffffff" }
        Caption { text: "APPLICATIONS" }
        Repeater {
            model: mixer.audio.apps.length
            delegate: ColumnLayout {
                id: appRow
                required property int index
                readonly property var app: mixer.audio.apps[index]
                Layout.fillWidth: true
                spacing: 0
                RowLayout {
                    Rectangle {
                        implicitWidth: 22; implicitHeight: 22; radius: 7; color: appRow.app.accent
                        Text { anchors.centerIn: parent; text: appRow.app.name[0]; color: "white"; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    Text { text: appRow.app.name; color: "#f1f0fa"; font.pixelSize: 12; Layout.fillWidth: true }
                    Action {
                        objectName: "editEq" + appRow.index
                        text: "EQ" + (appRow.app.eqEnabled ? " •" : "")
                        Accessible.name: appRow.app.name + " equalizer settings"
                        onClicked: {
                            mixer.expandedApp = mixer.expandedApp === appRow.index ? -1 : appRow.index;
                            if (mixer.expandedApp >= 0) Qt.callLater(() => {
                                const viewport = mixer.contentItem as Flickable;
                                viewport.contentY = Math.max(0, Math.min(appRow.y, viewport.contentHeight - viewport.height));
                            });
                        }
                    }
                }
                VolumeRow {
                    objectName: "app" + appRow.index
                    Layout.fillWidth: true
                    label: appRow.app.name
                    level: appRow.app.volume
                    muted: appRow.app.muted
                    onMoved: value => mixer.audio.updateApp(appRow.index, "volume", value)
                    onMuteRequested: mixer.audio.updateApp(appRow.index, "muted", !appRow.app.muted)
                }
                DeviceChoice {
                    objectName: "appRoute" + appRow.index
                    implicitHeight: 23
                    model: ["Default output"].concat(mixer.audio.outputs)
                    currentIndex: appRow.app.output
                    Accessible.name: appRow.app.name + " output routing"
                    onActivated: mixer.audio.updateApp(appRow.index, "output", currentIndex)
                }
                CompactEqualizer {
                    objectName: "inlineEq" + appRow.index
                    Layout.fillWidth: true
                    visible: mixer.expandedApp === appRow.index
                    audio: mixer.audio
                    appIndex: appRow.index
                    onAdvancedRequested: mixer.settingsRequested(appRow.index)
                }
            }
        }
        Text { text: "Preview audio · simulated devices"; color: "#9195aa"; font.pixelSize: 10; Layout.topMargin: 2 }
    }
}
