import QtQuick 2.3
import QtQuick.Window 2.2
import LightNote.Note 1.0

Window {

    visible: true

    id: mainWindow
    width: 320
    height: 568

    //minimumWidth: 300
    //minimumHeight: 532

    function dp(px)
    {
        return px*devicePixelRatio;
    }

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

            height: mainWindow.height - dp(45)
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
                        selectedGenre = genre
                    state = (genre === null ? "folded" : "opened")
                }

                anchors.fill: parent

                anchors.bottomMargin: -itemCardList.height + dp(50 - 45 * foldAnim)
                spacing: -itemCardList.height + dp(50 - 50 * foldAnim)

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
                            (cardList.selectedGenre==modelData ?
                                 (itemCardList.height - 20) * cardList.foldAnim : 0)

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
                            y: dp(10)
                            text: modelData == 1 ? "新建分类" : modelData
                            font.bold : true
                            font.wordSpacing : 1.5
                            color: modelData === 1 ? "#909090" : notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                            font.pixelSize: dp(20)
                        }
                        Text {
                            visible: modelData != 1
                            x: parent.width * 0.5 * 0.3
                            y: dp(35)
                            text: noteListView.count + "项笔记"
                            font.wordSpacing : 1.3
                            color: modelData === 1 ? "black" : notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                            font.pixelSize: dp(12)
                        }

                        Rectangle {
                            y: dp(60)
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            opacity: 0.2
                            color: "black"
                        }

                        MouseArea {
                            height: dp(55)
                            anchors.left: parent.left
                            anchors.right: parent.right

                            onPressAndHold: {
                                if (modelData != 1)
                                {
                                    classDeleteItem.classDelete(modelData)
                                }
                            }

                            onClicked: {
                                if(modelData == 1)
                                {
                                    addGenre.add()
                                }
                                else
                                {
                                    cardList.setSelected(cardList.state=="opened" ? null : modelData)
                                }
                            }
                        }

                        Connections {
                            target: notes
                            onNotesChanged: {
                                noteListView.model = notes.getGenreNotesFiltered(modelData)
                            }
                            onFilterChanged: {
                                noteListView.model = notes.getGenreNotesFiltered(modelData)
                            }
                        }
                        //各项笔记
                        ListView {

                            id: noteListView

                            clip: true
                            visible: modelData == cardList.selectedGenre
                            interactive: cardList.state == "opened"
                            opacity: cardList.foldAnim

                            y: dp(70)
                            height: parent.height - dp(75)
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: dp(30)
                            anchors.rightMargin: dp(30)

                            model: notes.getGenreNotesFiltered(modelData)
                            spacing: 5

                            delegate: Item {
                                id: textTitleItem
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: dp(24)

                                Rectangle {
                                    y: dp(22)
                                    anchors.left: parent.left
                                    anchors.right: parent.right
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
                                        width: dp(22 * noteTagListView.count + 2)
                                        spacing: 2

                                        model: modelData.tags

                                        delegate: Item {
                                            width: dp(20)
                                            height: dp(20)
                                            Rectangle {
                                                anchors.fill: parent
                                                color: notes.getColor(modelData.charCodeAt(Math.max(modelData.length-2, 0)))
                                                radius: dp(10)
                                            }

                                            Text {
                                                color: "#ffffff"
                                                font.pixelSize: dp(12)
                                                font.wordSpacing : 1.5
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: modelData[0]
                                            }
                                        }
                                    }

                                    Text {
                                        color: "#6999af"
                                        font.wordSpacing : 1.5
                                        text: modelData.title
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.pixelSize: dp(16)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressAndHold: {
                                        noteDeleteItem.noteDelete(modelData)
                                    }

                                    onClicked: {
                                        notes.currentNote = modelData
                                        subItem.loadUI("edit.qml")
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
            anchors.bottomMargin: mainWindow.height - dp(45)
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
                width: dp(15)
                anchors.top: parent.top
                anchors.topMargin: dp(15)
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dp(15)
                anchors.left: parent.left
                anchors.leftMargin: dp(20)
                source: "img/title/menu.png"
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: {
                        menuContainer.state = "opened"
                    }
                }
            }

            Rectangle {
                id: searchRect
                color: "#747575"
                radius: dp(8)
                anchors.bottomMargin: dp(10)
                anchors.topMargin: dp(10)
                anchors.leftMargin: dp(55)
                anchors.rightMargin: dp(55)
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
                    font.pixelSize: dp(12)
                    selectionColor: "#555555"
                    onAccepted: {
                        notes.filter = searchContent.text
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
                    spacing: dp(2)

                    Image {
                        width: dp(12)
                        height: dp(12)
                        anchors.verticalCenter: parent.verticalCenter
                        source: "img/title/search.png"
                    }

                    Text {
                        color: "#ffffff"
                        text: "搜索"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: dp(12)
                    }
                }
            }

            Image {
                id: addNoteImag
                width: dp(15)
                anchors.top: parent.top
                anchors.topMargin: dp(15)
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dp(15)
                anchors.right: parent.right
                anchors.rightMargin: dp(20)
                source: "img/title/addNote.png"

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: {
                        notes.currentNote = null
                        subItem.loadUI("edit.qml")
                    }
                }
            }

            Item {
                id: searchFocusItem
                height: mainItem.height - dp(45)

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
                        notes.filter = searchContent.text
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
                    PropertyChanges { target: menuItem; x: dp(-5); enabled: true }
                    PropertyChanges { target: menuCancelItem; opacity: 0.5; enabled: true }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: menuItem; x: dp(-250); enabled: false }
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
                anchors.leftMargin: dp(-5)


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
                width: dp(250)
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                x: dp(-250)

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    radius: dp(5)
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
                    height: dp(500)
                    source: "img/menu/menu.png"

                    Column {
                        id: menuColumn
                        anchors.topMargin: dp(80)
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top

                        Row {
                            id: innerMenuRow
                            height: dp(100)
                            anchors.leftMargin: dp(20)
                            spacing: dp(15)
                            anchors.right: parent.right
                            anchors.left: parent.left

                            Image {
                                id: userPhotoImage
                                width: dp(70)
                                height: dp(70)
                                x: dp(20)
                                y: dp(15)

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
                                y: dp(15)
                                spacing: dp(15)

                                Text {
                                    id: userNameInformationText
                                    text: notes.user.length == 0 ? "未登陆" : notes.user
                                    color: "#ffffff"
                                    font.pixelSize: dp(24)
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            userItemContainer.state = "login"
                                            /*if (notes.user.length == 0)
                                            {
                                                userItemContainer.state = "login"
                                            }
                                            else//注销
                                            {
                                                userPhotoImage.source = "img/title/null.png"
                                                //userNoteNumberText.text = "笔记 0项"
                                            }*/
                                        }
                                    }
                                }
                                Text {
                                    id: userNoteNumberText
                                    text: "笔记"+notes.noteCount+"项"//用户笔记数量
                                    color: "#747474"

                                }
                            }
                        }

                        Column {
                            id: innerMenuColumn
                            height: dp(45)
                            spacing: dp(10)
                            anchors.leftMargin: dp(20)
                            anchors.right: parent.right
                            anchors.left: parent.left

                            Rectangle {
                                id: innerCutLineRectangle
                                width: dp(215)
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
                            height: dp(100)
                            anchors.leftMargin: dp(20)
                            anchors.right: parent.right
                            anchors.left: parent.left

                        }
                    }
                }

                Item {
                    id: footerMenuItem
                    height: dp(40)
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
                        spacing: dp(15)
                        anchors.leftMargin: dp(20)

                        /*Image {
                            id: footerSettingImage
                            width: dp(20)
                            height: dp(20)
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/menu/setting.png"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    //subItem.loadUI("test.qml")//写崩了。。。
                                }
                            }
                        }*/

                        Image {
                            id: footerUploadImage
                            width: dp(30)
                            height: dp(20)
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/menu/upload.png"
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    notes.sync();
                                }
                            }
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
                    PropertyChanges { target: userItemMask; enabled: true }
                },
                State {
                    name: "closed"
                    PropertyChanges { target: userStatement; opacity: 0; enabled: false }
                    PropertyChanges { target: userRegister; opacity: 0; enabled: false }
                    PropertyChanges { target: userCancelItem; opacity: 0; enabled: false }
                    PropertyChanges { target: userItemMask; enabled: false }
                },
                State {
                    name: "register"
                    PropertyChanges { target: userStatement; opacity: 0; enabled: false }
                    PropertyChanges { target: userRegister; opacity: 1; enabled: true }
                    PropertyChanges { target: userCancelItem; opacity: 0.5; enabled: true }
                    PropertyChanges { target: userItemMask; enabled: true }
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
                id: userItemMask

                width: dp(200)
                height: dp(300)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                }

            }

            Item {
                id: userStatement

                width: dp(200)
                height: dp(300)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Connections {
                    target: notes
                    onLoginFinished: {
                        if(userItemContainer.state == "login")
                        {
                            noticeItem.notify(success ? "登录成功" : "登录失败，请检查后再试");
                            userStatement.enabled = true;
                            if(success)userItemContainer.state = "closed"
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent

                    radius: dp(8)

                    color: "#606060"

                    opacity: 0.9
                }

                MouseArea {
                    anchors.fill: parent
                }

                Column {
                    id: userLoginInfo
                    anchors.top: parent.top
                    anchors.topMargin: dp(40)
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    spacing: dp(40)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "用户登录"
                        color: "#ffffff"
                        font.pixelSize: dp(20)
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: dp(60)
                            horizontalAlignment: Text.AlignRight
                            text: "用户名："
                            color: "#ffffff"
                            font.pixelSize: dp(16)
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: dp(100)
                            height: dp(20)

                            TextInput {
                                id: userName
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: dp(16)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: dp(60)
                            horizontalAlignment: Text.AlignRight
                            text: "密码："
                            color: "#ffffff"
                            font.pixelSize: dp(16)
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: dp(100)
                            height: dp(20)

                            TextInput {
                                id: userPasswd
                                echoMode: TextInput.Password
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: dp(16)
                            }
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: dp(20)
                        Rectangle {
                            id: loginSubmitButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter

                                text: "登陆"
                            }

                            color: "#ffffff"
                            width: dp(40)
                            height: dp(20)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if(userName.text.length > 0)
                                    {
                                        userStatement.enabled = false;
                                        notes.loginUser(userName.text, userPasswd.text);
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: registerButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter

                                text: "注册"
                            }

                            color: "#ffffff"
                            width: dp(40)
                            height: dp(20)

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

                width: dp(240)
                height: dp(400)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Connections {
                    target: notes
                    onLoginFinished: {
                        if(userItemContainer.state == "register")
                        {
                            noticeItem.notify(success ? "注册成功" : "注册失败，请更换用户名再试");
                            userRegister.enabled = true;
                            if(success)userItemContainer.state = "closed"
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent

                    radius: dp(8)

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
                    anchors.topMargin: dp(40)
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left

                    spacing: dp(40)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "用户注册"
                        color: "#ffffff"
                        font.pixelSize: dp(20)
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: dp(80)
                            horizontalAlignment: Text.AlignRight
                            text: "用户名："
                            color: "#ffffff"
                            font.pixelSize: dp(16)
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: dp(120)
                            height: dp(20)

                            TextInput {
                                id: registerUserName
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: dp(16)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: dp(80)
                            horizontalAlignment: Text.AlignRight
                            text: "密码："
                            color: "#ffffff"
                            font.pixelSize: dp(16)
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: dp(120)
                            height: dp(20)

                            TextInput {
                                id: registerUserPasswd
                                echoMode: TextInput.Password
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: dp(16)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: dp(80)
                            horizontalAlignment: Text.AlignRight
                            text: "再次输入："
                            color: "#ffffff"
                            font.pixelSize: dp(16)
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: dp(120)
                            height: dp(20)

                            TextInput {
                                id: registerUserPasswdTwo
                                echoMode: TextInput.Password
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: dp(16)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: dp(80)
                            horizontalAlignment: Text.AlignRight
                            text: "电话号码："
                            color: "#ffffff"
                            font.pixelSize: dp(16)
                        }

                        Rectangle {
                            color: "#ffffff"

                            width: dp(120)
                            height: dp(20)

                            TextInput {
                                id: registerUserPhoneNumber
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: dp(16)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: dp(20)
                        Rectangle {
                            id: registerSubmitButton

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter

                                text: "注册"
                            }

                            color: "#ffffff"
                            width: dp(40)
                            height: dp(20)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (registerUserPasswd.text == registerUserPasswdTwo.text  &&
                                            registerUserPasswd.text.length > 0 && registerUserName.text.length > 0)
                                    {
                                        //注册行为
                                        // userItemContainer.state = "login"
                                        userRegister.enabled = false;
                                        notes.registerUser(registerUserName.text, registerUserPasswd.text, registerUserPhoneNumber.text);
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
                                anchors.verticalCenter: parent.verticalCenter

                                text: "重置"
                            }

                            color: "#ffffff"
                            width: dp(40)
                            height: dp(20)

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
            testLoader.source = url
            subItem.state = "opened"
        }

        Loader {
            id: testLoader
            //source: "test.qml"
            anchors.fill: parent
        }

        Connections {
            target: testLoader.item
            onExit: {
                subItem.enabled = false
                subItem.state = "closed"
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
                    subItem.enabled = false
                    subItem.state = "closed"
                }
            }

        }*/

    }

    Item {
        id: addGenre

        function add()
        {
            addGenre.state = "adding"
        }
        anchors.fill: parent

        state: "closed"
        states: [
            State {
                name: "adding"
                PropertyChanges { target: addGenre; opacity: 1; enabled: true }
            },
            State {
                name: "closed"
                PropertyChanges { target: addGenre; opacity: 0; enabled: false }
            }
        ]

        transitions: [
            Transition {
                to: "*"
                PropertyAnimation {
                    target: addGenre
                    duration: 100; properties: "opacity"; easing.type: Easing.Linear
                }
            }
        ]

        MouseArea {
            anchors.fill: parent
            onClicked: {
                addGenre.state = "closed"
            }
        }

        Rectangle {
            color: "#262626"
            anchors.fill: parent
            opacity: 0.5
        }

        Rectangle {
            id: addingGenreRectangle
            color: "#ffffff"
            radius: dp(8)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
            width: dp(200)
            height: dp(100)

            TextInput {
                id: addingGenreText
                color: "#979797"
                selectionColor: "#555555"
                anchors.verticalCenterOffset: -14
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    addingGenreText.focus = true
                }
            }
        }
        Rectangle {
            anchors.left: addingGenreRectangle.left
            anchors.right: addingGenreRectangle.right
            anchors.bottom: addingGenreRectangle.bottom
            anchors.bottomMargin: dp(5)
            height: addingGenreRectangle.height / 4
            color: "#1685f8"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dp(-5)
                anchors.top: parent.top
                radius: dp(5)
                color: "#1685f8"

                Text {
                    color: "#ffffff"
                    font.pixelSize: dp(14)
                    text: "添加"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (addingGenreText.text != "")
                    {
                        notes.addGenre(addingGenreText.text)
                        addingGenreText.text = ""
                        addingGenreText.focus = false
                        addGenre.state = "closed"
                    }
                    else
                    {
                        addingGenreText.text = ""
                        addingGenreText.focus = true
                        noticeItem.notify("分类名不能为空！")
                    }
                }
            }
        }
    }

    Item {
        id: noteDeleteItem

        property Note deletingNote: null

        function noteDelete(note)
        {
            deletingNote = note
            noteDeleteText.text = "删除“" + note.title + "”？"
            noteDeleteItem.state = "noteDelete"
        }
        anchors.fill: parent

        state: "closed"
        states: [
            State {
                name: "noteDelete"
                PropertyChanges { target: noteDeleteItem; opacity: 1; enabled: true }
            },
            State {
                name: "closed"
                PropertyChanges { target: noteDeleteItem; opacity: 0; enabled: false }
            }
        ]

        transitions: [
            Transition {
                to: "*"
                PropertyAnimation {
                    target: noteDeleteItem
                    duration: 100; properties: "opacity"; easing.type: Easing.Linear
                }
            }
        ]

        MouseArea {
            anchors.fill: parent
            onClicked: {
                noteDeleteItem.state = "closed"
            }
        }

        Rectangle {
            color: "#262626"
            anchors.fill: parent
            opacity: 0.5
        }

        Rectangle {
            id: noteDeleteRectangle
            color: "#262626"
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
            width: dp(200)
            height: dp(100)

            Text {
                id: noteDeleteText
                color: "#ffffff"
                anchors.verticalCenterOffset: -14
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                }
            }
        }
        Rectangle {
            anchors.left: noteDeleteRectangle.left
            anchors.right: noteDeleteRectangle.right
            anchors.bottom: noteDeleteRectangle.bottom
            anchors.bottomMargin: dp(5)
            height: noteDeleteRectangle.height / 4
            color: "red"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dp(-5)
                anchors.top: parent.top
                radius: dp(5)
                color: "red"

                Text {
                    color: "#ffffff"
                    font.pixelSize: dp(14)
                    text: "删除"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        notes.deleteNote(noteDeleteItem.deletingNote)
                        noteDeleteItem.deletingNote = null
                        noteDeleteItem.state = "closed"
                    }
                }
            }
        }
    }

    Item {
        id: classDeleteItem

        property string deletingNoteList: ""

        function classDelete(noteList)
        {
            deletingNoteList = noteList
            classDeleteText.text = "删除“" + noteList + "”？"
            classDeleteItem.state = "classDelete"
        }
        anchors.fill: parent

        state: "closed"
        states: [
            State {
                name: "classDelete"
                PropertyChanges { target: classDeleteItem; opacity: 1; enabled: true }
            },
            State {
                name: "closed"
                PropertyChanges { target: classDeleteItem; opacity: 0; enabled: false }
            }
        ]

        transitions: [
            Transition {
                to: "*"
                PropertyAnimation {
                    target: classDeleteItem
                    duration: 100; properties: "opacity"; easing.type: Easing.Linear
                }
            }
        ]

        MouseArea {
            anchors.fill: parent
            onClicked: {
                classDeleteItem.state = "closed"
            }
        }

        Rectangle {
            color: "#262626"
            anchors.fill: parent
            opacity: 0.5
        }

        Rectangle {
            id: classDeleteRectangle
            color: "#262626"
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
            width: dp(200)
            height: dp(100)

            Text {
                id: classDeleteText
                color: "#ffffff"
                anchors.verticalCenterOffset: -14
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                }
            }
        }
        Rectangle {
            anchors.left: classDeleteRectangle.left
            anchors.right: classDeleteRectangle.right
            anchors.bottom: classDeleteRectangle.bottom
            anchors.bottomMargin: dp(5)
            height: classDeleteRectangle.height / 4
            color: "red"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dp(-5)
                anchors.top: parent.top
                radius: dp(5)
                color: "red"

                Text {
                    color: "#ffffff"
                    font.pixelSize: dp(14)
                    text: "删除"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        notes.deleteGenre(classDeleteItem.deletingNoteList)

                        classDeleteItem.state = "closed"
                        classDeleteItem.deletingNoteList = ""
                    }
                }
            }
        }


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
            radius: dp(8)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
            width: dp(200)
            height: dp(150)

            Text {
                id: noticeText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: dp(15)
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
