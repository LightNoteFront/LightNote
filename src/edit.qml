import QtQuick 2.0

Rectangle {

    width: 320
    height: 568

    color: "#F5F5F5"

    Item {

        id: titleItem

        height: 45
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top


        Image {
            id: imageBack
            width: 25
            height: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            source: "img/edit/back.png"
        }

        Rectangle {
            id: rectTitle
            color: "#E4E4E4"
            radius: 8
            height: 25

            anchors.verticalCenter: parent.verticalCenter

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 55
            anchors.rightMargin: 55

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    holderTitle.visible = false
                    inputTitle.focus = true
                }

            }

            TextInput {
                id: inputTitle
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.pixelSize: 12
                selectionColor: "#555555"

            }

            Row {
                id: holderTitle
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.5
                Text {
                    color: "#ffffff"
                    text: "标题"
                    font.pixelSize: 12
                }
            }
        }

        Image {
            id: imageEdit
            width: 25
            height: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            source: "img/edit/edit.png"
        }
    }



}

