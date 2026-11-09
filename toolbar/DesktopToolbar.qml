pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../shared"

Item {
    id: toolbar

    property Item backdrop: null
    property bool menuBar: false
    property alias searchButton: searchPill
    property bool wifiOn: true
    property bool bluetoothOn: false
    property int volume: 62
    property int brightness: 75
    property int keyboardBrightness: 50
    property int battery: 82
    readonly property bool compact: width < 650
    readonly property color foreground: "#f1f0fa"
    readonly property color muted: "#b3b7cd"
    readonly property color accent: "#c6b8ff"
    property date now: new Date()

    signal searchRequested()
    signal windowsRequested()
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

    implicitHeight: menuBar ? 30 : 34
    onMenuBarChanged: panel.close()

    GlassSurface {
        anchors.fill: parent
        visible: toolbar.menuBar
        radius: 0
        borderWidth: 0
        backdrop: toolbar.backdrop
        sampleOrigin: Qt.point(toolbar.x - (toolbar.backdrop?.x ?? 0),
                               toolbar.y - (toolbar.backdrop?.y ?? 0))
        tintOpacity: 0.64
        fallbackOpacity: 0.82

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.rgba(1, 1, 1, 0.18)
        }
    }

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
        width: implicitWidth
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
                visible: !toolbar.menuBar
                backdrop: toolbar.backdrop
                sampleOrigin: Qt.point(toolbar.x + pill.x - (toolbar.backdrop?.x ?? 0),
                                       toolbar.y + pill.y - (toolbar.backdrop?.y ?? 0))
                tintOpacity: 0.64
                fallbackOpacity: 0.82
            }

            Rectangle {
                anchors.fill: parent
                radius: toolbar.menuBar ? 5 : height / 2
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
        x: toolbar.menuBar ? systemPill.x + systemPill.width + 4 : 0
        width: height
        leftPadding: 0
        rightPadding: 0
        Accessible.name: "Search applications"
        onClicked: toolbar.searchRequested()

        contentItem: Item {
            ToolbarGlyph {
                anchors.centerIn: parent
                symbol: "search"
            }
        }
    }

    Pill {
        id: windowsPill
        objectName: "toolbarWindows"
        x: searchPill.x + searchPill.width + (toolbar.menuBar ? 2 : 8)
        width: height
        Accessible.name: "Switch windows"
        onClicked: toolbar.windowsRequested()
        contentItem: PillText {
            text: "▣"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Pill {
        id: clockPill

        objectName: "toolbarClock"
        x: toolbar.menuBar ? toolbar.width - width - 12 : (toolbar.width - width) / 2
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
        x: (toolbar.menuBar ? clockPill.x - 2 : systemPill.x - 8) - width
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
        x: toolbar.menuBar ? 8 : toolbar.width - width
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

    component HoverTooltip: GlassSurface {
        id: tooltip
        required property Button trigger
        required property string label

        x: Math.max(4 - toolbar.x, Math.min(toolbar.width + toolbar.x - width - 4,
                                          trigger.x + (trigger.width - width) / 2))
        y: toolbar.height + 4 + 4 * opacity
        z: 10
        width: tooltipLabel.implicitWidth + 20
        height: tooltipLabel.implicitHeight + 10
        backdrop: toolbar.backdrop
        sampleOrigin: Qt.point(toolbar.x + x - (toolbar.backdrop?.x ?? 0),
                               toolbar.y + y - (toolbar.backdrop?.y ?? 0))
        tintOpacity: 0.60
        fallbackOpacity: 0.94
        opacity: trigger.hovered && trigger.enabled && !trigger.down && !panel.visible ? 1 : 0
        visible: opacity > 0
        Accessible.ignored: true

        Behavior on opacity {
            NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
        }

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            text: tooltip.label
            textFormat: Text.PlainText
            color: "#f5f8ff"
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    HoverTooltip {
        objectName: "searchTooltip"
        trigger: searchPill
        label: "Search"
    }

    HoverTooltip {
        objectName: "windowsTooltip"
        trigger: windowsPill
        label: "Switch windows"
    }

    Popup {
        id: panel

        objectName: "toolbarPanel"
        property Item trigger: null
        property Component body: null
        readonly property real cornerRadius: 20

        // Anchor to the toolbar instead of the window overlay.
        parent: toolbar
        x: Math.max(8, Math.min(toolbar.width - width - 8,
            !trigger ? 0 : trigger === clockPill
                ? trigger.x + (trigger.width - width) / 2 : trigger.x + trigger.width - width))
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

            property real animatedPosition: visualPosition
            readonly property real displayedPosition: sliderPointer.dragging
                ? visualPosition : animatedPosition

            Behavior on animatedPosition {
                enabled: sliderPointer.active && !sliderPointer.dragging
                SmoothedAnimation { duration: 120; velocity: -1 }
            }

            // Observe the gesture without taking the Slider's pointer grab.
            PointHandler {
                id: sliderPointer

                property bool dragging: false
                acceptedButtons: Qt.LeftButton
                onActiveChanged: dragging = false
                onPointChanged: {
                    if (active && Math.abs(point.position.x - point.pressPosition.x) > 1)
                        dragging = true;
                }
            }

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
                    width: parent.width * slider.displayedPosition
                    height: parent.height
                    radius: parent.radius
                    color: toolbar.accent
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.displayedPosition * (slider.availableWidth - width)
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
            LevelControl {
                Layout.fillWidth: true
                label: "Keyboard Brightness"
                symbol: "keyboardBrightness"
                value: toolbar.keyboardBrightness
                onMoved: value => toolbar.keyboardBrightness = value
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
