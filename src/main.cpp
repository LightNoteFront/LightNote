#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "notelist.h"

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

