import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    visible: true;
    width: 480;
    height: 320;

    Text {
        id: txt;
        text: "I am a text";
        color: "green";
        font.pixelSize: 24;
        Keys.onLeftPressed: x -= 10;
        Keys.onRightPressed: x += 10;
        Keys.onUpPressed: y += 10;
        Keys.onDownPressed: y -= 10;
        MouseArea {
            anchors.fill: parent;
            acceptedButtons: Qt.LeftButton|Qt.RightButton;
            onClicked: {
                if (mouse.button == Qt.LeftButton)
                {
                    txt.focus = true;
                }
                else if (mouse.button == Qt.RightButton)
                {
                    txt.focus = false;
                }
            }
        }
    }

    Button {
        y: 40;
        text: "A Button";
        onClicked: {
            console.log("click");
        }
    }

    Rectangle {
        x: 30;
        y: 80;
        width: 200;
        height: 30;
        color: "lightgray";
        border.width: 2;
        border.color: "black";
        radius: 8;



        TextInput {
            x: 10;
            y: 4;
            id: txti;
            width: 200;
            height: 200;
            MouseArea {
                anchors.fill: parent;
                acceptedButtons: Qt.LeftButton|Qt.RightButton;
                onClicked: {
                    if (mouse.button == Qt.LeftButton)
                    {
                        txti.focus = true;
                    }
                    else if (mouse.button == Qt.RightButton)
                    {
                        txti.focus = false;
                    }
                }
            }
        }
    }


}

