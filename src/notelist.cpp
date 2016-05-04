#include "notelist.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDir>
#include <QSettings>
#include <QSemaphore>
#include <QTimer>

NoteList::NoteList(WebRequest* request, QObject *parent)
    : QObject(parent)
    , currentNote(nullptr)
    , emptyNote(nullptr)
    , signalEnabled(true)
    , req(request)
{
    fullLoad();

    colorList << "aqua" << "blueviolet" << "chocolate" << "crimson" << "darkblue" << "dodgerblue"
              << "forestgreen" << "firebrick" << "gold" << "hotpink" << "lightseagreen" << "lime"
              << "limegreen" << "lightsalmon" << "mediumspringgreen" << "mediumpurple" << "navy"
              << "olive" << "orange" << "orangered" << "peru" << "plum" << "purple" << "red"
              << "salmon" << "seagreen" << "steelblue" << "tomato" << "violet";

    if(req != nullptr)
    {
        req->registerUrl("login", "Login");
        req->registerUrl("register", "NewUser");
        req->registerUrl("newnote", "NewNote");
        req->registerUrl("deletenote", "DeleteNote");
        req->registerUrl("brief", "Brief");
        req->registerUrl("download", "Sync_Download");
        req->registerUrl("upload", "Sync_Upload");
    }

    currentUser = QSettings("").property("user").toString();

}

NoteList::~NoteList()
{
    clear();
}

void NoteList::clear()
{
    qDeleteAll(noteList);
    noteList.clear();
    genreSet.clear();
    currentNote = nullptr;
    if(emptyNote != nullptr)
        delete emptyNote;
    emptyNote = nullptr;
    signalEnabled = true;
}

void NoteList::sync()
{
    if(currentUser.isEmpty())
        return;

    currentNote = nullptr;
    emit currentNoteChanged();

    fullSave();

    QJsonObject objUser;
    objUser["userID"] = currentUser;
    req->get("brief", objUser, [this](const QJsonObject& data)
    {
        qDebug() << data;
        if(data.size() == 0 || !data["result"].toBool(true))
            return;

        QMap<int, int> timeMap;
        QJsonArray arr = data["array"].toArray();
        for(int i=0; i<arr.size(); ++i)
        {
            QJsonObject brief = arr.at(i).toObject();
            timeMap[brief["noteID"].toInt()] = brief["lastEditTime"].toInt();
        }

        QJsonObject objUser;
        objUser["userID"] = currentUser;

        QEventLoop wait;

        for(Note* note : noteList)
        {
            if(note->authorId.isEmpty())
                note->authorId = currentUser;

            if(note->webId == -1 || !timeMap.contains(note->webId))
            {
                req->get("newnote", objUser, [note, &wait](const QJsonObject& data)
                {
                    qDebug() << "newed " << data;
                    note->webId = data["noteID"].toInt(-1);
                    QTimer::singleShot(0, &wait, SLOT(quit()));
                });
                wait.exec();
                if(note->webId == -1)
                {
                    qDebug() << "note #" << note->localId << " " << note->title << " get id failed";
                    continue;
                }
            }

            int webTime = timeMap.value(note->webId, 0);
            if(note->webTime < webTime)
            {
                // 服务器的时间较新，下载笔记
                QJsonObject objID;
                objID["noteID"] = note->webId;
                req->get("download", objID, [note, &wait](const QJsonObject& data)
                {
                    qDebug() << "downloaded " << data;
                    note->read(data);
                    QTimer::singleShot(0, &wait, SLOT(quit()));
                });
                wait.exec();
                note->webTime = webTime;
                saveNote(note);
            }
            else if((note->webTime > webTime || note->webTime == 0) && note->authorId == currentUser)
            {
                // 本体时间较新，上传笔记，笔记作者必须是当前登录用户
                QJsonObject objNote;
                note->write(objNote);
                qDebug() << "uploading " << objNote;
                req->get("upload", objNote, [note, &wait](const QJsonObject& data)
                {
                    qDebug() << "uploaded " << data;
                    note->webTime = data.value("lastEditTime").toInt(note->webTime);
                    QTimer::singleShot(0, &wait, SLOT(quit()));
                });
                wait.exec();
                saveNote(note);
            }

            timeMap.remove(note->webId);

        }

        for(int webId : timeMap)
        {
            QJsonObject objID;
            objID["noteID"] = webId;
            req->get("download", objID, [this, &wait, &timeMap, webId](const QJsonObject& data)
            {
                qDebug() << "new downloaded " << data;
                Note* note = createNote(data);
                note->webTime = timeMap[webId];
                saveNote(note);
                QTimer::singleShot(0, &wait, SLOT(quit()));
            });
            wait.exec();
        }

        QList<int> deleted;
        for(int webId : deletedNotes)
        {
            // 被删除的笔记
            QJsonObject objID;
            objID["noteID"] = webId;
            req->get("deletenote", objID, [&wait, &deleted, webId](const QJsonObject& data)
            {
                qDebug() << "deleted " << data;
                if(data["result"].toBool())
                    deleted.append(webId);
                QTimer::singleShot(0, &wait, SLOT(quit()));
            });
            wait.exec();
        }
        for(int webId : deleted)
        {
            deletedNotes.remove(webId);
        }

        setNotesChanged();

    });

}

QStringList NoteList::getGenreList() const
{
    auto list = genreSet.toList();
    qSort(list);
    return list;
}

void NoteList::addGenre(QString genre)
{
    genreSet.insert(genre);
    setNotesChanged();
}

QList<QObject*> NoteList::getGenreNotesFiltered(QString genreName) const
{
    QList<QObject*> res;
    for(auto note : noteList)
        if(note->genre == genreName && (filter.isEmpty() || note->title.contains(filter, Qt::CaseInsensitive)))
            res.append(note);
    return res;
}

QList<QObject*> NoteList::getGenreNotes(QString genreName) const
{
    QList<QObject*> res;
    for(auto note : noteList)
        if(note->genre == genreName)
            res.append(note);
    return res;
}

QList<QObject*> NoteList::getNotes() const
{
    QList<QObject*> res;
    for(auto note : noteList)
        if(filter.isEmpty() || note->title.contains(filter, Qt::CaseInsensitive))
            res.append(note);
    return res;
}

int NoteList::noteCount() const
{
    return noteList.count();
}

Note* NoteList::createNote(QString genre, QString title, int id)
{
    Note* res = new Note(this, id);
    res->genre = genre;
    res->title = title;
    addNote(res);
    genreSet.insert(genre);
    setNotesChanged();
    connect(res, SIGNAL(infoChanged()), this, SLOT(setNotesChanged()));
    return res;
}

Note* NoteList::createNote(const QJsonObject& json, int id)
{
    Note* res = new Note(this, id);
    res->read(json);
    res->validate();
    addNote(res);
    genreSet.insert(res->genre);
    setNotesChanged();
    connect(res, SIGNAL(infoChanged()), this, SLOT(setNotesChanged()));
    return res;
}

void NoteList::setSignalEnabled(bool enabled)
{
    signalEnabled = enabled;
}

Note* NoteList::getCurrentNote() const
{
    return currentNote;
}

void NoteList::setCurrentNote(Note* note)
{
    //noteList.removeAll(note);
    currentNote = note;
    emit currentNoteChanged();
}

Note* NoteList::createEmptyNote()
{
    if(emptyNote != nullptr)
        delete emptyNote;
    emptyNote = new Note(this);
    currentNote = emptyNote;
    return emptyNote;
}

void NoteList::applyNote()
{
    if(currentNote == nullptr)
        return;
    if(emptyNote == currentNote)
    {
        addNote(emptyNote);
        emptyNote = nullptr;
    }
    currentNote->webTime++;
    currentNote->validate();
    saveNote(currentNote);
    genreSet.insert(currentNote->genre);
    setNotesChanged();
}

void NoteList::applyNote(Note* note)
{
    if(note == nullptr)
        return;
    note->validate();
    genreSet.insert(note->genre);
    setNotesChanged();
}

void NoteList::deleteNote(Note* note)
{
    if(note == nullptr)
        return;
    if(note == currentNote)
        currentNote = nullptr;
    if(note == emptyNote)
    {
        delete emptyNote;
        emptyNote = nullptr;
    }
    else
    {
        int index = noteList.indexOf(note);
        if(index != -1)
        {
            deletedNotes.insert(index);
            delete noteList[index];
            noteList.removeAt(index);
            saveIndex();
            QFile::remove(QString("notes/%0.json").arg(note->localId));
            setNotesChanged();
        }
    }
}

void NoteList::fullLoad()
{
    if(!QDir("notes/").exists())
        return;

    setSignalEnabled(false);

    clear();

    QFile file("notelist.json");
    if(file.open(QFile::ReadOnly))
    {
        QByteArray raw = file.readAll();
        file.close();

        QJsonObject obj = QJsonDocument::fromJson(raw).object();
        QJsonArray arrIdx = obj["index"].toArray();
        QJsonArray arrGenre = obj["genre"].toArray();
        QJsonArray arrDel = obj["deleted"].toArray();

        for(int i=0; i<arrIdx.size(); ++i)
        {
            int id = arrIdx.at(i).toInt(-1);
            if(id == -1)continue;
            QFile filenote(QString("notes/%0.json").arg(id));
            if(filenote.open(QFile::ReadOnly))
            {
                raw = filenote.readAll();
                filenote.close();
                createNote(QJsonDocument::fromJson(raw).object(), id);
            }
        }

        for(int i=0; i<arrGenre.size(); ++i)
        {
            genreSet.insert(arrIdx.at(i).toString(""));
        }
        genreSet.remove("");

        deletedNotes.clear();
        for(int i=0; i<arrDel.size(); ++i)
        {
            deletedNotes.insert(arrDel.at(i).toInt(-1));
        }
        deletedNotes.remove(-1);

    }

    setSignalEnabled(true);
    setNotesChanged();

}

void NoteList::fullSave()
{
    if(!QDir("notes/").exists() && !QDir().mkdir("notes"))
        return;

    QFile file("notelist.json");
    if(file.open(QFile::WriteOnly))
    {
        QJsonObject obj;
        QJsonArray arrIdx, arrGenre, arrDel;

        for(int i=0; i<noteList.size(); ++i)
        {
            if(saveNote(noteList[i]))
                arrIdx.append(noteList[i]->localId);
        }

        for(auto genre : genreSet)
            arrGenre.append(genre);

        for(int id : deletedNotes)
            arrDel.append(id);

        obj.insert("index", arrIdx);
        obj.insert("genre", arrGenre);
        obj.insert("deleted", arrDel);

        QJsonDocument doc(obj);
        file.write(doc.toJson());
        file.close();

    }

}

QStringList NoteList::getPopularTags(int limit) const
{
    if(limit<=0) return QStringList();
    QStringList res;
    for(auto tag : tagPop)
    {
        res.append(tag);
        if(limit--<=0)
            break;
    }
    return res;
}

void NoteList::addPopularTag(QString tag, int weight)
{
    int pop = popTags[tag];
    popTags[tag] = pop + weight;
    tagPop.remove(qMakePair(pop, tag));
    tagPop[qMakePair(pop + weight, tag)] = tag;
    while(tagPop.size() > maxPopTag)
    {
        auto firstKey = tagPop.firstKey();
        tagPop.remove(firstKey);
        popTags.remove(firstKey.second);
    }
    emit popularTagsChanged();
}

QString NoteList::getColor(int index) const
{
    return colorList[index%colorList.size()];
}

void NoteList::loginUser(QString username, QString password)
{
    QJsonObject obj;
    obj["userID"] = username;
    obj["userPassword"] = password;
    req->get("login", obj, [this, username](const QJsonObject& reply)
    {
        bool result = reply["result"].toBool();
        setCurrentUser(username, result);
    });
}

void NoteList::registerUser(QString username, QString password, QString phoneno)
{
    QJsonObject obj;
    obj["userID"] = username;
    obj["userPassword"] = password;
    obj["userPhoneNumber"] = phoneno;
    req->get("register", obj, [this, username](const QJsonObject& reply)
    {
        bool result = reply["result"].toBool();
        setCurrentUser(username, result);
    });
}

void NoteList::setNotesChanged()
{
    if(signalEnabled)
        emit notesChanged();
}

void NoteList::addNote(Note* note)
{
    noteList.append(note);
    for(auto tag : note->tags)
        addPopularTag(tag, 1);
    if(note->localId == -1)
        note->localId = noteList.length();
    saveIndex();
    saveNote(note);
    setNotesChanged();
}

bool NoteList::loadNote(Note* note)
{
    QFile filenote(QString("notes/%0.json").arg(note->localId));
    if(filenote.open(QFile::ReadOnly))
    {
        QByteArray raw = filenote.readAll();
        filenote.close();
        note->read(QJsonDocument::fromJson(raw).object());
        setNotesChanged();
        return true;
    }
    return false;
}

bool NoteList::saveNote(Note* note)
{
    QFile filenote(QString("notes/%0.json").arg(note->localId));
    if(filenote.open(QFile::WriteOnly))
    {
        QJsonObject json;
        note->write(json);
        QJsonDocument doc(json);
        filenote.write(doc.toJson());
        filenote.close();
        return true;
    }
    return false;
}

bool NoteList::saveIndex()
{
    if(!QDir("notes/").exists() && !QDir().mkdir("notes"))
        return false;
    QFile file("notelist.json");
    if(file.open(QFile::WriteOnly))
    {
        QJsonObject obj;
        QJsonArray arrIdx, arrGenre, arrDel;
        for(int i=0; i<noteList.size(); ++i)
            arrIdx.append(noteList[i]->localId);
        for(auto genre : genreSet)
            arrGenre.append(genre);
        for(int id : deletedNotes)
            arrDel.append(id);
        obj.insert("index", arrIdx);
        obj.insert("genre", arrGenre);
        obj.insert("deleted", arrDel);
        QJsonDocument doc(obj);
        file.write(doc.toJson());
        file.close();
        return true;
    }
    return false;
}

void NoteList::setCurrentUser(QString name, bool success)
{
    if(success)
    {
        currentUser = name;
        QSettings().setProperty("user", currentUser);
        emit userChanged();
    }
    emit loginFinished(success);
}



