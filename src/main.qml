import QtQuick 2.3
import QtQuick.Window 2.2

Window {

    visible: true

    id: mainWindow
    width: 320
    height: 568

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
                source: "img/title/menu.png"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        menuItem.x = -5
                        menuCalcelItem.x = 240
                    }
                }
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
                        source: "img/title/search.png"
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
                source: "img/title/addNote.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        subItem.loadUI("edit.qml");
                    }
                }
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

        Item {
            id: menuCalcelItem
            opacity: 0.5
            x: mainWindow.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: mainWindow.width - 240

            Rectangle {
                color: "#262626"
                anchors.fill: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuItem.x = -250
                    menuCalcelItem.x = mainWindow.width
                }
            }
        }

        Item {
            id: menuItem
            width: 250
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            x: -250

            Rectangle {
                anchors.fill: parent
                radius: 5
                color: "black"
                border.color: "#919191"
                border.width: 1
            }

            Image {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 500
                source: "img/menu/menu.png"
            }
        }
    }

    Item {
        id: subItem

        height: parent.height
        width: parent.width
        x: 0

        state: "closed"
        states: [
            State {
                name: "opened"
                PropertyChanges { target: subItem; x: 0; visible: true; enabled: true }
            },
            State {
                name: "closed"
                PropertyChanges { target: subItem; x: parent.width; visible: false; enabled: false }
            }
        ]

        transitions: [
            Transition {
                from: "opened"
                to: "closed"
                SequentialAnimation {
                    PropertyAction { property: "enabled"; value: false }
                    PropertyAnimation { duration: 100; properties: "x"; easing.type: Easing.Linear }
                    PropertyAction { property: "visible"; value: false }
                }
            },
            Transition {
                from: "closed"
                to: "opened"
                SequentialAnimation {
                    PropertyAction { property: "visible"; value: true }
                    PropertyAnimation { duration: 100; properties: "x"; easing.type: Easing.Linear }
                    PropertyAction { property: "enabled"; value: true }
                }
            }
        ]

        function loadUI(url)
        {
            testLoader.source = url;
            subItem.state = "opened";
        }

        Loader {
            id: testLoader
            //source: "edit.qml"
            anchors.fill: parent
        }

        Connections {
            target: testLoader.item
            onExit: {
                subItem.enabled = false;
                subItem.state = "closed";
            }
        }

        Rectangle {
            visible: false

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
                    subItem.enabled = false;
                    subItem.state = "closed";
                }
            }

        }

    }

}

