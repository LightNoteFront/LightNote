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
            currentNote = notes.currentNote;
            if(!currentNote)
            {
                currentNote = notes.createEmptyNote();
                editState = true;
                inputTitle.forceActiveFocus();
            }
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
                    enabled: editState
                    anchors.fill: parent
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    selectionColor: "#555555"

                    text: currentNote.title

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
                        editState = false;
                        currentNote.content = textContent.text;
                        currentNote.title = inputTitle.text;
                        notes.applyNote();
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
            height: 30
            anchors.right: parent.right
            anchors.left: parent.left
        }

        Item {

            id: itemContent

            anchors.right: parent.right
            anchors.left: parent.left

            Layout.fillHeight: true

            Flickable {

                anchors.fill: parent
                anchors.margins: 5

                flickableDirection: Flickable.VerticalFlick
                clip: true

                contentHeight: textContent.height

                TextEdit {

                    id: textContent
                    enabled: editState
                    text: currentNote.content

                    width: parent.width

                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere


                }

            }

        }

    }


}

