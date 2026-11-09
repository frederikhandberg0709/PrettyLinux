pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ScrollView {
    id: mixer
    required property AudioState audio
    readonly property int selectedApp: audio.editingApp
    readonly property var current: audio.apps[selectedApp]
    readonly property color ink: "#f1f0fa"
    readonly property color muted: "#b3b7cd"
    readonly property color accent: "#c6b8ff"
    clip: true
    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    component LabelText: Text {
        color: mixer.ink
        font.pixelSize: 12
    }

    component Action: Button {
        id: action
        palette.buttonText: mixer.ink
        font.pixelSize: 11
        implicitHeight: 30
        background: Rectangle {
            radius: 8
            color: action.down ? "#40503f70" : action.checked || action.hovered ? "#354c4968" : "#18ffffff"
            border.color: action.visualFocus ? mixer.accent : "transparent"
        }
    }

    component Choice: ComboBox {
        id: choice
        Layout.fillWidth: true
        palette.text: mixer.ink
        palette.buttonText: mixer.ink
        palette.base: "#292c3c"
        palette.button: "#343748"
        palette.highlight: "#63577d"
        font.pixelSize: 11
        implicitHeight: 30
        background: Rectangle {
            radius: 7
            color: "#242733"
            border.color: choice.visualFocus ? mixer.accent : "#35ffffff"
        }
    }

    component Level: Slider {
        id: level
        Layout.fillWidth: true
        from: 0
        to: 100
        stepSize: 1
        implicitHeight: 26
        background: Rectangle {
            x: level.leftPadding
            y: (level.height - height) / 2
            width: level.availableWidth
            height: 5
            radius: 3
            color: "#36ffffff"
            Rectangle {
                width: level.visualPosition * parent.width
                height: parent.height
                radius: 3
                color: mixer.accent
            }
        }
        handle: Rectangle {
            x: level.leftPadding + level.visualPosition * (level.availableWidth - width)
            y: (level.height - height) / 2
            implicitWidth: 13
            implicitHeight: 13
            radius: 7
            color: level.pressed ? mixer.accent : "#f4f0ff"
            border.color: level.visualFocus ? "#8570ba" : "transparent"
            border.width: 2
        }
    }

    ColumnLayout {
        width: mixer.availableWidth
        spacing: 12

        LabelText { text: "App equalizer"; font.pixelSize: 20; font.weight: Font.DemiBold }
        LabelText { text: "Choose an app to shape its sound."; color: mixer.muted }
        Choice {
            objectName: "eqApp"
            model: mixer.audio.apps.map(app => app.name)
            currentIndex: mixer.selectedApp
            Accessible.name: "Application to equalize"
            onActivated: mixer.audio.editingApp = currentIndex
        }
        Rectangle {
            id: eqPanel
            Layout.fillWidth: true
            implicitHeight: eqBody.implicitHeight + 28
            radius: 12
            color: "#13ffffff"
            border.color: "#26ffffff"
            ColumnLayout {
                id: eqBody
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10
                RowLayout {
                    LabelText { text: mixer.current.name + " equalizer"; font.pixelSize: 15; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    Action {
                        objectName: "eqToggle"
                        text: checked ? "Enabled" : "Bypassed"
                        checkable: true
                        checked: mixer.current.eqEnabled
                        onClicked: mixer.audio.updateApp(mixer.selectedApp, "eqEnabled", checked)
                    }
                }
                LabelText { text: "10 bands · ±12 dB · curves stay independent for each app"; color: mixer.muted; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                RowLayout {
                    Choice {
                        objectName: "eqPreset"
                        model: mixer.audio.presetNames
                        currentIndex: mixer.current.preset
                        Accessible.name: "Equalizer preset"
                        onActivated: mixer.audio.applyPreset(mixer.selectedApp, currentIndex)
                    }
                    Action { text: "Reset"; onClicked: mixer.audio.applyPreset(mixer.selectedApp, 0) }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    opacity: mixer.current.eqEnabled ? 1 : 0.45
                    Repeater {
                        model: mixer.audio.frequencies
                        delegate: ColumnLayout {
                            id: band
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.maximumWidth: Infinity
                            spacing: 4
                            LabelText {
                                Layout.alignment: Qt.AlignHCenter
                                text: (mixer.current.gains[band.index] > 0 ? "+" : "") + mixer.current.gains[band.index]
                                color: mixer.accent
                                font.pixelSize: 10
                            }
                            Slider {
                                id: eqSlider
                                objectName: "eqBand" + band.index
                                Layout.alignment: Qt.AlignHCenter
                                implicitHeight: 112
                                implicitWidth: 24
                                orientation: Qt.Vertical
                                from: -12
                                to: 12
                                stepSize: 1
                                value: mixer.current.gains[band.index]
                                enabled: mixer.current.eqEnabled
                                palette.highlight: mixer.accent
                                Accessible.name: band.modelData + " Hz gain in dB"
                                onMoved: mixer.audio.setBand(mixer.selectedApp, band.index, value)
                                background: Rectangle {
                                    x: (eqSlider.width - width) / 2
                                    y: eqSlider.topPadding
                                    width: 4
                                    height: eqSlider.availableHeight
                                    radius: 2
                                    color: "#40ffffff"
                                }
                                handle: Rectangle {
                                    x: (eqSlider.width - width) / 2
                                    y: eqSlider.topPadding + eqSlider.visualPosition * (eqSlider.availableHeight - height)
                                    implicitWidth: 12
                                    implicitHeight: 12
                                    radius: 6
                                    color: eqSlider.pressed ? mixer.accent : "#f4f0ff"
                                    border.color: eqSlider.visualFocus ? mixer.accent : "transparent"
                                    border.width: 2
                                }
                            }
                            LabelText { text: band.modelData; font.pixelSize: 10; color: mixer.muted; Layout.alignment: Qt.AlignHCenter }
                        }
                    }
                }
                RowLayout {
                    LabelText { text: "Preamp" }
                    Level {
                        objectName: "eqPreamp"
                        from: -12
                        to: 12
                        enabled: mixer.current.eqEnabled
                        value: mixer.current.preamp
                        Accessible.name: "Equalizer preamp in dB"
                        onMoved: {
                            mixer.audio.updateApp(mixer.selectedApp, "preamp", Math.round(value));
                            mixer.audio.updateApp(mixer.selectedApp, "preset", 4);
                        }
                    }
                    LabelText { text: mixer.current.preamp + " dB"; Layout.preferredWidth: 40 }
                }
                LabelText { text: "Lower preamp when boosting bands to leave headroom."; color: mixer.muted; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                RowLayout {
                    TextField {
                        id: curveName
                        objectName: "curveName"
                        Layout.fillWidth: true
                        placeholderText: "Name your custom curve"
                        maximumLength: 40
                        color: mixer.ink
                        Accessible.name: "Custom curve name"
                        background: Rectangle { radius: 7; color: "#242733"; border.color: curveName.activeFocus ? mixer.accent : "#35ffffff" }
                        onAccepted: if (text.trim()) mixer.audio.saveCurve(mixer.selectedApp, text)
                    }
                    Action {
                        objectName: "saveCurve"
                        text: "Save"
                        enabled: curveName.text.trim().length > 0
                        onClicked: mixer.audio.saveCurve(mixer.selectedApp, curveName.text)
                    }
                }
                Choice {
                    objectName: "savedCurves"
                    model: ["Load saved curve…"].concat(mixer.current.saved.map(curve => curve.name))
                    currentIndex: 0
                    Accessible.name: "Saved custom curves for " + mixer.current.name
                    onActivated: {
                        if (currentIndex > 0) mixer.audio.loadCurve(mixer.selectedApp, currentIndex - 1);
                        currentIndex = 0;
                    }
                }
                LabelText { text: "Saved curves last for this preview session."; color: mixer.muted; font.pixelSize: 10 }
            }
        }
    }
}
