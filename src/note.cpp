#include "note.h"

#include <QJsonObject>

Note::Note(QObject *parent)
    : QObject(parent)
{

}

Note::Note(const Note& other)
    : QObject(other.parent())
    , webId(other.webId)
    , title(other.title)
    , genre(other.genre)
    , tags(other.tags)
    , content(other.content)
{

}

void Note::read(const QJsonObject& json)
{

}

void Note::write(QJsonObject& json) const
{

}

Note& Note::operator=(const Note& other)
{
    webId = other.webId;
    title = other.title;
    genre = other.genre;
    tags = other.tags;
    content = other.content;
    return *this;
}

bool Note::operator==(const Note&)
{
    return false;
}

void Note::setText(const QQuickTextDocument& doc)
{

}

QString Note::text()
{

}

/*
QTextDocument& Note::text()
{
    if(content == nullptr)
        content = new QTextDocument(this);
    return *content;
}*/

