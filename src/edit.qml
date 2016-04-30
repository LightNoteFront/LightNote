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
        }
    }

    Item {

        id: itemLayout
        anchors.fill: parent

        Item {

            id: itemTitle

            height: 45
            anchors.right: parent.right
            anchors.left: parent.left

            Image {
                id: imageBack
                width: 25
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
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
                radius: 8
                height: 25

                anchors.verticalCenter: parent.verticalCenter

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 55
                anchors.rightMargin: 55

                TextInput {
                    id: inputTitle
                    enabled: editState
                    anchors.fill: parent
                    color: "#979797"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
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
                        font.pixelSize: 12
                    }
                }
            }

            Image {
                id: btnOk
                visible: editState
                width: 25
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "img/edit/ok.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentNote.content = textContent.text;
                        currentNote.title = inputTitle.text;
                        notes.applyNote();
                        editState = false;
                    }
                }

            }

            Image {
                id: btnEdit
                visible: !editState
                width: 25
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
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
            height: editState ? 30 : 0
            anchors.top: itemTitle.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {

                id: btnTag
                y: 4
                width: 88
                height: 22
                color: state == "closed" ? "#f5f5f5" : "#cccccc"
                radius: 5
                anchors.left: parent.left
                anchors.leftMargin: 35
                border.color: state == "closed" ? "#979797" : "#cccccc"
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
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 12
                }

                Image {
                    id: arrowTag
                    width: 14
                    height: 9
                    anchors.verticalCenterOffset: 1-2*btnTag.foldAnim
                    rotation: 180*btnTag.foldAnim
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    source: "img/edit/arrows.png"
                }

            }

            Rectangle {
                id: btnGenre
                x: 163
                y: 4
                width: 88
                height: 22
                color: "#f5f5f5"
                radius: 5
                anchors.right: parent.right
                anchors.rightMargin: 35
                anchors.verticalCenter: parent.verticalCenter
                border.color: "#979797"

                MouseArea {
                    anchors.fill: parent
                }

                Text {
                    y: -9
                    color: "#979797"
                    text: "选择分类"
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: arrowGenre
                    x: -9
                    y: -9
                    width: 14
                    height: 9
                    anchors.verticalCenterOffset: 1
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    source: "img/edit/arrows.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }


        }

        Item {

            id: itemTagEdit
            height: 80*btnTag.foldAnim
            anchors.top: itemOption.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {
                anchors.fill: parent
                color: "#e9e9e9"
            }


            /*onFocusChanged: {
                if(!focus)
                    btnTag.state = "closed";
            }*/

        }

        Item {

            id: itemContent

            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: itemTagEdit.bottom
            anchors.bottom: parent.bottom

            Flickable {

                anchors.fill: parent
                anchors.margins: 5

                flickableDirection: Flickable.VerticalFlick
                clip: true

                contentHeight: textContent.contentHeight

                TextEdit {

                    id: textContent
                    enabled: editState

                    width: parent.width
                    height: Math.max(itemContent.height-10, textContent.contentHeight)

                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere


                }

            }

        }

    }


}

