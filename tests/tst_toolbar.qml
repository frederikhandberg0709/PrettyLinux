pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import "../toolbar"

Item {
    width: 800
    height: 440

    DesktopToolbar {
        id: toolbar
        x: 16
        y: 16
        width: 768
    }

    TestCase {
        name: "ToolbarTooltips"
        when: windowShown

        function test_percentageEditing_data() {
            return [
                { tag: "volume", label: "volume", property: "volume" },
                { tag: "display", label: "display", property: "brightness" },
                { tag: "keyboard", label: "keyboard", property: "keyboardBrightness" }
            ];
        }

        function test_percentageEditing(data) {
            mouseClick(findChild(toolbar, "toolbarControls"));
            const panel = findChild(toolbar, "toolbarPanel");
            tryCompare(panel, "opened", true);
            const field = findChild(toolbar, data.label + "Percentage");
            const pointer = findChild(field, data.label + "PercentagePointer");
            const original = toolbar[data.property];
            mouseMove(field, field.width / 2, field.height / 2);
            tryCompare(field, "hovered", true);
            compare(pointer.cursorShape, Qt.PointingHandCursor);
            mouseClick(field);
            verify(field.editing);
            compare(pointer.cursorShape, Qt.IBeamCursor);
            compare(pointer.acceptedButtons, Qt.NoButton);
            mouseMove(field, field.width / 2, field.height / 2);
            tryCompare(pointer, "containsMouse", true);
            compare(field.selectedText, String(original));
            keyClick(Qt.Key_4);
            keyClick(Qt.Key_2);
            compare(toolbar[data.property], original);
            keyClick(Qt.Key_Return);
            compare(toolbar[data.property], 42);
            compare(field.text, "42%");
            verify(field.readOnly);
            compare(pointer.cursorShape, Qt.PointingHandCursor);

            mouseClick(field);
            keyClick(Qt.Key_Backspace);
            keyClick(Qt.Key_Return);
            verify(field.editing);
            compare(toolbar[data.property], 42);
            keyClick(Qt.Key_Escape);
            compare(field.text, "42%");
            verify(panel.opened);

            mouseClick(field);
            keyClick(Qt.Key_9);
            const other = findChild(toolbar, data.label === "display" ? "volumePercentage" : "displayPercentage");
            mouseClick(other);
            verify(!field.editing);
            compare(toolbar[data.property], 42);
            mouseClick(field);
            keyClick(Qt.Key_1);
            wait(0);
            const singleDigitWidth = field.width;
            keyClick(Qt.Key_5);
            keyClick(Qt.Key_0);
            tryVerify(() => field.width > singleDigitWidth);
            compare(field.text, "150");
            compare(toolbar[data.property], 42);
            keyClick(Qt.Key_Return);
            compare(toolbar[data.property], 100);
            compare(field.text, "100%");
            panel.close();
            tryCompare(panel, "visible", false);
            toolbar[data.property] = original;
        }

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
