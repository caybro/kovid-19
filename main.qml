import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    width: 640
    height: 480
    visible: true

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.4
        height: window.height

        ColumnLayout {
            anchors.fill: parent

            ItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Infected prevalence")
                onClicked: {
                    stackView.push("Infected.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Cumulative statistics")
                onClicked: {
                    stackView.push("Cumulative.qml")
                    drawer.close()
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Settings {
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }

    StackView {
        id: stackView
        initialItem: Intro {}
        anchors.fill: parent
    }
}
