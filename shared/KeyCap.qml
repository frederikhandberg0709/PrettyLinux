import QtQuick

Rectangle {
    id: cap

    required property string label
    property bool hovered: false

    implicitWidth: Math.max(22, labelText.implicitWidth + 12)
    implicitHeight: 21
    radius: 5
    color: hovered ? "#25ffffff" : "#0effffff"
    border.color: "#21ffffff"
    Accessible.ignored: true

    Text {
        id: labelText

        anchors.centerIn: parent
        text: cap.label
        color: "#cdd3e5"
        font.pixelSize: 11
        font.weight: Font.Medium
    }
}
