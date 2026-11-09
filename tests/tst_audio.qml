pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import ".."

Item {
    TestCase {
        name: "VolumeMixer"
        when: windowShown

        function test_mixer() {
            const component = Qt.createComponent("../Preview.qml");
            compare(component.status, Component.Ready, component.errorString());
            const preview = component.createObject(null, {
                locked: false,
                settingsLocation: "file:///private/tmp/pretty-linux-audio-" + Date.now() + ".ini"
            }) as Preview;
            verify(preview !== null);
            const toolbar = findChild(preview, "toolbar");
            const state = findChild(preview, "audioState");
            const store = findChild(preview, "windowStore");
            const panel = findChild(toolbar, "toolbarPanel");
            const trigger = findChild(toolbar, "toolbarSound");
            mouseClick(trigger);
            tryCompare(panel, "opened", true);
            compare(store.entries.count, 4); // Quick controls never create a desktop window.
            let quick = findChild(toolbar, "quickMixer");
            verify(quick !== null);
            const appSlider = findChild(quick, "app0Level");
            appSlider.forceActiveFocus();
            keyClick(Qt.Key_Left);
            compare(state.apps[0].volume, 79);
            compare(state.apps[1].volume, 65);
            compare(findChild(quick, "app0Level"), appSlider);
            mouseClick(findChild(quick, "app0Mute"));
            compare(state.apps[0].muted, true);
            const output = findChild(quick, "outputLevel");
            output.decrease();
            output.moved();
            compare(state.outputVolume, 61);
            compare(toolbar.volume, 61);
            toolbar.volumeMoved(28);
            compare(output.value, 28);
            state.outputMuted = true;
            compare(toolbar.volume, 0);
            state.outputMuted = false;
            compare(toolbar.volume, 28);
            const input = findChild(quick, "inputDevice");
            input.currentIndex = 1;
            input.activated(1);
            compare(state.inputDevice, 1);
            const route = findChild(quick, "appRoute0");
            route.currentIndex = 2;
            route.activated(2);
            compare(state.apps[0].output, 2);
            findChild(quick, "editEq0").clicked();
            compare(quick.expandedApp, 0);
            compare(store.entries.count, 4);
            const preset = findChild(quick, "inlineEqPreset0");
            preset.currentIndex = 1;
            preset.activated(1);
            compare(state.apps[0].gains[0], 6);
            const band = findChild(quick, "inlineBand0_0");
            band.increase();
            band.moved();
            compare(state.apps[0].gains[0], 7);
            compare(state.apps[1].gains[0], 0);
            compare(state.apps[0].preset, 4);
            wait(150);
            let savedImage = false;
            preview.contentItem.grabToImage(result => { savedImage = result.saveToFile("/private/tmp/pretty-linux-quick-mixer.png"); });
            tryVerify(() => savedImage);
            keyClick(Qt.Key_Escape);
            tryCompare(panel, "visible", false);
            mouseClick(trigger);
            tryCompare(panel, "opened", true);
            quick = findChild(toolbar, "quickMixer");
            compare(state.apps[0].gains[0], 7);
            findChild(quick, "editEq0").clicked();
            findChild(quick, "advancedEq0").clicked();
            tryCompare(panel, "visible", false);
            compare(store.entries.count, 5);
            compare(preview.settingsPage, 1);
            const settingsId = store.activeId;
            const source = findChild(preview, "desktop").orderedWindows()[0].source;
            const content = findChild(source, "mixerContent");
            verify(content !== null);
            compare(findChild(content, "eqBand0").value, 7);
            findChild(content, "curveName").text = "My bass";
            findChild(content, "saveCurve").clicked();
            state.applyPreset(0, 0);
            const saved = findChild(content, "savedCurves");
            saved.currentIndex = 1;
            saved.activated(1);
            compare(state.apps[0].gains[0], 7);
            compare(state.apps[0].preamp, -6);
            preview.openSoundSettings(1);
            compare(store.entries.count, 5);
            compare(store.activeId, settingsId);
            compare(content.selectedApp, 1);
            preview.openSettings();
            compare(preview.settingsPage, 0);
            preview.width = 540;
            preview.height = 360;
            mouseClick(trigger);
            tryCompare(panel, "opened", true);
            verify(panel.width <= toolbar.width);
            verify(panel.y + toolbar.y + panel.height <= preview.height);
            savedImage = false;
            preview.contentItem.grabToImage(result => { savedImage = result.saveToFile("/private/tmp/pretty-linux-quick-mixer-compact.png"); });
            tryVerify(() => savedImage);
            mouseClick(preview.contentItem, 5, 300);
            tryCompare(panel, "visible", false);
            preview.destroy();
        }
    }
}
