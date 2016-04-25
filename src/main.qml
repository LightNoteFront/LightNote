import QtQuick 2.3
import QtQuick.Window 2.2

Window {
    visible: true

    height: 300
    width: 300

    id: win

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Qt.quit();
        }
    }

    Item {
        id: testItem
        anchors.fill: parent
        Loader {
            id: testLoader
            source: "test.qml"
            anchors.fill: parent
        }
        Rectangle {
            width: 20
            height: 20
            color: "black"
            anchors.top: parent.top
            anchors.right: parent.right

            Text {
                anchors.centerIn: parent
                text: "×"
                color: "white"
                font.pixelSize: 18
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    testItem.visible = false;
                }
            }

        }

    }



}

