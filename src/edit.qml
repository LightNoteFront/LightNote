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
        notes.currentNote = null;
        mainItem.exit();
    }

    property Note currentNote: notes.currentNote

    function setEditState(state) {
        btnEdit.visible = !state;
        btnOk.visible = state;
        textContent.enabled = state;
        inputTitle.enabled = state;
    }


    Component.onCompleted: {
        if(!currentNote)
        {
            currentNote = notes.createEmptyNote();
            inputTitle.forceActiveFocus();
            setEditState(true);
        }

    }

    ColumnLayout {

        anchors.fill: parent

        Item {

            id: titleItem

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
                color: "#E4E4E4"
                radius: 8
                height: 25

                anchors.verticalCenter: parent.verticalCenter

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 55
                anchors.rightMargin: 55

                TextInput {
                    id: inputTitle
                    anchors.fill: parent
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    selectionColor: "#555555"

                    text: currentNote.title
                    onTextChanged: {
                        currentNote.title = inputTitle.text;
                    }

                    onFocusChanged: {
                        if(!inputTitle.focus && text.length==0)
                            holderTitle.visible = true;
                        else
                            holderTitle.visible = false;
                    }

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
                id: btnOk
                visible: false
                width: 25
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "img/edit/ok.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        setEditState(false);
                        notes.saveNote();
                    }
                }

            }

            Image {
                id: btnEdit
                visible: true
                width: 25
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "img/edit/edit.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        setEditState(true);
                    }
                }

            }
        }

        Item {
            id: itemOption
            height: 30
            anchors.right: parent.right
            anchors.left: parent.left
        }

        Item {
            id: itemContent
            anchors.right: parent.right
            anchors.left: parent.left

            Layout.fillHeight: true

            TextEdit {
                id: textContent

                anchors.rightMargin: 5
                anchors.leftMargin: 5
                anchors.bottomMargin: 5
                anchors.topMargin: 5
                anchors.fill: parent

            }

        }

    }


}

