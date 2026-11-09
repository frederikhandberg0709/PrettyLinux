import QtQuick

QtObject {
    readonly property var entries: [
        { name: "Settings", description: "Customize your desktop", action: "settings",
          keywords: "preferences configuration customize", accent: "#7654ce",
          path: "M 4 6 H 9 M 13 6 H 20 M 4 12 H 14 M 18 12 H 20 M 4 18 H 7 M 11 18 H 20 M 13 6 A 2 2 0 1 1 9 6 A 2 2 0 1 1 13 6 M 18 12 A 2 2 0 1 1 14 12 A 2 2 0 1 1 18 12 M 11 18 A 2 2 0 1 1 7 18 A 2 2 0 1 1 11 18" },
        { name: "Lock", description: "Lock the screen", action: "lock",
          keywords: "screen security session", accent: "#377fed",
          path: "M 7 10 V 7 A 5 5 0 0 1 17 7 V 10 M 6 10 H 18 Q 20 10 20 12 V 19 Q 20 21 18 21 H 6 Q 4 21 4 19 V 12 Q 4 10 6 10 Z M 12 14 V 17" },
        { name: "Sleep", description: "Put the computer to sleep", action: "sleep",
          keywords: "suspend standby power", accent: "#6265b5",
          path: "M 20.5 15 A 9 9 0 1 1 9 3.5 A 9 9 0 0 0 20.5 15 Z" },
        { name: "Restart", description: "Restart the computer", action: "restart",
          keywords: "reboot power", accent: "#258752",
          path: "M 20 4 V 9 H 15 M 20 9 A 8.5 8.5 0 1 0 20 15" },
        { name: "Shut down", description: "Turn off the computer", action: "shutdown",
          keywords: "shutdown power off halt", accent: "#be5266",
          path: "M 12 3 V 12 M 7 5.5 A 8.5 8.5 0 1 0 17 5.5" }
    ]
}
