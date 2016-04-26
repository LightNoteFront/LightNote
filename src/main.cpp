#include <QGuiApplication>
#include <QJsonDocument>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "notelist.h"
#include "webrequest.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    NoteList notes;
    notes.createNote("软件项目管理", "写文档");
    notes.createNote("软件项目管理", "写代码");
    notes.createNote("软件项目管理", "做测试");
    notes.createNote("软件设计模式与体系结构", "分析CPPCHECK");
    notes.createNote("编译原理", "预习笔记！！！");
    notes.createNote("编译原理", "写作业");
    notes.createNote("编译原理", "张天利是个辣鸡");

    // 程序增加笔记

    // 文件增加笔记
    QFile file("out.json");
    if(file.open(QFile::ReadOnly))
    {
        QByteArray raw = file.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(raw);
        notes.createNote(doc.object());
        file.close();
    }

    // 网络增加笔记
    WebRequest req("http://localhost/");
    req.send("http://localhost/test.json", QJsonObject(), [&notes](const QJsonObject& data)
    {
        notes.createNote(data);
    });

    QQmlApplicationEngine engine;
    QQmlContext *context=engine.rootContext();

    QStringList testList;
    testList << "asdasd" << "dsadsa" << "hahaha" << "123456" << "asdasdasdasd";
    testList << "asdasd" << "dsadsa" << "hahaha" << "123456" << "asdasdasdasd";
    testList << "asdasd" << "dsadsa" << "hahaha" << "123456" << "asdasdasdasd";
    testList << "asdasd" << "dsadsa" << "hahaha" << "123456" << "asdasdasdasd";
    testList << "asdasd" << "dsadsa" << "hahaha" << "123456" << "asdasdasdasd";
    testList << "asdasd" << "dsadsa" << "hahaha" << "123456" << "asdasdasdasd";

    context->setContextProperty("notes", &notes);
    context->setContextProperty("testList", QVariant::fromValue(testList));

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

