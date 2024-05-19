import QtQuick
import QtQuick.Window
import QtMultimedia
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

Window {
    id: mwin
    width: parseInt(settingsDialog.sizeValue) + margins*2
    height: parseInt(settingsDialog.sizeValue) + margins*2
    visible: true
    title: qsTr("Easy Camera")
    color: "#00000000"
    flags: Qt.FramelessWindowHint |
           Qt.WindowStaysOnTopHint

    Material.accent: Material.Cyan

    readonly property real margins: 30
    readonly property bool maximized: mwin.visibility == Window.Maximized
    readonly property bool recording: recorder.recorderState === MediaRecorder.RecordingState

    Settings {
        id: settings
        property alias size: settingsDialog.size
        property alias camera: settingsDialog.camera
        property alias audio: settingsDialog.audio
        property alias windowX: mwin.x
        property alias windowY: mwin.y
        property alias output: settingsDialog.output
    }

    MediaDevices {
        id: mediaDevices
    }

    CaptureSession {
        screenCapture: ScreenCapture {
            id: screenCapture
            active: true
        }
        audioInput: AudioInput {
            device: settingsDialog.audioValue
        }
        recorder: MediaRecorder {
            id: recorder
            outputLocation: "file://" + settingsDialog.output + "/easy_camera-" + (new Date).getTime() + ".mp4"
        }
    }

    CaptureSession {
        camera: Camera {
            cameraDevice: settingsDialog.cameraValue
            whiteBalanceMode: Camera.WhiteBalanceAuto
            exposureMode: Camera.ExposureAuto
            active: true
        }
        videoOutput: videoOutput
    }

    VideoOutput {
        id: videoOutput
        anchors.margins: maximized? 0 : margins
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        visible: false
    }

    Item {
        id: mask
        anchors.fill: videoOutput
        visible: false

        Rectangle {
            width: mwin.maximized? mwin.width : Math.min(mask.width, mask.height)
            height: mwin.maximized? mwin.height : width
            radius: mwin.maximized? 0 : height / 2
            anchors.centerIn: parent
        }
    }

    DropShadow {
        source: mask
        anchors.fill: videoOutput
        radius: 16
        opacity: 0.3 * opacityMask.opacity
        horizontalOffset: 4
        verticalOffset: 4
    }

    OpacityMask {
        id: opacityMask
        anchors.fill: videoOutput
        source: videoOutput
        maskSource: mask

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 300 }
        }
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        cursorShape: pressed? Qt.ClosedHandCursor : Qt.OpenHandCursor
        hoverEnabled: true
        onPressed: {
            moving = false;
            pin = Qt.point(mouseX, mouseY);
        }
        onPositionChanged: {
            if (mwin.maximized || !pressed)
                return;

            const dx = Math.abs(mouseX - pin.x);
            const dy = Math.abs(mouseY - pin.y);
            if (dx + dy < 20 && !moving)
                return;

            moving = true;
            const globalPos = mapToGlobal(mouseX, mouseY);
            mwin.x = globalPos.x - pin.x;
            mwin.y = globalPos.y - pin.y;
        }
        onDoubleClicked: {
            if (mwin.maximized)
                mwin.showNormal()
            else
                mwin.showMaximized()
        }

        property point pin
        property bool moving
    }

    MouseArea {
        width: parent.width
        height: 110
        hoverEnabled: true
        opacity: containsMouse? 1 : 0

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 300 }
        }

        RowLayout {
            anchors.centerIn: parent

            Button {
                text: qsTr("Menu")
                onClicked: menu.open()

                Menu {
                    id: menu
                    Material.theme: Material.Dark

                    MenuItem {
                        text: qsTr("Settings")
                        onClicked: settingsDialog.showNormal()
                    }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr("Exit")
                        onClicked: Qt.exit(0)
                    }
                }
            }

            Button {
                highlighted: true
                text: recording? qsTr("Stop") : qsTr("Record")
                Material.accent: recording? Material.Red : Material.Cyan
                onClicked: {
                    if (recording) {
                        recorder.stop();
                        cursorWindow.close();
                    } else {
                        recorder.record();
                        cursorWindow.showMaximized();
                    }
                }
            }
        }
    }

    SettingsDialog {
        id: settingsDialog
    }

    CursorWindow {
        id: cursorWindow
    }
}
