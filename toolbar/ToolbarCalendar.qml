pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: calendar

    required property date today
    required property color foreground
    required property color muted
    required property color accent
    property int monthOffset: 0
    readonly property date shownMonth: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)

    spacing: 7

    component MonthButton: Button {
        id: nav

        required property string direction
        implicitWidth: 29
        implicitHeight: 29
        hoverEnabled: true

        background: Rectangle {
            radius: height / 2
            color: nav.down ? "#30ffffff" : nav.hovered ? "#1cffffff" : "transparent"
            border.color: nav.visualFocus ? calendar.accent : "transparent"
        }
        contentItem: Item {
            ToolbarGlyph {
                anchors.centerIn: parent
                symbol: nav.direction
                color: calendar.foreground
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Text {
            Layout.fillWidth: true
            text: Qt.formatDate(calendar.shownMonth, "MMMM yyyy")
            color: calendar.foreground
            font.pixelSize: 15
            font.weight: Font.DemiBold
            Accessible.role: Accessible.Heading
        }

        MonthButton {
            direction: "left"
            Accessible.name: "Previous month"
            onClicked: --calendar.monthOffset
        }
        MonthButton {
            direction: "right"
            Accessible.name: "Next month"
            onClicked: ++calendar.monthOffset
        }
    }

    DayOfWeekRow {
        Layout.fillWidth: true
        implicitHeight: 24
        spacing: 2
        background: null

        delegate: Text {
            required property var model
            text: model.shortName
            color: calendar.muted
            font.pixelSize: 10
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    MonthGrid {
        id: monthGrid

        Layout.fillWidth: true
        implicitHeight: 176
        spacing: 2
        month: calendar.shownMonth.getMonth()
        year: calendar.shownMonth.getFullYear()
        background: null

        delegate: Item {
            id: dayCell

            required property var model
            readonly property bool isToday: model.year === calendar.today.getFullYear()
                                            && model.month === calendar.today.getMonth()
                                            && model.day === calendar.today.getDate()

            Accessible.name: Qt.formatDate(model.date, Locale.LongFormat)
            Accessible.role: Accessible.StaticText

            Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 26
                radius: width / 2
                color: calendar.accent
                visible: dayCell.isToday
            }

            Text {
                anchors.centerIn: parent
                text: dayCell.model.day
                color: dayCell.isToday ? "#25213b"
                     : dayCell.model.month === monthGrid.month ? calendar.foreground : "#777a92"
                font.pixelSize: 12
                font.weight: dayCell.isToday ? Font.DemiBold : Font.Normal
                Accessible.ignored: true
            }
        }
    }
}
