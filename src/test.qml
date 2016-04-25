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

            width: 60
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

                }

                ListView {

                    id: noteListView
                    width: 60
                    height: 20*noteListView.count

                    model: notes.getGenreNotes(modelData)

                    delegate: Rectangle {
                        width: 60
                        height: 20
                        color: "green"
                        Text {
                            x: 2
                            text: modelData.title
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                }

            }
        }

    }


}

