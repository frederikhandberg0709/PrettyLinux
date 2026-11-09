pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../shared"

Item {
    id: launcher

    required property var applications
    // Optional sibling item to sample in the standalone preview.
    property Item backdrop: null
    property bool opened: false
    property real topInset: 0
    readonly property var results: matchApps(search.text)
    property int selectedIndex: 0

    signal dismissed()
    signal launched(var appData)

    visible: opened || panel.opacity > 0
    enabled: opened

    onOpenedChanged: {
        if (opened) {
            search.clear();
            selectedIndex = results.length ? 0 : -1;
            list.positionViewAtBeginning();
            search.forceActiveFocus(Qt.ShortcutFocusReason);
        }
    }

    onResultsChanged: {
        search.activationKey = 0;
        selectedIndex = results.length ? 0 : -1;
        list.positionViewAtBeginning();
    }

    function matchApps(query: string): var {
        const normalized = query.trim().toLowerCase();
        if (!normalized)
            return applications;

        const terms = normalized.split(/\s+/);
        const matches = [];
        for (let i = 0; i < applications.length; ++i) {
            const app = applications[i];
            const name = app.name.toLowerCase();
            const aliases = (app.keywords || "").toLowerCase().split(/\s+/);
            let score = 0;
            for (const term of terms) {
                if (name === term)
                    score += 100;
                else if (name.startsWith(term))
                    score += 80;
                else if (name.includes(term))
                    score += 60;
                else if (aliases.includes(term))
                    score += 50;
                else if (aliases.some(alias => alias.startsWith(term)))
                    score += 35;
                else {
                    // Match abbreviations such as "trm" against app names.
                    let letter = 0;
                    for (let j = 0; j < name.length && letter < term.length; ++j) {
                        if (name[j] === term[letter])
                            ++letter;
                    }
                    if (letter !== term.length) {
                        score = -1;
                        break;
                    }
                    score += 15;
                }
            }
            if (score >= 0)
                matches.push({ app: app, score: score, order: i });
        }

        matches.sort((a, b) => b.score - a.score || a.order - b.order);
        return matches.map(match => match.app);
    }

    function moveSelection(delta: int) {
        const count = results.length;
        if (!count)
            return;
        search.activationKey = 0;
        selectedIndex = (selectedIndex + delta + count) % count;
    }

    function activate(index: int) {
        if (!opened || index < 0 || index >= results.length)
            return;

        const app = results[index];
        dismissed();
        launched(app);
    }

    Rectangle {
        anchors.fill: parent
        color: "#0c0d17"
        opacity: panel.opacity * 0.45
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                launcher.dismissed();
        }
        onWheel: wheel => { wheel.accepted = true; }
    }

    Item {
        id: panel

        readonly property real radius: 22
        readonly property real topMargin: Math.max(launcher.topInset, 16, Math.min(52, launcher.height * 0.085))
        readonly property real centeredX: (launcher.width - width) / 2
        property real horizontalOffset: 0
        property real verticalOffset: 0

        x: Math.max(16, Math.min(launcher.width - width - 16, centeredX + horizontalOffset))
        y: Math.max(topMargin, Math.min(launcher.height - height - 16,
                                       topMargin + verticalOffset)) - (1 - opacity) * 8
        width: Math.min(600, launcher.width - 32)
        height: Math.min(444, launcher.height - topMargin - 16)
        opacity: launcher.opened ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        RectangularGlow {
            anchors.fill: parent
            anchors.topMargin: 12
            anchors.bottomMargin: -12
            cornerRadius: panel.radius + glowRadius
            glowRadius: 32
            color: "#66000000"
        }

        RectangularGlow {
            anchors.fill: parent
            anchors.topMargin: 3
            anchors.bottomMargin: -3
            cornerRadius: panel.radius + glowRadius
            glowRadius: 9
            color: "#70000000"
        }

        GlassSurface {
            anchors.fill: parent
            radius: panel.radius
            backdrop: launcher.backdrop
            sampleOrigin: Qt.point(launcher.x + panel.x - (launcher.backdrop?.x ?? 0),
                                   launcher.y + panel.y - (launcher.backdrop?.y ?? 0))
            tintOpacity: 0.80
            fallbackOpacity: 0.96
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        // Empty header space and the section heading act as a drag handle.
        // The input and close button above this area keep their usual gestures.
        MouseArea {
            id: panelDrag

            property point pressPosition
            property point startPosition
            property bool centerSnapped: false
            property bool moving: false

            anchors.left: parent.left
            anchors.right: parent.right
            height: header.height + resultHeading.height
            cursorShape: moving ? Qt.ClosedHandCursor : Qt.ArrowCursor
            preventStealing: true

            onPressed: mouse => {
                moving = false;
                pressPosition = mapToItem(launcher, mouse.x, mouse.y);
                startPosition = Qt.point(panel.x, panel.y);
                centerSnapped = Math.abs(panel.x - panel.centeredX) < 1;
            }
            onPositionChanged: mouse => {
                if (!pressed)
                    return;

                const position = mapToItem(launcher, mouse.x, mouse.y);
                const rawX = startPosition.x + position.x - pressPosition.x;
                const rawY = startPosition.y + position.y - pressPosition.y;
                const distance = Math.abs(rawX - panel.centeredX);
                // A wider release threshold avoids jitter at the snap boundary.
                centerSnapped = distance <= (centerSnapped ? 24 : 14);
                const clampedX = Math.max(16, Math.min(launcher.width - panel.width - 16, rawX));
                panel.horizontalOffset = centerSnapped ? 0 : clampedX - panel.centeredX;
                panel.verticalOffset = Math.max(panel.topMargin,
                    Math.min(launcher.height - panel.height - 16, rawY)) - panel.topMargin;
                if (panel.x !== startPosition.x || panel.y !== startPosition.y)
                    moving = true;
            }
            onReleased: {
                moving = false;
                search.forceActiveFocus(Qt.MouseFocusReason);
            }
            onCanceled: moving = false
        }

        Item {
            id: header

            anchors.left: parent.left
            anchors.right: parent.right
            height: 66

            SearchGlyph {
                id: magnifier

                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                color: "#c6b8ff"
            }

            TextInput {
                id: search

                property int activationKey: 0

                objectName: "launcherSearch"
                anchors.left: magnifier.right
                anchors.leftMargin: 14
                anchors.right: closeButton.left
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                selectByMouse: true
                color: "#f7f6ff"
                selectionColor: "#7057b4"
                selectedTextColor: "#ffffff"
                font.pixelSize: 21
                Accessible.name: "Search applications"

                onActiveFocusChanged: {
                    if (!activeFocus)
                        activationKey = 0;
                }

                Keys.onPressed: event => {
                    if (inputMethodComposing)
                        return;

                    switch (event.key) {
                    case Qt.Key_Down:
                    case Qt.Key_Tab:
                        launcher.moveSelection(1);
                        break;
                    case Qt.Key_Up:
                    case Qt.Key_Backtab:
                        launcher.moveSelection(-1);
                        break;
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        if (!event.isAutoRepeat && launcher.selectedIndex >= 0)
                            activationKey = event.key;
                        break;
                    case Qt.Key_Escape:
                        launcher.dismissed();
                        break;
                    default:
                        return;
                    }
                    event.accepted = true;
                }

                Keys.onReleased: event => {
                    if (event.key !== activationKey)
                        return;
                    event.accepted = true;
                    if (!event.isAutoRepeat) {
                        activationKey = 0;
                        launcher.activate(launcher.selectedIndex);
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.displayText.length === 0
                    text: "Search applications…"
                    color: "#a8adbf"
                    font: search.font
                    Accessible.ignored: true
                }
            }

            Button {
                id: closeButton

                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                width: 42
                height: 32
                focusPolicy: Qt.NoFocus
                Accessible.name: "Close launcher"
                onClicked: launcher.dismissed()

                contentItem: Item {
                    KeyCap {
                        anchors.centerIn: parent
                        label: "Esc"
                        hovered: closeButton.hovered
                    }
                }
                background: null
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#19ffffff"
            }
        }

        Item {
            id: resultHeading

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            height: 33

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                text: "APPLICATIONS"
                color: "#b7bbd0"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.5
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                text: launcher.results.length === 1 ? "1 app" : launcher.results.length + " apps"
                color: "#a3a9bd"
                font.pixelSize: 11
            }
        }

        ListView {
            id: list

            property Item hoveredRow: null
            property Item pressedRow: null

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: resultHeading.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 11
            anchors.rightMargin: 11
            anchors.bottomMargin: 12
            clip: true
            // Keep the icon glyphs inside the viewport during software scrolling.
            layer.enabled: interactive && GraphicsInfo.api === GraphicsInfo.Software
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            keyNavigationEnabled: false
            currentIndex: launcher.selectedIndex
            model: launcher.results
            highlightMoveDuration: 150
            highlightMoveVelocity: -1
            highlightResizeDuration: 0
            highlightResizeVelocity: -1

            highlight: Item {
                Rectangle {
                    id: selection

                    readonly property bool pressed: search.activationKey !== 0
                                                    || (list.pressedRow !== null
                                                        && list.pressedRow === list.currentItem)
                    readonly property bool hovered: list.hoveredRow !== null
                                                    && list.hoveredRow === list.currentItem

                    anchors.fill: parent
                    anchors.bottomMargin: 3
                    radius: 9
                    color: pressed ? "#779b7cf3"
                                   : hovered ? "#385d49a8" : "#417f69d3"
                    border.color: pressed ? "#a4b19af8"
                                          : hovered ? "#587262b5" : "#628c79d8"

                    Behavior on color {
                        ColorAnimation { duration: selection.pressed ? 45 : 100 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: selection.pressed ? 45 : 100 }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Item {
                id: entry

                required property int index
                required property var modelData
                readonly property bool selected: index === launcher.selectedIndex
                readonly property bool pressed: rowTap.pressed

                width: list.width - (list.interactive ? 9 : 0)
                height: 43
                Accessible.role: Accessible.Button
                Accessible.name: modelData.name
                Accessible.description: modelData.description
                Accessible.selected: selected
                Accessible.onPressAction: launcher.activate(index)

                Rectangle {
                    anchors.fill: parent
                    anchors.bottomMargin: 3
                    radius: 9
                    color: "white"
                    opacity: entry.selected ? 0
                                            : entry.pressed ? 42 / 255
                                                            : rowHover.hovered ? 19 / 255 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: entry.pressed ? 70 : 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                AppTile {
                    id: icon

                    anchors.left: parent.left
                    anchors.leftMargin: 11
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1.5
                    width: 28
                    height: width
                    appData: entry.modelData
                }

                Column {
                    anchors.left: icon.right
                    anchors.leftMargin: 11
                    anchors.right: status.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: icon.verticalCenter
                    spacing: 1

                    Text {
                        width: parent.width
                        text: entry.modelData.name
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: "#f6f6ff"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        Accessible.ignored: true
                    }

                    Text {
                        width: parent.width
                        text: entry.modelData.description || ""
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: "#b7bad0"
                        font.pixelSize: 11
                        Accessible.ignored: true
                    }
                }

                Row {
                    id: status

                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: icon.verticalCenter
                    spacing: 6
                    visible: !!entry.modelData.running

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 5
                        height: width
                        radius: width / 2
                        color: "#91dfb6"
                    }

                    Text {
                        text: "Running"
                        color: "#bdc7d4"
                        font.pixelSize: 11
                    }
                }

                HoverHandler {
                    id: rowHover

                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: {
                        if (hovered)
                            list.hoveredRow = entry;
                        else if (list.hoveredRow === entry)
                            list.hoveredRow = null;
                    }
                }

                TapHandler {
                    id: rowTap

                    onPressedChanged: {
                        if (pressed)
                            list.pressedRow = entry;
                        else if (list.pressedRow === entry)
                            list.pressedRow = null;
                    }
                    onTapped: launcher.activate(entry.index)
                }
            }
        }

        Column {
            anchors.horizontalCenter: list.horizontalCenter
            anchors.verticalCenter: list.verticalCenter
            spacing: 5
            visible: launcher.results.length === 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No matching apps"
                color: "#f0eff9"
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Try a different name or keyword."
                color: "#b7bbd0"
                font.pixelSize: 12
            }
        }

    }
}
