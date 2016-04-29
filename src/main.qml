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

        Item {
            id: itemCardList

            height: mainWindow.height - 45
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            ListView {

                id: cardList

                property variant selectedGenre: null
                property double foldAnim: 0

                function setSelected(genre)
                {
                    if(genre !== null)
                        selectedGenre = genre;
                    state = (genre === null ? "folded" : "opened");
                }

                anchors.fill: parent

                anchors.bottomMargin: -(itemCardList.height - 50 + 45 * foldAnim)
                spacing: -(itemCardList.height - 50 + 45 * foldAnim)

                state: "folded"
                states: [
                    State {
                        name: "folded"
                        PropertyChanges { target: cardList; foldAnim: 0}
                    },
                    State {
                        name: "opened"
                        PropertyChanges { target: cardList; foldAnim: 1}
                    }
                ]

                transitions: [
                    Transition {
                        to: "*"
                        PropertyAnimation { duration: 200; properties: "foldAnim"; easing.type: Easing.InOutQuad }
                    }
                ]

                model: [1].concat(notes.genreList)

                delegate: Item {
                    width: itemCardList.width
                    height: itemCardList.height * 1 +
                            (cardList.selectedGenre==modelData ? (itemCardList.height - 20) * cardList.foldAnim : 0);

                    Rectangle {
                        width: itemCardList.width
                        height: itemCardList.height
                        radius: 8
                        color: "white"
                        border.color: "#8C8C8C"
                        border.width: 1

                        Text {
                            x: parent.width * 0.5 * 0.3
                            y: 10
                            text: modelData == 1 ? "新建项目" : modelData
                            color: "red"//之后换成notes内的classcolor接口
                            font.pixelSize: 18
                        }
                        Text {
                            visible: modelData != 1
                            x: parent.width * 0.5 * 0.3
                            y: 35
                            text: noteListView.count + "项笔记"
                            color: "blue"//之后换成notes内的classcolor接口
                            font.pixelSize: 12
                        }
                        Rectangle {
                            y: 55
                            width: parent.width
                            height: 1
                            opacity: 0.2
                            color: "black"
                        }

                        MouseArea {
                            height: 55
                            width: parent.width
                            onClicked: {
                                if(modelData == 1)
                                {
                                    // 新建项目
                                }
                                else
                                {
                                    cardList.setSelected(cardList.state=="opened" ? null : modelData);
                                }
                            }
                        }

                        ListView {

                            visible: modelData == cardList.selectedGenre
                            opacity: cardList.foldAnim

                            x: parent.width * 0.5 * 0.3
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
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        notes.currentNote = modelData;
                                        subItem.loadUI("edit.qml");
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }

        Item {
            id: titleItem
            anchors.bottom: parent.bottom
            anchors.bottomMargin: mainWindow.height - 45
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            state: "closed"
            states: [
                State {
                    name: "opened"
                    PropertyChanges { target: searchFocusItem; opacity: 0.5; enabled: true }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: searchFocusItem; opacity: 0; enabled: false }
                }
            ]

            transitions: [
                Transition {
                    to: "*"
                    PropertyAnimation { duration: 100; properties: "opacity"; easing.type: Easing.Linear }
                }
            ]

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
                        menuContainer.state = "opened"
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
                        titleItem.state = "opened"
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
                        notes.currentNote = null;
                        subItem.loadUI("edit.qml");
                    }
                }
            }

            Item {
                id: searchFocusItem
                height: mainItem.height - 45

                anchors.top: titleItem.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    color: "#262626"
                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        titleItem.state = "closed"
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

        Item {
            id: menuContainer
            anchors.fill: parent

            state: "closed"
            states: [
                State {
                    name: "opened"
                    PropertyChanges { target: menuItem; x: -5; enabled: true }
                    PropertyChanges { target: menuCancelItem; opacity: 0.5; enabled: true }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: menuItem; x: -250; enabled: false }
                    PropertyChanges { target: menuCancelItem; opacity: 0; enabled: false }
                }
            ]

            transitions: [
                Transition {
                    to: "*"
                    PropertyAnimation { duration: 100; properties: "x,opacity"; easing.type: Easing.Linear }
                }

            ]

            Item {
                id: menuCancelItem
                anchors.left: menuItem.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.leftMargin: -5


                Rectangle {
                    color: "#262626"
                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        menuContainer.state = "closed"
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
                    PropertyAction { property: "enabled"; value: true }
                    PropertyAnimation { duration: 100; properties: "x"; easing.type: Easing.Linear }
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

