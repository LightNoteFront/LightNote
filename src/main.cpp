#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "notelist.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    NoteList notes;
    notes.createNote("A", "ok");
    notes.createNote("A", "1");
    notes.createNote("A", "2");
    notes.createNote("C", "3");
    notes.createNote("C", "4");
    notes.createNote("B", "5");
    notes.createNote("C", "6");

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

