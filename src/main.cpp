#include <QGuiApplication>
#include <QJsonDocument>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QScreen>

#include "notelist.h"
#include "webrequest.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    WebRequest request("http://133.130.125.201:3000/");
    NoteList notes(&request);

    /*/
    QJsonObject json;
    json.insert("userID", "test");
    json.insert("userPassword", "password");
    //json.insert("userPhoneNumber", "13333333333");

    request.send("http://10.50.141.13:3000/Login", json, [](const QJsonObject& data)
    {
        QJsonDocument doc(data);
        qDebug() << doc.toJson();
        qDebug() << data["result"].toBool();

    });
    //*/

    // 测试说明：去掉注释运行一次，本地就有记录生成，然后记得把注释加回来
    /*/
    notes.createNote("软件项目管理", "写文档");
    notes.createNote("软件项目管理", "写代码");
    notes.createNote("软件项目管理", "做测试");
    notes.createNote("软件设计模式与体系结构", "分析CPPCHECK");
    notes.createNote("编译原理", "预习笔记！！！");
    notes.createNote("编译原理", "写作业");
    notes.createNote("编译原理", "张天利是个辣鸡");
    //*/

    QQmlApplicationEngine engine;
    QQmlContext *context=engine.rootContext();

    qmlRegisterType<Note>("LightNote.Note", 1, 0, "Note");

    qDebug() << QGuiApplication::primaryScreen()->physicalDotsPerInch();

    double screenScale = 1;
#ifdef Q_OS_MAC
    screenScale = 0.8;
#endif
#ifdef Q_OS_WIN32
    screenScale = 1.2;
#endif

    context->setContextProperty("notes", &notes);
    context->setContextProperty("devicePixelRatio", QGuiApplication::primaryScreen()->physicalDotsPerInch() / 160 *
                                QGuiApplication::primaryScreen()->devicePixelRatio() * screenScale);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

