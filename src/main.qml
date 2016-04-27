import QtQuick 2.3
import QtQuick.Window 2.2

Window {
    visible: true

    id: mainWindow
    width: 320
    height: 568

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

        ListView {
            id: cardList
            anchors.top: parent.top
            anchors.topMargin: 45
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            model: [1].concat(notes.genreList)

            delegate: Item {
                width: mainWindow.width
                height: (mainWindow.height - 45)// * 2

                Rectangle {
                    width: mainWindow.width
                    height: mainWindow.height - 45
                    radius: 8
                    color: "white"
                    border.color: "#8C8C8C"
                    border.width: 1
                    Text {
                        x: mainWindow.width * 0.5 * 0.3
                        y: 10
                        text: modelData == 1 ? "新建项目" : modelData
                        color: "red"//之后换成notes内的classcolor接口
                        font.pixelSize: 18
                    }
                    Text {
                        visible: modelData != 1
                        x: mainWindow.width * 0.5 * 0.3
                        y: 35
                        text: noteListView.count + "项笔记"
                        color: "blue"//之后换成notes内的classcolor接口
                        font.pixelSize: 12
                    }
                    Rectangle {
                        y: 55
                        width: mainWindow.width
                        height: 1
                        opacity: 0.2
                        color: "black"
                    }

                    ListView {

                        visible: modelData != 1

                        x: mainWindow.width * 0.5 * 0.3
                        y: 65
                        id: noteListView
                        height: 20*noteListView.count

                        model: notes.getGenreNotes(modelData)
                        spacing: 5

                        delegate: Item {
                            width: 60
                            height: 20
                            Text {
                                x: 2
                                text: modelData.title
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
            spacing: -(((mainWindow.height - 45) * 1) - 50)
        }

        Item {
            id: titleItem
            anchors.bottom: parent.bottom
            anchors.bottomMargin: mainWindow.height - 45
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            Rectangle {
                id: titleRect
                anchors.fill: parent
                color: "#262626"
            }

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
                    anchors.fill: parent
                    onClicked: {
                        searchLogo.visible = false
                        searchContent.focus = true
                        searchContent.opacity = 1.0
                        searchFocusItem.y = 45
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

        Item {
            id: searchFocusItem
            opacity: 0.5
            y: mainWindow.height
            height: mainWindow.height - 45
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {
                id: searchFocusRect
                color: "#262626"
                anchors.fill: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    searchFocusItem.y = mainWindow.height
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
        }
    }

    /*Item {
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

    }*/

}

