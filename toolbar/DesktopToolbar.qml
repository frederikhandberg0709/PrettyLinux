pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../shared"

Item {
    id: toolbar

    property Item backdrop: null
    property string searchShortcut: ""
    property alias searchButton: searchPill
    property bool wifiOn: true
    property bool bluetoothOn: false
    property int volume: 62
    property int brightness: 75
    property int battery: 82
    readonly property bool compact: width < 650
    readonly property color foreground: "#f1f0fa"
    readonly property color muted: "#b3b7cd"
    readonly property color accent: "#c6b8ff"
    property date now: new Date()

    signal searchRequested()
    signal systemAction(string action)

    function closePanel(): Item {
        const trigger = panel.visible ? panel.trigger : null;
        panel.close();
        return trigger;
    }

    function togglePanel(trigger: Item, content: Component) {
        if (panel.opened && panel.trigger === trigger) {
            panel.close();
            return;
        }
        panel.trigger = trigger;
        panel.body = content;
        panel.open();
    }

    implicitHeight: 34

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: toolbar.now = new Date()
    }

    // Close from the gaps without intercepting clicks on other toolbar pills.
    MouseArea {
        anchors.fill: parent
        enabled: panel.visible
        onClicked: panel.close()
    }

    component Pill: Button {
        id: pill

        property bool selected: panel.visible && panel.trigger === pill
        property real pressScale: down ? 0.95 : 1.0

        height: toolbar.height
        leftPadding: 12
        rightPadding: 12
        topPadding: 0
        bottomPadding: 0
        hoverEnabled: true

        Behavior on pressScale {
            SpringAnimation {
                spring: 4.0
                damping: 0.29
                epsilon: 0.001
            }
        }

        // Scale the visuals together while the button keeps its layout and hit area.
        Binding {
            target: pill.contentItem
            property: "scale"
            value: pill.pressScale
        }

        background: Item {
            scale: pill.pressScale

            GlassSurface {
                anchors.fill: parent
                backdrop: toolbar.backdrop
                sampleOrigin: Qt.point(toolbar.x + pill.x - (toolbar.backdrop?.x ?? 0),
                                       toolbar.y + pill.y - (toolbar.backdrop?.y ?? 0))
                tintOpacity: 0.64
                fallbackOpacity: 0.82
            }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: pill.down ? "#28ffffff" : pill.selected || pill.hovered ? "#15ffffff" : "transparent"
                border.color: pill.visualFocus ? toolbar.accent : "transparent"
            }
        }
    }

    component PillText: Text {
        color: toolbar.foreground
        font.pixelSize: 12
        font.weight: Font.Medium
    }

    Pill {
        id: searchPill

        objectName: "toolbarSearch"
        anchors.left: parent.left
        Accessible.name: "Search applications"
        onClicked: toolbar.searchRequested()

        contentItem: RowLayout {
            spacing: 8

            ToolbarGlyph { symbol: "search"; color: toolbar.accent }
            PillText { text: "Search" }
            KeyCap {
                label: toolbar.searchShortcut
                visible: !toolbar.compact && label.length > 0
                hovered: searchPill.hovered
            }
        }
    }

    Pill {
        id: clockPill

        objectName: "toolbarClock"
        anchors.horizontalCenter: parent.horizontalCenter
        Accessible.name: dateLabel.text + ", " + timeLabel.text + ", Calendar"
        onClicked: toolbar.togglePanel(clockPill, calendarBody)

        contentItem: RowLayout {
            spacing: 8

            ToolbarGlyph { symbol: "calendar"; color: toolbar.muted; visible: !toolbar.compact }
            PillText {
                id: dateLabel

                text: Qt.formatDate(toolbar.now, "ddd, MMM d")
                color: toolbar.muted
            }
            Rectangle {
                implicitWidth: 1
                implicitHeight: 12
                color: "#32ffffff"
            }
            PillText {
                id: timeLabel

                text: Qt.formatTime(toolbar.now, "HH:mm")
            }
        }
    }

    Pill {
        id: controlPill

        objectName: "toolbarControls"
        anchors.right: systemPill.left
        anchors.rightMargin: 8
        Accessible.name: "Control Center, Wi-Fi " + (toolbar.wifiOn ? "on" : "off")
                         + ", volume " + toolbar.volume + "%, battery " + toolbar.battery + "%"
        onClicked: toolbar.togglePanel(controlPill, controlsBody)

        contentItem: RowLayout {
            spacing: 8

            ToolbarGlyph {
                symbol: toolbar.wifiOn ? "wifi" : "wifiOff"
                color: toolbar.wifiOn ? toolbar.foreground : toolbar.muted
            }
            ToolbarGlyph { symbol: toolbar.volume > 0 ? "volume" : "mute" }
            Rectangle {
                implicitWidth: 1
                implicitHeight: 12
                color: "#32ffffff"
            }
            RowLayout {
                spacing: 5
                ToolbarGlyph { symbol: "battery"; size: 18 }
                PillText { text: toolbar.battery + "%" }
            }
        }
    }

    Pill {
        id: systemPill

        objectName: "toolbarSystem"
        anchors.right: parent.right
        width: height
        leftPadding: 0
        rightPadding: 0
        Accessible.name: "System menu"
        onClicked: toolbar.togglePanel(systemPill, systemBody)

        contentItem: Item {
            ToolbarGlyph {
                anchors.centerIn: parent
                symbol: "power"
                size: 17
            }
        }
    }

    Popup {
        id: panel

        objectName: "toolbarPanel"
        property Item trigger: null
        property Component body: null
        readonly property real cornerRadius: 20

        // Anchor to the toolbar instead of the window overlay.
        parent: toolbar
        x: !trigger ? 0 : trigger === clockPill
            ? trigger.x + (trigger.width - width) / 2 : trigger.x + trigger.width - width
        y: toolbar.height + 9 - (1 - opacity) * 8
        width: trigger === systemPill ? 220 : 292
        padding: 14
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
        }

        onClosed: {
            if (!visible)
                body = null;
        }

        background: Item {
            RectangularGlow {
                anchors.fill: parent
                anchors.topMargin: 6
                anchors.bottomMargin: -6
                glowRadius: 18
                cornerRadius: panel.cornerRadius + glowRadius
                color: "#65000000"
            }
            RectangularGlow {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.bottomMargin: -2
                glowRadius: 5
                cornerRadius: panel.cornerRadius + glowRadius
                color: "#70000000"
            }
            GlassSurface {
                anchors.fill: parent
                radius: panel.cornerRadius
                backdrop: toolbar.backdrop
                sampleOrigin: Qt.point(toolbar.x + panel.x - (toolbar.backdrop?.x ?? 0),
                                       toolbar.y + panel.y - (toolbar.backdrop?.y ?? 0))
                tintOpacity: 0.84
                fallbackOpacity: 0.97
            }
        }

        contentItem: Loader { sourceComponent: panel.body }
    }

    component PanelTitle: Text {
        color: toolbar.foreground
        font.pixelSize: 15
        font.weight: Font.DemiBold
        Accessible.role: Accessible.Heading
    }

    component Rule: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: "#24ffffff"
    }

    component MenuButton: Button {
        id: menuButton

        property real rounding: 9
        hoverEnabled: true

        background: Rectangle {
            radius: menuButton.rounding
            color: menuButton.down ? "#32ffffff"
                                   : menuButton.hovered ? "#22ffffff"
                                   : menuButton.highlighted ? "#13ffffff" : "transparent"
            border.color: menuButton.visualFocus ? toolbar.accent : "transparent"
        }
    }

    component ToggleCard: MenuButton {
        id: card

        required property string symbol
        implicitHeight: 50
        highlighted: true
        rounding: 12
        checkable: true
        Accessible.name: text

        contentItem: RowLayout {
            spacing: 8

            Rectangle {
                implicitWidth: 29
                implicitHeight: 29
                radius: width / 2
                color: card.checked ? "#c6b8ff" : "#1affffff"

                ToolbarGlyph {
                    anchors.centerIn: parent
                    symbol: card.symbol
                    color: card.checked ? "#25213b" : toolbar.foreground
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                PillText { text: card.text }
                Text {
                    text: card.checked ? "On" : "Off"
                    color: toolbar.muted
                    font.pixelSize: 11
                }
            }
        }
    }

    component LevelControl: ColumnLayout {
        id: level

        required property string label
        required property string symbol
        required property int value
        signal moved(int value)

        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            ToolbarGlyph { symbol: level.symbol; color: toolbar.muted }
            PillText { text: level.label; Layout.fillWidth: true }
            PillText { text: level.value + "%"; color: toolbar.muted }
        }

        Slider {
            id: slider

            Layout.fillWidth: true
            implicitHeight: 23
            from: 0
            to: 100
            stepSize: 1
            value: level.value
            Accessible.name: level.label
            onMoved: level.moved(value)

            background: Rectangle {
                x: slider.leftPadding
                y: (slider.height - height) / 2
                width: slider.availableWidth
                height: 6
                radius: height / 2
                color: "#33ffffff"

                Rectangle {
                    width: parent.width * slider.visualPosition
                    height: parent.height
                    radius: parent.radius
                    color: toolbar.accent
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: (slider.height - height) / 2
                implicitWidth: 14
                implicitHeight: 14
                radius: width / 2
                color: slider.pressed ? toolbar.accent : "#f5f2ff"
                border.width: 2
                border.color: slider.visualFocus ? "#8a70da" : "transparent"
            }
        }
    }

    Component {
        id: controlsBody

        ColumnLayout {
            spacing: 11

            PanelTitle { text: "Control Center" }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ToggleCard {
                    objectName: "wifiToggle"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    text: "Wi-Fi"
                    symbol: toolbar.wifiOn ? "wifi" : "wifiOff"
                    checked: toolbar.wifiOn
                    onToggled: toolbar.wifiOn = checked
                }
                ToggleCard {
                    objectName: "bluetoothToggle"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    text: "Bluetooth"
                    symbol: "bluetooth"
                    checked: toolbar.bluetoothOn
                    onToggled: toolbar.bluetoothOn = checked
                }
            }

            LevelControl {
                Layout.fillWidth: true
                label: "Volume"
                symbol: toolbar.volume > 0 ? "volume" : "mute"
                value: toolbar.volume
                onMoved: value => toolbar.volume = value
            }
            LevelControl {
                Layout.fillWidth: true
                label: "Brightness"
                symbol: "brightness"
                value: toolbar.brightness
                onMoved: value => toolbar.brightness = value
            }

            Rule {}

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ToolbarGlyph { symbol: "battery"; size: 18; color: toolbar.muted }
                PillText { text: "Battery"; Layout.fillWidth: true }
                PillText { text: toolbar.battery + "% remaining"; color: toolbar.muted }
            }
        }
    }

    Component {
        id: systemBody

        ColumnLayout {
            spacing: 4

            PanelTitle {
                Layout.leftMargin: 7
                Layout.bottomMargin: 5
                text: "System"
            }

            Repeater {
                model: [
                    { label: "Settings", symbol: "settings", action: "settings" },
                    { label: "Lock", symbol: "lock", action: "lock" },
                    { label: "Sleep", symbol: "sleep", action: "sleep" },
                    { divider: true },
                    { label: "Restart", symbol: "restart", action: "restart" },
                    { label: "Shut Down", symbol: "power", action: "shutdown" }
                ]

                delegate: Loader {
                    id: systemEntry

                    required property var modelData
                    Layout.fillWidth: true

                    sourceComponent: modelData.divider ? divider : actionButton

                    Component {
                        id: divider

                        Rectangle {
                            implicitHeight: 1
                            color: "#24ffffff"
                        }
                    }
                    Component {
                        id: actionButton

                        MenuButton {
                            implicitHeight: 32
                            text: systemEntry.modelData.label
                            Accessible.name: text
                            onClicked: {
                                panel.close();
                                toolbar.systemAction(systemEntry.modelData.action);
                            }

                            contentItem: RowLayout {
                                spacing: 9
                                ToolbarGlyph { symbol: systemEntry.modelData.symbol; color: toolbar.muted }
                                PillText { text: systemEntry.modelData.label; Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: calendarBody

        ToolbarCalendar {
            today: toolbar.now
            foreground: toolbar.foreground
            muted: toolbar.muted
            accent: toolbar.accent
        }
    }
}
