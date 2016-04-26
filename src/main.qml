import QtQuick 2.3
import QtQuick.Window 2.2

Window {
    visible: true

    id: mainWindow
    width: 320
    height: 568

    /*
    onHeightChanged: {
        console.log("height:" + mainWindow.height)
    }

    onWidthChanged: {
        console.log("width:" + mainWindow.width)
    }
    */

    function setSearchFocus(ths)
    {
        if (ths.id !== searchMous)
        {
            searchContent.focus = false
            if (searchContent.text === "")
            {
                searchLogo.visible = true
            }
            else
            {
                searchContent.opacity = 0.5
            }
        }
    }

    Item {
        id: mainItem

        anchors.fill: parent

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: "#262626"
        }

        Item {
            id: titleItem
            anchors.bottom: parent.bottom
            anchors.bottomMargin: mainWindow.height - 45
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            Image {
                id: menuImag
                width: 15
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: 20
                source: "../img/title/menu.png"
            }

            Rectangle {
                id: searchRect
                color: "#747575"
                radius: 8
                anchors.bottomMargin: 10
                anchors.topMargin: 10
                anchors.leftMargin: 55
                anchors.rightMargin: 55
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.top: parent.top

                MouseArea {
                    id: searchMous
                    anchors.fill: parent
                    onClicked: {
                        searchLogo.visible = false
                        searchContent.focus = true
                        searchContent.opacity = 1.0
                    }

                }

                TextInput {
                    id: searchContent
                    //text: //这里可以指定一些网络的热门搜索
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ffffff"
                    font.pixelSize: 12
                    selectionColor: "#555555"
                }

                Row {
                    id: searchLogo
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.5
                    spacing: 2

                    Image {
                        width: 12
                        height: 12
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../img/title/search.png"
                    }

                    Text {
                        color: "#ffffff"
                        text: "搜索"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 12
                    }
                }
            }

            Image {
                id: addNoteImag
                width: 15
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                anchors.right: parent.right
                anchors.rightMargin: 20
                source: "../img/title/addNote.png"
            }
        }

        ListView {
            id: listView1
            anchors.top: titleItem.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            model: ListModel {
                ListElement {
                    name: "Grey"
                    colorCode: "grey"
                }
            }
            delegate: Item {
                x: 5
                width: 80
                height: 40
                Row {
                    id: row1
                    Rectangle {
                        width: 40
                        height: 40
                        color: colorCode
                    }

                    Text {
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                        font.bold: true
                    }
                    spacing: 10
                }
            }
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

