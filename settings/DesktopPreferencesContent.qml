pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ScrollView {
    id: settings

    required property DesktopSettings preferences
    clip: true
    contentWidth: availableWidth
    palette.window: "#20232e"
    palette.windowText: "#f1f0fa"
    palette.text: "#f1f0fa"
    palette.buttonText: "#f1f0fa"
    palette.button: "#343646"
    palette.base: "#181b24"
    palette.mid: "#55566d"
    palette.highlight: "#b8a2ef"
    palette.highlightedText: "#171521"
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.vertical.active: true

    component Heading: Label {
        Layout.fillWidth: true
        color: "#f1f0fa"
        font.pixelSize: 17
        font.weight: Font.DemiBold
    }

    component Hint: Label {
        Layout.fillWidth: true
        color: "#aeb5cc"
        font.pixelSize: 12
        wrapMode: Text.WordWrap
    }

    component ValueSlider: ColumnLayout {
        id: control
        required property string label
        property alias value: slider.value
        property alias from: slider.from
        property alias to: slider.to
        signal moved(int value)
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            Label { text: control.label; Layout.fillWidth: true; color: "#e1e2ef"; font.pixelSize: 13 }
            Label { text: Math.round(slider.value) + " px"; color: "#c6b8ff"; font.pixelSize: 13 }
        }
        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 64
            stepSize: 1
            live: true
            Accessible.name: control.label
            onMoved: control.moved(Math.round(value))

            background: Rectangle {
                x: slider.leftPadding
                y: (slider.height - height) / 2
                width: slider.availableWidth
                height: 4
                radius: 2
                color: "#444657"
                Rectangle {
                    width: parent.width * slider.visualPosition
                    height: parent.height
                    radius: 2
                    color: "#c6b8ff"
                }
            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: (slider.height - height) / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: slider.pressed ? "#c6b8ff" : "#f1f0fa"
                border.width: slider.visualFocus ? 2 : 0
                border.color: "#8a70da"
            }
        }
    }

    component SettingSwitch: Switch {
        id: toggle
        Layout.fillWidth: true
        indicator: Rectangle {
            x: toggle.leftPadding
            y: (toggle.height - height) / 2
            implicitWidth: 36
            implicitHeight: 22
            radius: 11
            color: toggle.checked ? "#b8a2ef" : "#444657"
            border.width: toggle.visualFocus ? 2 : 0
            border.color: "#f1f0fa"
            Rectangle {
                x: toggle.checked ? parent.width - width - 3 : 3
                y: 3
                width: 16
                height: 16
                radius: 8
                color: toggle.checked ? "#282237" : "#e1e2ef"
                Behavior on x { NumberAnimation { duration: 120 } }
            }
        }
    }

    component ToolbarOption: RadioButton {
        id: option
        required property string styleValue
        checked: settings.preferences.toolbarStyle === styleValue
        onClicked: settings.preferences.toolbarStyle = styleValue
        implicitHeight: 34
        leftPadding: 14
        rightPadding: 14
        hoverEnabled: true
        indicator: null
        contentItem: Text {
            text: option.text
            font.pixelSize: 13
            color: option.checked ? "#171521" : "#e1e2ef"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 7
            color: option.checked ? "#b8a2ef" : option.hovered ? "#444657" : "#343646"
            border.width: option.visualFocus ? 1 : 0
            border.color: "#f1f0fa"
        }
    }

    ColumnLayout {
        width: settings.availableWidth
        spacing: 12

        Heading { text: "Toolbar" }
        RowLayout {
            spacing: 4
            ToolbarOption {
                objectName: "floatingPillsOption"
                text: "Floating Pills"
                styleValue: "pills"
            }
            ToolbarOption {
                objectName: "menuBarOption"
                text: "Menu Bar"
                styleValue: "menuBar"
            }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#24ffffff" }
        Heading { text: "Dock" }
        ValueSlider {
            objectName: "dockHeightControl"
            Layout.fillWidth: true
            label: "Dock height"
            from: 56
            to: 100
            value: settings.preferences.dockHeight
            onMoved: value => settings.preferences.dockHeight = value
        }
        SettingSwitch {
            objectName: "magnificationToggle"
            Layout.fillWidth: true
            text: "Magnify apps on hover"
            checked: settings.preferences.magnificationEnabled
            onToggled: settings.preferences.magnificationEnabled = checked
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#24ffffff" }
        Heading { text: "Edge spacing" }
        Hint {
            text: settings.preferences.toolbarStyle === "menuBar"
                ? "The menu bar sits flush with the top edge. The toolbar gap is saved for Floating Pills."
                : "Distance from the toolbar to the top edge and the dock to the bottom edge."
        }
        SettingSwitch {
            objectName: "independentGapsToggle"
            Layout.fillWidth: true
            text: "Adjust gaps independently"
            checked: settings.preferences.independentGaps
            onToggled: settings.preferences.independentGaps = checked
        }
        ValueSlider {
            objectName: "dockGapControl"
            Layout.fillWidth: true
            label: settings.preferences.independentGaps || settings.preferences.toolbarStyle === "menuBar"
                ? "Dock · bottom gap" : "Toolbar & dock gap"
            value: settings.preferences.dockGap
            onMoved: value => settings.preferences.dockGap = value
        }
        ValueSlider {
            objectName: "toolbarGapControl"
            Layout.fillWidth: true
            visible: settings.preferences.independentGaps && settings.preferences.toolbarStyle !== "menuBar"
            label: "Toolbar · top gap"
            value: settings.preferences.toolbarGap
            onMoved: value => settings.preferences.toolbarGap = value
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Hint { text: "Changes apply and save automatically." }
            Button {
                text: "Reset defaults"
                onClicked: settings.preferences.reset()
            }
        }
    }
}
