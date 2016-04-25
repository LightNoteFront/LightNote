#include "note.h"

#include <QJsonArray>
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
    webId = json.value("webid").toString();
    title = json.value("title").toString();
    genre = json.value("genre").toString();
    tags.clear();
    auto arrtag = json.value("tags").toArray();
    for(auto var : arrtag)
    {
        auto tag = var.toString();
        if(!tag.isNull())
            tags.append(tag);
    }
    content = QString::fromUtf8(QByteArray::fromBase64(json.value("content").toString().toUtf8()));
    emit infoChanged();
}

void Note::write(QJsonObject& json) const
{
    if(!webId.isNull())
        json.insert("webid", webId);
    json.insert("title", title);
    json.insert("genre", genre);
    json.insert("tags", QJsonArray::fromStringList(tags));
    json.insert("content", QString::fromUtf8(content.toUtf8().toBase64()));
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
    content = doc.textDocument()->toPlainText();
}

const QString& Note::text()
{
    return content;
}

/*
QTextDocument& Note::text()
{
    if(content == nullptr)
        content = new QTextDocument(this);
    return *content;
}*/

