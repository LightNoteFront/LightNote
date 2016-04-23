import QtQuick 2.4
import QtQuick.Window 2.2

Window {
    id: mainWindow
    visible: true
    width: 320
    height: 568

    function searchFocus(ths)
    {
        if (ths.id !== searchRec)
        {
            searchContent.focus = false;
            if (searchContent.text === "")
            {
                searchLogo.visible = true;
            }
            else
            {
                searchContent.opacity = 0.5;
            }
        }
    }

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
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    searchFocus(this);
                }
            }

            delegate: Item {
                width: 320
                height: 40
                Row {
                    id: mainCard
                    Image {
                        width: 320
                        height: 480
                        visible: true
                        source: "source/home/card.png"
                    }

                }
            }
            model: ListModel {
                ListElement {
                    name: "card1"
                }

                ListElement {
                    name: "card2"
                }

                ListElement {
                    name: "card3"
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

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    searchFocus(this);
                }
            }
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
                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        searchLogo.visible = false;
                        searchContent.focus = true;
                        searchContent.opacity = 1.0;
                    }
                }

                TextInput {
                    id: searchContent
                    y: 4
                    text: qsTr("")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ffffff"
                    font.pixelSize: 12
                }

                Row {
                    id: searchLogo
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

