import QtQuick 2.4
import QtQuick.Window 2.2

Window {
    id: mainWindow
    visible: true
    width: 320
    height: 568

    Grid {
        id: grid1
        anchors.fill: parent

        Image {
            id: background
            anchors.fill: parent
            source: "source/home/background.png"
        }

        ListView {
            id: cardList
            anchors.top: parent.top
            anchors.topMargin: 56
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            delegate: Item {
                width: 320
                height: fs * 2
                Row {
                    id: mainCard
                    Image {
                        width: 320
                        height: 480
                        visible: true
                        source: "source/home/card.png"
                        Text {
                            font.pixelSize: fs
                            text: name
                        }
                    }

                }
            }
            model: ListModel {
                ListElement {
                    name: "card1"
                    fs: 12
                }

                ListElement {
                    name: "card2"
                    fs: 24
                }

                ListElement {
                    name: "card3"
                    fs: 38
                }

                ListElement {
                    name: "card4"
                    fs: 438
                }
            }
        }

        Rectangle {
            id: title
            color: "#262626"
            opacity: 1
            anchors.bottom: cardList.top
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Image {
                id: menu
                width: 26
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.top: parent.top
                anchors.topMargin: 15
                source: "source/home/menu.png"
            }

            Image {
                id: addNote
                width: 26
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.right: parent.right
                anchors.rightMargin: 15
                source: "source/icon/add.png"
            }

            Rectangle {
                id: searchRec
                color: "#747575"
                radius: 8
                anchors.right: parent.right
                anchors.rightMargin: 71
                anchors.left: parent.left
                anchors.leftMargin: 71
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.top: parent.top
                anchors.topMargin: 15

                Text {
                    id: text1
                    text: qsTr("Text")
                    //                    style: Text.Center;
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    font.pixelSize: 12
                }

                Row {
                    id: row1
                    opacity: 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Image {
                        id: image1
                        width: 16
                        height: 16
                        source: "source/home/search.png"
                    }

                    Text {
                        id: text2
                        color: "#ffffff"
                        text: qsTr("搜索")
                        font.pixelSize: 12
                    }
                }
            }
        }

    }
}

