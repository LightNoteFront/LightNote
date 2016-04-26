TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp \
    note.cpp \
    notelist.cpp \
    webrequest.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    note.h \
    notelist.h \
    webrequest.h

DISTFILES +=

