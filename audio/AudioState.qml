pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: audio
    property int editingApp: 0

    property int outputVolume: 62
    property int inputVolume: 75
    property bool outputMuted: false
    property bool inputMuted: false
    property int outputDevice: 0
    property int inputDevice: 0
    readonly property var outputs: ["Built-in speakers", "USB headphones", "HDMI / DisplayPort"]
    readonly property var inputs: ["Built-in microphone", "USB microphone"]
    readonly property var frequencies: ["32", "64", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]
    readonly property var presetNames: ["Flat", "Bass boost", "Voice", "Bright", "Custom"]
    readonly property var curves: [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
        [-4, -3, -2, 0, 2, 4, 4, 2, 0, -2],
        [0, 0, 0, 0, 0, 1, 2, 3, 4, 5]
    ]
    // App identities are independent of window instances. These are mock audio sessions.
    property var apps: [
        { name: "Music", accent: "#ca4368", volume: 80, muted: false, output: 0,
          eqEnabled: true, preset: 0, gains: [0,0,0,0,0,0,0,0,0,0], preamp: 0, saved: [] },
        { name: "Browser", accent: "#158eab", volume: 65, muted: false, output: 0,
          eqEnabled: false, preset: 0, gains: [0,0,0,0,0,0,0,0,0,0], preamp: 0, saved: [] },
        { name: "Messages", accent: "#258752", volume: 50, muted: false, output: 0,
          eqEnabled: false, preset: 0, gains: [0,0,0,0,0,0,0,0,0,0], preamp: 0, saved: [] }
    ]

    function updateApp(index: int, key: string, value: var) {
        const copy = apps.slice();
        copy[index] = Object.assign({}, copy[index]);
        copy[index][key] = value;
        apps = copy;
    }

    function setBand(appIndex: int, band: int, gain: real) {
        const gains = apps[appIndex].gains.slice();
        gains[band] = Math.max(-12, Math.min(12, Math.round(gain)));
        updateApp(appIndex, "gains", gains);
        updateApp(appIndex, "preset", 4);
    }

    function applyPreset(index: int, preset: int) {
        if (preset < 0 || preset >= curves.length)
            return;
        updateApp(index, "gains", curves[preset].slice());
        updateApp(index, "preamp", preset === 0 ? 0 : -6);
        updateApp(index, "preset", preset);
    }

    function saveCurve(index: int, name: string) {
        const label = name.trim();
        if (!label)
            return;
        const saved = apps[index].saved.filter(curve => curve.name !== label);
        saved.push({ name: label, gains: apps[index].gains.slice(), preamp: apps[index].preamp });
        updateApp(index, "saved", saved);
    }

    function loadCurve(index: int, curveIndex: int) {
        const curve = apps[index].saved[curveIndex];
        if (!curve)
            return;
        updateApp(index, "gains", curve.gains.slice());
        updateApp(index, "preamp", curve.preamp);
        updateApp(index, "preset", 4);
    }
}
