#include "note.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

Note::Note(QObject *parent, int id)
    : QObject(parent)
    , localId(id)
    , webId(-1)
    , webTime(0)
{

}

Note::Note(const Note& other)
    : QObject(other.parent())
    , localId(other.localId)
    , webId(other.webId)
    , webTime(other.webTime)
    , title(other.title)
    , genre(other.genre)
    , tags(other.tags)
    , authorId(other.authorId)
    , content(other.content)
{

}

void Note::read(const QJsonObject& json)
{
    webId = json.value("noteID").toInt(-1);
    authorId = json.value("userID").toString();

    QByteArray raw = QByteArray::fromBase64(json.value("content").toString().toUtf8());
    QJsonObject objContent = QJsonDocument::fromJson(raw).object();

    tags.clear();
    auto arrtag = objContent.value("tags").toArray();
    for(auto var : arrtag)
    {
        auto tag = var.toString();
        if(!tag.isNull())
            tags.append(tag);
    }

    webTime = objContent.value("webTime").toInt(0);
    genre = objContent.value("genre").toString();
    title = objContent.value("title").toString();
    content = QString::fromUtf8(QByteArray::fromBase64(objContent.value("text").toString().toUtf8()));
    emit infoChanged();
}

void Note::write(QJsonObject& json) const
{
    if(webId != -1)
        json.insert("noteID", webId);
    if(!authorId.isNull())
        json.insert("userID", authorId);
    QJsonArray arrtag = QJsonArray::fromStringList(tags);
    json.insert("tags", arrtag);
    json.insert("genre", genre);

    QJsonObject objContent;
    objContent.insert("webTime", webTime);
    objContent.insert("tags", arrtag);
    objContent.insert("genre", genre);
    objContent.insert("title", title);
    objContent.insert("text", QString::fromUtf8(content.toUtf8().toBase64()));
    QJsonDocument docContent(objContent);
    //qDebug() << docContent;
    json.insert("content", QString::fromUtf8(docContent.toJson().toBase64()));
}

Note& Note::operator=(const Note& other)
{
    webId = other.webId;
    webTime = other.webTime;
    title = other.title;
    genre = other.genre;
    tags = other.tags;
    authorId = other.authorId;
    content = other.content;
    return *this;
}

bool Note::operator==(const Note& other)
{
    if(webId == -1 && other.webId == -1)
        return localId == other.localId;
    return webId == other.webId;
}

void Note::setText(const QQuickTextDocument& doc)
{
    content = doc.textDocument()->toPlainText();
}

void Note::validate()
{
    if(genre.isEmpty())
        genre = "无分类";
    if(title.isEmpty())
        title = "无标题";
}

/*
QTextDocument& Note::text()
{
    if(content == nullptr)
        content = new QTextDocument(this);
    return *content;
}*/

