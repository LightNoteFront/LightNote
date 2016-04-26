import QtQuick 2.0

Item {
    width: 300
    height: 300

    ListView {

        id: listView1

        anchors.fill: parent

        spacing: -1

        model: notes.genreList

        delegate: Item {

            id: itemView

            width: listView1.width
            height: noteListView.height

            Row {
                id: row1
                spacing: 0

                Rectangle {
                    width: 40
                    height: noteListView.height
                    color: "blue"

                    border.width: 1
                    border.color: "black"

                    Text {
                        x: 2
                        text: modelData
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            noteListView.model = notes.getGenreNotes(modelData);
                        }
                    }

                }

                Connections {
                    target: notes
                    onNotesChanged: {
                        noteListView.model = notes.getGenreNotes(modelData);
                    }
                }

                ListView {

                    id: noteListView
                    width: 60
                    height: 20*noteListView.count

                    model: notes.getGenreNotes(modelData)

                    delegate: Row {

                        Rectangle {
                            width: tagListView.width+2
                            height: 20
                            color: "green"
                            anchors.verticalCenter: parent.verticalCenter

                            ListView {

                                id: tagListView
                                height: 16
                                x: 1
                                anchors.verticalCenter: parent.verticalCenter

                                orientation: ListView.Horizontal
                                interactive: false

                                spacing: 1

                                model: modelData.tags

                                delegate: Rectangle {

                                    width: textTag.width+2
                                    height: 16
                                    color: "orange"

                                    Text {
                                        id: textTag
                                        x: 2
                                        text: modelData
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                }

                                onCountChanged: {
                                    // iterate over each delegate item to get their sizes
                                    var listViewWidth = 0;
                                    var len = tagListView.children.length > 2 ? 2 : tagListView.children.length;
                                    for (var i = 0; i < len; i++) {
                                        listViewWidth += tagListView.children[i].width;
                                    }
                                    //console.log(textTitle.text, listViewWidth);
                                    tagListView.width = listViewWidth;
                                }

                            }
                        }


                        Rectangle {
                            width: textTitle.width+4
                            height: 20
                            color: "green"
                            Text {
                                id: textTitle
                                x: 2
                                text: modelData.title
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            width: textNote.width+4
                            height: 20
                            color: "lime"
                            Text {
                                id: textNote
                                x: 2
                                text: modelData.text
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                    }

                }

            }
        }

    }


}

