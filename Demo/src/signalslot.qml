import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: cao
    visible: true
    width: 300
    height: 200
    color: "black"

    Text {
        id: txt
        text: "cener text"
        font.pointSize: 18;
        color: "blue"
    }

    Button {
        x: 0
        y: 0
        id: b1
        text: "Quit"
    }

    onWidthChanged: wC()

    onHeightChanged: {
        txt.y = (cao.height - txt.height) / 2
    }
    function wC() {
        txt.x = (cao.width - txt.width) / 2
    }
    function quitApp() {
        txt.y = (cao.height - txt.height) / 3
        txt.x = (cao.width - txt.width) / 3
    }
    /*
    Component.onCompleted: {
        b1.clicked.connect(quitApp)
    }*/
    Connections {
        target: b1
        onClicked: quitApp()
    }
}

