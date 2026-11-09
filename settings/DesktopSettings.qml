import QtCore

Settings {
    location: "file://" + StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/PrettyLinux/desktop.ini"
    category: "PrettyLinux/Desktop"

    property int dockHeight: 76
    property bool magnificationEnabled: true
    property bool independentGaps: false
    property int dockGap: 16
    property int toolbarGap: 16
    property string toolbarStyle: "pills"
    readonly property int effectiveToolbarGap: independentGaps ? toolbarGap : dockGap

    function reset() {
        dockHeight = 76;
        magnificationEnabled = true;
        independentGaps = false;
        dockGap = 16;
        toolbarGap = 16;
        toolbarStyle = "pills";
    }
}
