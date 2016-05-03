import QtQuick 2.3
import QtQuick.Window 2.2

Window {

    visible: true

    id: mainWindow
    width: 320
    height: 568

    minimumWidth: 300
    minimumHeight: 532


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
                spacing: -(itemCardList.height - 50 + 50 * foldAnim)

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
                    height: itemCardList.height * 1.01 +
                            (cardList.selectedGenre==modelData ? (itemCardList.height - 20) * cardList.foldAnim : 0);

                    Rectangle {
                        id: rectCard
                        width: itemCardList.width
                        height: itemCardList.height
                        radius: 8
                        color: "white"
                        border.color: "#8C8C8C"
                        border.width: 1

                        Text {
                            x: parent.width * 0.5 * 0.3
                            y: 10
                            text: modelData == 1 ? "新建分类" : modelData
                            font.bold : true
                            font.wordSpacing : 1.5
                            color: modelData === 1 ? "#909090" : notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                            font.pixelSize: 20
                        }
                        Text {
                            visible: modelData != 1
                            x: parent.width * 0.5 * 0.3
                            y: 35
                            text: noteListView.count + "项笔记"
                            font.wordSpacing : 1.3
                            color: modelData === 1 ? "black" : notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                            font.pixelSize: 12
                        }
                        Rectangle {
                            y: 55
                            width: parent.width
                            anchors.horizontalCenter: parent.horizontalCenter
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
                                    // 新建分类
                                }
                                else
                                {
                                    cardList.setSelected(cardList.state=="opened" ? null : modelData);
                                }
                            }
                        }

                        Connections {
                            target: notes
                            onNotesChanged: {
                                noteListView.model = notes.getGenreNotesFiltered(modelData);
                            }
                            onFilterChanged: {
                                noteListView.model = notes.getGenreNotesFiltered(modelData);
                            }
                        }
                        //各项笔记
                        ListView {

                            id: noteListView

                            clip: true
                            visible: modelData == cardList.selectedGenre
                            interactive: cardList.state == "opened"
                            opacity: cardList.foldAnim

                            y: 65
                            height: parent.height - 75
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 30
                            anchors.rightMargin: 30

                            model: notes.getGenreNotesFiltered(modelData)
                            spacing: 5

                            delegate: Item {
                                id: textTitleItem
                                width: parent.width
                                height: 24

                                Rectangle {
                                    y: 22
                                    width: parent.width
                                    height: 1
                                    opacity: 0.2
                                    color: "black"
                                }

                                Row {
                                    id: noteRow

                                    anchors.fill: parent

                                    ListView {
                                        id: noteTagListView
                                        orientation: ListView.Horizontal
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 22 * noteTagListView.count + 2
                                        spacing: 2

                                        model: modelData.tags

                                        delegate: Item {
                                            width: 20
                                            height: 20
                                            Rectangle {
                                                anchors.fill: parent
                                                color: notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                                                radius: 10
                                            }

                                            Text {
                                                color: "#ffffff"
                                                font.pixelSize: 12
                                                font.wordSpacing : 1.5
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData[0]
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    Text {
                                        color: "#6999af"
                                        font.wordSpacing : 1.5
                                        text: modelData.title
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.pixelSize: 16
                                    }
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
                    PropertyChanges { target: searchContent; focus: true; opacity: 1.0 }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: searchFocusItem; opacity: 0; enabled: false }
                    PropertyChanges { target: searchContent; focus: false; opacity: 0.5 }
                }
            ]

            transitions: [
                Transition {
                    to: "*"
                    PropertyAnimation {
                        target: searchFocusItem
                        duration: 100; properties: "opacity"; easing.type: Easing.Linear
                    }
                }
            ]

            Rectangle {
                id: titleRect
                anchors.fill: parent
                color: "#262626"
            }

            Image {
                id: menuImage
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
                        titleItem.state = "opened"
                    }

                }

                TextInput {
                    id: searchContent
                    //text: //这里可以指定一些网络的热门搜索
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "#ffffff"
                    font.pixelSize: 12
                    selectionColor: "#555555"
                    onAccepted: {
                        notes.filter = searchContent.text;
                        titleItem.state = "closed"
                    }
                    onFocusChanged: {
                        if(focus)
                            titleItem.state = "opened"
                    }
                }

                Row {
                    id: searchLogo
                    visible: titleItem.state == "closed" && searchContent.text.length == 0
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
                        notes.filter = searchContent.text;
                        titleItem.state = "closed"
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
                    color: "black"
                    radius: 5
                    border.color: "#747474"

                }

                MouseArea {
                    anchors.fill: parent
                }

                Image {
                    id: topMenuImage
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 500
                    source: "img/menu/menu.png"

                    Column {
                        id: menuColumn
                        anchors.topMargin: 80
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top

                        Row {
                            id: innerMenuRow
                            height: 100
                            anchors.leftMargin: 20
                            spacing: 15
                            anchors.right: parent.right
                            anchors.left: parent.left

                            Image {
                                id: userPhotoImage
                                width: 70
                                height: 70
                                x: 20
                                y: 15

                                source: "img/menu/null.png"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        //添加android选取图片的API，修改source
                                        userPhotoImage.source = "img/menu/null.png"
                                    }
                                }
                            }

                            Column {
                                id: innerMenuInfofationColumn
                                y: 15
                                spacing: 15

                                Text {
                                    id: userNameInformationText
                                    text: "未登陆"
                                    color: "#ffffff"
                                    font.pixelSize: 24
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (userNameInformationText.text == "未登陆")
                                            {
                                                userItemContainer.state = "login"
                                            }
                                            else//注销
                                            {
                                                userNameInformationText.text = "未登陆"
                                                userPhotoImage.source = "img/title/null.png"
                                                userNoteNumberText.text = "笔记 0项"
                                            }
                                        }
                                    }
                                }
                                Text {
                                    id: userNoteNumberText
                                    text: "笔记 0项"//用户笔记数量
                                    color: "#747474"

                                }
                            }
                        }

                        Column {
                            id: innerMenuColumn
                            height: 45
                            spacing: 10
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.left: parent.left

                            Rectangle {
                                id: innerCutLineRectangle
                                width: 215
                                height: 1
                                color: "#747474"
                            }

                            Text {
                                id: innerSelectInformationText
                                color: "#747474"
                                text: qsTr("按标签筛选")
                            }

                        }

                        Grid {
                            id: innerMenuGrid
                            height: 100
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.left: parent.left

                        }
                    }
                }

                Item {
                    id: footerMenuItem
                    height: 40
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Rectangle {
                        id: rectangle1
                        height: 1
                        color: "#747474"
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

                    Row {
                        id: footerCommandRow
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.left: parent.left
                        spacing: 15
                        anchors.leftMargin: 20

                        Image {
                            id: footerSettingImage
                            width: 20
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/menu/setting.png"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    //subItem.loadUI("test.qml");//写崩了。。。
                                }
                            }
                        }

                        Image {
                            id: footerUploadImage
                            width: 30
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/menu/upload.png"

                        }
                    }
                }
            }
        }

        Item {
            id: userItemContainer

            anchors.fill: parent

            state: "closed"
            states: [
                State {
                    name: "login"
                    PropertyChanges { target: userStatement; opacity: 1; enabled: true }
                    PropertyChanges { target: userRegister; opacity: 0; enabled: false }
                    PropertyChanges { target: userCancelItem; opacity: 0.5; enabled: true }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: userStatement; opacity: 0; enabled: false }
                    PropertyChanges { target: userRegister; opacity: 0; enabled: false }
                    PropertyChanges { target: userCancelItem; opacity: 0; enabled: false }
                },
                State {
                    name: "register"
                    PropertyChanges { target: userStatement; opacity: 0; enabled: false }
                    PropertyChanges { target: userRegister; opacity: 1; enabled: true }
                    PropertyChanges { target: userCancelItem; opacity: 0.5; enabled: true }
                }
            ]

            transitions: [
                Transition {
                    from: "closed"
                    to: "login"
                    PropertyAnimation {
                        target: userStatement
                        duration: 200; properties: "opacity"; easing.type: Easing.Linear
                    }
                    PropertyAnimation {
                        target: userCancelItem
                        duration: 200; properties: "opacity"; easing.type: Easing.Linear
                    }
                },
                Transition {
                    from: "login"
                    to: "register"
                    SequentialAnimation
                    {
                        PropertyAnimation {
                            target: userStatement
                            duration: 100; properties: "opacity"; easing.type: Easing.Linear
                        }
                        PropertyAnimation {
                            target: userRegister
                            duration: 100; properties: "opacity"; easing.type: Easing.Linear
                        }
                    }
                },
                Transition {
                    from: "register"
                    to: "login"
                    SequentialAnimation
                    {
                        PropertyAnimation {
                            target: userStatement
                            duration: 100; properties: "opacity"; easing.type: Easing.Linear
                        }
                        PropertyAnimation {
                            target: userRegister
                            duration: 100; properties: "opacity"; easing.type: Easing.Linear
                        }
                    }
                },
                Transition {
                    from: "*"
                    to: "closed"
                    PropertyAnimation {
                        target: userStatement
                        duration: 200; properties: "opacity"; easing.type: Easing.Linear
                    }
                    PropertyAnimation {
                        target: userRegister
                        duration: 200; properties: "opacity"; easing.type: Easing.Linear
                    }
                    PropertyAnimation {
                        target: userCancelItem
                        duration: 200; properties: "opacity"; easing.type: Easing.Linear
                    }
                }
            ]

            Item {
                id: userCancelItem

                anchors.fill: parent

                Rectangle {
                    color: "#262626"
                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        userItemContainer.state = "closed"
                    }
                }
            }

            Item {
                id: userStatement

                width: 200
                height: 300
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent

                    radius: 8

                    color: "#606060"

                    opacity: 0.9
                }

                MouseArea {
                    anchors.fill: parent
                }

                Column {
                    id: userLoginInfo
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    spacing: 40

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "用户登录"
                        color: "#ffffff"
                        font.pixelSize: 20
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "用户名："
                            color: "#ffffff"
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: 100
                            height: 20

                            TextInput {
                                id: userName
                                anchors.fill: parent
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "    密码："
                            color: "#ffffff"
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: 100
                            height: 20

                            TextInput {
                                id: userPasswd
                                echoMode: TextInput.Password
                                anchors.fill: parent
                            }
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Rectangle {
                            id: loginSubmitButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "登陆"
                            }

                            color: "#ffffff"
                            width: 40
                            height: 20

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    //登陆行为
                                    userItemContainer.state = "closed"
                                }
                            }
                        }

                        Rectangle {
                            id: registerButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "注册"
                            }

                            color: "#ffffff"
                            width: 40
                            height: 20

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    userItemContainer.state = "register"
                                }
                            }
                        }
                    }
                }

            }

            Item {
                id: userRegister

                width: 200
                height: 400
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent

                    radius: 8

                    color: "#606060"

                    opacity: 0.9
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                    }
                }

                Column {
                    id: userRegisterInfo
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    spacing: 40

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "用户注册"
                        color: "#ffffff"
                        font.pixelSize: 20
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "   用户名："
                            color: "#ffffff"
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: 100
                            height: 20

                            TextInput {
                                id: registerUserName
                                anchors.fill: parent
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "       密码："
                            color: "#ffffff"
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: 100
                            height: 20

                            TextInput {
                                id: registerUserPasswd
                                echoMode: TextInput.Password
                                anchors.fill: parent
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "再次输入："
                            color: "#ffffff"
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: 100
                            height: 20

                            TextInput {
                                id: registerUserPasswdTwo
                                echoMode: TextInput.Password
                                anchors.fill: parent
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "电话号码："
                            color: "#ffffff"
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: 100
                            height: 20

                            TextInput {
                                id: registerUserPhoneNumber
                                anchors.fill: parent
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Rectangle {
                            id: registerSubmitButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "注册"
                            }

                            color: "#ffffff"
                            width: 40
                            height: 20

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (registerUserPasswd.text == registerUserPasswdTwo.text && registerUserName.text != "未登陆")
                                    {
                                        //注册行为
                                        userItemContainer.state = "login"
                                    }
                                    else
                                    {
                                        noticeItem.notify("用户名不合法或者密码不合法！")
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: resetButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "重置"
                            }

                            color: "#ffffff"
                            width: 40
                            height: 20

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    registerUserName.text = ""
                                    registerUserPasswd.text = ""
                                    registerUserPasswdTwo.text = ""
                                }
                            }
                        }
                    }
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
                PropertyChanges { target: mainItem; enabled: false }
            },
            State {
                name: "closed"
                PropertyChanges { target: subItem; x: parent.width; visible: false; enabled: false }
                PropertyChanges { target: mainItem; enabled: true }
            }
        ]

        transitions: [
            Transition {
                from: "opened"
                to: "closed"
                SequentialAnimation {
                    PropertyAnimation { duration: 100; properties: "x"; easing.type: Easing.Linear }
                    PropertyAction { property: "visible"; value: false }
                }
            },
            Transition {
                from: "closed"
                to: "opened"
                SequentialAnimation {
                    PropertyAction { property: "visible"; value: true }
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
            //source: "test.qml"
            anchors.fill: parent
        }

        Connections {
            target: testLoader.item
            onExit: {
                subItem.enabled = false;
                subItem.state = "closed";
            }
        }
        //以下这些是不是可以删除了
        /*
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

        }*/

    }

    Item {
        id: noticeItem

        function notify(str)
        {
            if (str !== "")
            {
                noticeText.text = str
                noticeItem.state = "notify"
            }
            else
            {
                noticeText.text = "无内容的通知"
                noticeItem.state = "notify"
            }
        }
        anchors.fill: parent

        state: "closed"
        states: [
            State {
                name: "notify"
                PropertyChanges { target: noticeItem; opacity: 1; enabled: true }
            },
            State {
                name: "closed"
                PropertyChanges { target: noticeItem; opacity: 0; enabled: false }
            }
        ]

        transitions: [
            Transition {
                to: "*"
                PropertyAnimation {
                    target: noticeItem
                    duration: 100; properties: "opacity"; easing.type: Easing.Linear
                }
            }
        ]

        Rectangle {
            color: "#262626"
            anchors.fill: parent
            opacity: 0.5
        }

        Rectangle {
            color: "#262626"
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
            width: 200
            height: 150

            Text {
                id: noticeText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                color: "#ffffff"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                noticeItem.state = "closed"
            }
        }
    }
}
