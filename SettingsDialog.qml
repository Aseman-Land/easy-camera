import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import QtQuick.Controls.Material

Window {
    id: settingsDialog
    title: qsTr("Settings")
    width: 400
    height: 300
    flags: Qt.Dialog

    Material.theme: Material.Dark
    Material.background: "#31363b"

    property alias size: sizeCombo.currentIndex
    property alias sizeValue: sizeCombo.currentText

    property alias camera: deviceCombo.currentIndex
    property alias cameraValue: deviceCombo.currentValue

    property alias audio: audioCombo.currentIndex
    property alias audioValue: audioCombo.currentValue

    property alias output: outputLocation.text

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
