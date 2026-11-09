pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../audio"

Item {
    id: settings
    required property DesktopSettings preferences
    required property AudioState audio
    property int page: 0
    signal pageRequested(int page)

    ColumnLayout {
        anchors.fill: parent
        spacing: 14
        RowLayout {
            spacing: 6
            Repeater {
                model: ["Desktop", "Sound"]
                delegate: Button {
                    id: tab
                    required property int index
                    required property string modelData
                    objectName: index === 0 ? "desktopSettingsTab" : "soundSettingsTab"
                    text: modelData
                    checked: settings.page === index
                    onClicked: settings.pageRequested(index)
                    palette.buttonText: checked ? "#1d192d" : "#f1f0fa"
                    background: Rectangle {
                        radius: 8
                        color: tab.checked ? "#c6b8ff" : tab.hovered ? "#444657" : "#343646"
                        border.color: tab.visualFocus ? "white" : "transparent"
                    }
                }
            }
        }
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: settings.page
            DesktopPreferencesContent { preferences: settings.preferences }
            MixerContent { objectName: "mixerContent"; audio: settings.audio }
        }
    }
}
