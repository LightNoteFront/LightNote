import QtQuick 2.0

Item {
    width: 300
    height: 300

    ListView {
        id: listView1

        anchors.fill: parent

        model: notes.genreList

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
                    text: modelData
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                ListView {
                    id: noteListView
                    width: parent.width
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
        spacing: -(((mainWindow.height - 45) * 1) - 60)

    }


}

