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

    // 测试说明：去掉注释运行一次，本地就有记录生成，然后记得把注释加回来
    /*
    notes.createNote("软件项目管理", "写文档");
    notes.createNote("软件项目管理", "写代码");
    notes.createNote("软件项目管理", "做测试");
    notes.createNote("软件设计模式与体系结构", "分析CPPCHECK");
    notes.createNote("编译原理", "预习笔记！！！");
    notes.createNote("编译原理", "写作业");
    notes.createNote("编译原理", "张天利是个辣鸡");
    */

    QQmlApplicationEngine engine;
    QQmlContext *context=engine.rootContext();

    qmlRegisterType<Note>("LightNote.Note", 1, 0, "Note");

    context->setContextProperty("notes", &notes);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

