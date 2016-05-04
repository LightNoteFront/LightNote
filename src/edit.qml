import QtQuick 2.0
import QtQuick.Layouts 1.0
import LightNote.Note 1.0

Rectangle {

    id: mainItem

    width: 320
    height: 568

    color: "#F5F5F5"

    signal exit()

    function doExit() {
        mainItem.exit();
        //notes.currentNote = null;
    }

    property Note currentNote: notes.currentNote
    property bool editState: false

    onEnabledChanged: {
        if(enabled)
        {
            editState = false
            currentNote = notes.currentNote;
            if(!currentNote)
            {
                currentNote = notes.createEmptyNote();
                editState = true;
                inputTitle.forceActiveFocus();
            }
            inputTitle.text = currentNote.title
            textContent.text = currentNote.content
            tagListView.model = currentNote.tags
            genreSelect.selectedGenre = currentNote.genre
        }
    }

    Item {

        id: itemContainer
        anchors.fill: parent

        Item {

            id: itemTitle

            height: dp(45)
            anchors.right: parent.right
            anchors.left: parent.left

            Image {
                id: imageBack
                width: dp(25)
                height: dp(25)
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: dp(10)
                source: "img/edit/back.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mainItem.doExit();
                    }
                }

            }

            Rectangle {
                id: rectTitle
                color: "#dddddd"
                radius: dp(8)
                height: dp(25)

                anchors.verticalCenter: parent.verticalCenter

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: dp(55)
                anchors.rightMargin: dp(55)

                TextInput {
                    id: inputTitle
                    enabled: editState
                    anchors.fill: parent
                    color: "#979797"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: dp(12)
                    selectionColor: "#555555"

                }

                Row {
                    id: holderTitle
                    visible: !inputTitle.focus && inputTitle.text.length===0
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.5
                    Text {
                        color: "#ffffff"
                        text: "标题"
                        font.pixelSize: dp(12)
                    }
                }
            }

            Image {
                id: btnOk
                visible: editState
                width: dp(25)
                height: dp(25)
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: dp(10)
                source: "img/edit/ok.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentNote.content = textContent.text;
                        currentNote.title = inputTitle.text;
                        currentNote.genre = genreSelect.selectedGenre;
                        currentNote.tags = tagListView.model;
                        notes.applyNote();
                        editState = false;
                    }
                }

            }

            Image {
                id: btnEdit
                visible: !editState
                width: dp(25)
                height: dp(25)
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: dp(10)
                source: "img/edit/edit.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        editState = true;
                        textContent.forceActiveFocus();
                    }
                }

            }
        }

        Item {

            id: itemOption
            visible: editState
            height: dp(editState ? 30 : 0)
            anchors.top: itemTitle.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {

                id: btnTag
                y: dp(4)
                width: dp(88)
                height: dp(22)
                color: state == "closed" ? "#f5f5f5" : "#cccccc"
                border.color: state == "closed" ? "#979797" : "#cccccc"
                radius: dp(5)
                anchors.left: parent.left
                anchors.leftMargin: dp(35)
                anchors.verticalCenter: parent.verticalCenter

                property double foldAnim: 0

                state: "closed"
                states: [
                    State {
                        name: "closed"
                        PropertyChanges { target: btnTag; foldAnim: 0}
                    },
                    State {
                        name: "opened"
                        PropertyChanges { target: btnTag; foldAnim: 1}
                    }
                ]

                transitions: [
                    Transition {
                        to: "*"
                        PropertyAnimation { duration: 200; properties: "foldAnim"; easing.type: Easing.Linear }
                    }
                ]

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        btnTag.state = (btnTag.state == "closed" ? "opened" : "closed");
                    }
                }

                Text {
                    color: "#979797"
                    text: "选择标签"
                    anchors.right: parent.right
                    anchors.rightMargin: dp(10)
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: dp(12)
                }

                Image {
                    id: arrowTag
                    width: dp(14)
                    height: dp(9)
                    anchors.verticalCenterOffset: dp(1-2*btnTag.foldAnim)
                    rotation: 180*btnTag.foldAnim
                    anchors.left: parent.left
                    anchors.leftMargin: dp(10)
                    anchors.verticalCenter: parent.verticalCenter
                    source: "img/edit/arrows.png"
                }

            }

            Rectangle {
                id: btnGenre
                x: dp(163)
                y: dp(4)
                width: Math.min(textGenreButton.contentWidth, dp(72)) + dp(40)
                height: dp(22)
                color: state == "closed" ? "#f5f5f5" : "#cccccc"
                border.color: state == "closed" ? "#979797" : "#cccccc"
                radius: dp(5)
                anchors.right: parent.right
                anchors.rightMargin: dp(35)
                anchors.verticalCenter: parent.verticalCenter

                property double foldAnim: 0

                state: "closed"
                states: [
                    State {
                        name: "closed"
                        PropertyChanges { target: btnGenre; foldAnim: 0}
                        PropertyChanges { target: genreSelect; enabled: false}
                    },
                    State {
                        name: "opened"
                        PropertyChanges { target: btnGenre; foldAnim: 1}
                        PropertyChanges { target: genreSelect; enabled: true}
                    }
                ]

                transitions: [
                    Transition {
                        to: "*"
                        PropertyAnimation { duration: 200; properties: "foldAnim"; easing.type: Easing.Linear }
                    }
                ]

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        btnGenre.state = (btnGenre.state == "closed" ? "opened" : "closed");
                    }
                }

                Text {
                    id: textGenreButton
                    color: "#979797"
                    text: genreSelect.selectedGenre.length == 0 ? "选择分类" : genreSelect.selectedGenre
                    anchors.left: parent.left
                    anchors.leftMargin: dp(10)
                    anchors.right: arrowGenre.left
                    anchors.rightMargin: dp(6)
                    clip: true
                    font.pixelSize: dp(12)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: arrowGenre
                    width: dp(14)
                    height: dp(9)
                    anchors.verticalCenterOffset: dp(1-2*btnGenre.foldAnim)
                    rotation: -180*btnGenre.foldAnim
                    anchors.right: parent.right
                    anchors.rightMargin: dp(10)
                    source: "img/edit/arrows.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }


        }

        Item {

            id: itemTagEdit
            height: dp(editState ? 60*btnTag.foldAnim : 0)
            anchors.top: itemOption.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            clip: true

            Rectangle {

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: dp(30)
                color: "#e9e9e9"

                ListView {

                    id: tagListView
                    height: dp(20)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: itemAddTag.left
                    anchors.leftMargin: dp(5)
                    anchors.rightMargin: dp(5)
                    clip: true
                    orientation: ListView.Horizontal
                    spacing: dp(2)

                    delegate: Rectangle {
                        width: Math.max(textTag.width, dp(10))+dp(10)
                        height: dp(20)
                        color: notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                        radius: dp(10)

                        Text {
                            id: textTag
                            color: "white"
                            font.pixelSize: dp(12)
                            font.wordSpacing : dp(1.5)
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Item {
                    id: itemAddTag
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: dp(30)

                    Image {
                        height: dp(24)
                        width: dp(24)
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                    }

                }

            }

            Rectangle {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: dp(30)
                height: dp(30)
                color: "#e0e0e0"

                Text {
                    id: textHintPop
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: dp(5)
                    text: "常用Tag:"
                    font.pixelSize: dp(12)
                    color: "#333333"
                }

                ListView {

                    id: tagPopListView
                    height: dp(20)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: textHintPop.right
                    anchors.right: parent.right
                    anchors.leftMargin: dp(5)
                    anchors.rightMargin: dp(5)
                    clip: true
                    orientation: ListView.Horizontal
                    spacing: dp(2)

                    model: notes.popularTags;

                    delegate: Rectangle {
                        width: Math.max(textTagPop.width, dp(10))+dp(10)
                        height: dp(20)
                        color: notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                        radius: dp(10)

                        Text {
                            id: textTagPop
                            color: "white"
                            font.pixelSize: dp(12)
                            font.wordSpacing : dp(1.5)
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var flag = true;
                                for(var tag in tagListView.model)
                                {
                                    if(tag === modelData)
                                    {
                                        flag = false;
                                        break;
                                    }
                                }
                                if(flag)
                                {
                                    var model = tagListView.model;
                                    model.push(modelData);
                                    tagListView.model = model;
                                }
                            }
                        }

                    }
                }

            }

        }

        Item {

            id: itemContent

            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: itemTagEdit.bottom
            anchors.bottom: parent.bottom

            Flickable {

                anchors.fill: parent
                anchors.margins: dp(5)

                flickableDirection: Flickable.VerticalFlick
                clip: true

                contentHeight: textContent.contentHeight

                TextEdit {

                    id: textContent
                    enabled: editState

                    width: parent.width
                    height: Math.max(itemContent.height-dp(10), textContent.contentHeight)

                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    font.pixelSize: dp(15)

                }

            }

        }

        Item {

            id: genreSelect
            anchors.fill: parent

            property string selectedGenre: ""

            Rectangle {
                id: genreSelectOverlay
                anchors.fill: parent
                color: "black"
                opacity: btnGenre.foldAnim*0.2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    btnGenre.state = "closed"
                }
            }

            Rectangle {
                id: genreSelectList
                y: dp(80)
                anchors.right: parent.right
                anchors.rightMargin: dp(30)
                width: dp(200)
                height: dp(btnGenre.foldAnim*129)

                ListView {
                    id: genreSelectListView

                    anchors.fill: parent
                    anchors.margins: dp(3)

                    spacing: 1
                    clip: true

                    model: [1].concat(notes.getGenreList())

                    delegate: Rectangle {

                        height: dp(30)
                        width: genreSelectListView.width
                        color: modelData === genreSelect.selectedGenre ? "#e8e8e8" :
                                   mouseAreaGenre.pressed ? "#dddddd" : "white"

                        Rectangle {
                            visible: modelData !== 1
                            color: "#dddddd"
                            height: 1
                            width: parent.width
                            y: -1
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: dp(2)
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: dp(14)
                            text: modelData === 1 ? "新建分类..." : modelData
                            color: modelData === 1 ? "black" :
                                   notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                        }

                        MouseArea {
                            id: mouseAreaGenre
                            anchors.fill: parent
                            onClicked: {
                                if(modelData === 1)
                                {
                                    // 新建
                                }
                                else
                                {
                                    genreSelect.selectedGenre = modelData;
                                    btnGenre.state = "closed";
                                }
                            }
                        }

                    }

                }

            }

        }

    }


}

