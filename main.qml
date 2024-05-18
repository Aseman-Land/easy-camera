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
    width: parseInt(sizeCombo.currentText) + margins*2
    height: parseInt(sizeCombo.currentText) + margins*2
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
        property alias size: sizeCombo.currentIndex
        property alias camera: deviceCombo.currentIndex
        property alias audio: audioCombo.currentIndex
        property alias windowX: mwin.x
        property alias windowY: mwin.y
        property alias output: outputLocation.text
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
        }
        recorder: MediaRecorder {
            id: recorder
            outputLocation: "file://" + outputLocation.text + "/easy_camera-" + (new Date).getTime() + ".mp4"
        }
    }

    CaptureSession {
        camera: Camera {
            cameraDevice: deviceCombo.currentValue
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
                    if (recording)
                        recorder.stop();
                    else
                        recorder.record();
                }
            }
        }
    }

    Window {
        id: settingsDialog
        title: qsTr("Settings")
        width: 400
        height: 300
        flags: Qt.Dialog

        Material.theme: Material.Dark
        Material.background: "#31363b"

        Page {
            anchors.fill: parent

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 30
                anchors.topMargin: 10

                RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Size")
                        font.bold: true
                    }

                    ComboBox {
                        id: sizeCombo
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        model: [64, 128, 192, 256, 384, 512, 768, 1024]
                        currentIndex: 4
                        displayText: qsTr("%1px").arg(currentText)
                    }
                }

                RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Camera Device")
                        font.bold: true
                    }

                    ComboBox {
                        id: deviceCombo
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        model: mediaDevices.videoInputs
                        textRole: "description"
                    }
                }

                RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Audio Device")
                        font.bold: true
                    }

                    ComboBox {
                        id: audioCombo
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        model: mediaDevices.audioInputs
                        textRole: "description"
                    }
                }

                RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Output")
                        font.bold: true
                    }

                    TextField {
                        id: outputLocation
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 50
                        text: homePath
                    }
                }
            }
        }
    }

}
