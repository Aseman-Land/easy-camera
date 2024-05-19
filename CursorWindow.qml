import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import EasyCamera

Window {
    id: mwin
    title: qsTr("Easy Camera")
    visible: true
    color: "#00000000"
    flags: Qt.FramelessWindowHint |
           Qt.WindowStaysOnTopHint |
           Qt.WindowTransparentForInput

    Image {
        id: cursor
        x: tracker.position.x - 5
        y: tracker.position.y - 5
        width: 32
        height: 32
        source: "cursor.png"
    }

    CursorTracker {
        id: tracker
        running: mwin.visible
    }
}
