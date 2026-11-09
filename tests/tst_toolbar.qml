pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import "../toolbar"

Item {
    width: 800
    height: 240

    DesktopToolbar {
        id: toolbar
        x: 16
        y: 16
        width: 768
    }

    TestCase {
        name: "ToolbarTooltips"
        when: windowShown

        function test_hover_data() {
            return [{ tag: "pills", menuBar: false }, { tag: "menuBar", menuBar: true }];
        }

        function test_hover(data) {
            toolbar.menuBar = data.menuBar;
            const search = findChild(toolbar, "toolbarSearch");
            const windows = findChild(toolbar, "toolbarWindows");
            const searchTip = findChild(toolbar, "searchTooltip");
            const windowsTip = findChild(toolbar, "windowsTooltip");
            compare(search.width, toolbar.height);
            compare(search.Accessible.name, "Search applications");
            mouseMove(search, search.width / 2, search.height / 2);
            tryCompare(searchTip, "opacity", 1);
            compare(searchTip.label, "Search");
            compare(searchTip.radius, searchTip.height / 2);
            verify(searchTip.y > toolbar.height);
            verify(searchTip.x + toolbar.x >= 4);
            mouseMove(windows, windows.width / 2, windows.height / 2);
            tryCompare(windowsTip, "opacity", 1);
            tryCompare(searchTip, "opacity", 0);
            compare(windowsTip.label, "Switch windows");
            mouseMove(toolbar, toolbar.width / 2, 100);
            tryCompare(windowsTip, "opacity", 0);
            tryCompare(windowsTip, "visible", false);
        }
    }
}
