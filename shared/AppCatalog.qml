import QtQuick

QtObject {
    readonly property var entries: [
        { name: "Files", description: "Browse folders and documents",
          keywords: "folder explorer finder file manager", accent: "#377fed", running: true,
          path: "M 3 8 V 6 Q 3 5 4 5 H 9 L 11 8 H 20 Q 21 8 21 9 V 18 Q 21 19 20 19 H 4 Q 3 19 3 18 Z M 3 11 H 21" },
        { name: "Browser", description: "Browse the web",
          keywords: "web internet firefox chrome safari", accent: "#158eab", running: true,
          path: "M 21 12 A 9 9 0 1 1 3 12 A 9 9 0 1 1 21 12 Z M 16 8 L 13.5 13.5 L 8 16 L 10.5 10.5 Z" },
        { name: "Messages", description: "Chat with your contacts",
          keywords: "chat text sms messenger", accent: "#258752", running: false,
          path: "M 12 4 C 6.8 4 3 7.1 3 11 C 3 13.2 4.3 15.1 6.3 16.3 L 5 20 L 9.5 17.8 C 10.3 18 11.1 18 12 18 C 17.2 18 21 15 21 11 C 21 7.1 17.2 4 12 4 Z M 8 11 H 8.2 M 11.9 11 H 12.1 M 15.8 11 H 16" },
        { name: "Notes", description: "Write and organize notes",
          keywords: "memo writing notebook text", accent: "#a66a16", running: false,
          path: "M 7 3 H 16 L 20 7 V 19 Q 20 21 18 21 H 7 Q 5 21 5 19 V 5 Q 5 3 7 3 Z M 15 3 V 8 H 20 M 9 12 H 16 M 9 16 H 15" },
        { name: "Music", description: "Listen to your library",
          keywords: "audio songs player spotify", accent: "#ca4368", running: true,
          path: "M 9 17 V 6 L 19 4 V 15 M 9 17 C 9 18.5 7.6 20 5.5 20 C 4 20 3 19.2 3 18 C 3 16.5 4.4 15.5 6.4 15.5 C 7.9 15.5 9 16.1 9 17 Z M 19 15 C 19 16.5 17.6 18 15.5 18 C 14 18 13 17.2 13 16 C 13 14.5 14.4 13.5 16.4 13.5 C 17.9 13.5 19 14.1 19 15 Z" },
        { name: "Photos", description: "View and organize photos",
          keywords: "images pictures gallery", accent: "#7654ce", running: false,
          path: "M 5 4 H 19 Q 21 4 21 6 V 18 Q 21 20 19 20 H 5 Q 3 20 3 18 V 6 Q 3 4 5 4 Z M 3 16 L 8.5 11 L 13 15 L 16 12.5 L 21 17 M 16.5 8.5 H 16.7" },
        { name: "Terminal", description: "Run commands in a shell",
          keywords: "shell command line cli console", accent: "#36475f", running: true,
          path: "M 5 5 H 19 Q 21 5 21 7 V 17 Q 21 19 19 19 H 5 Q 3 19 3 17 V 7 Q 3 5 5 5 Z M 7 9 L 10 12 L 7 15 M 13 15 H 17" }
    ]
}
