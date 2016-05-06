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
    , syncStatus(false)
    , syncCount(0)
    , syncTotal(1)
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
    if(syncStatus || currentUser.isEmpty())
        return;

    syncCount = 0;
    syncTotal = 1;
    syncStatus = true;
    emit syncProgressChanged();
    emit syncStatusChanged();

    currentNote = nullptr;
    emit currentNoteChanged();

    fullSave();

    QJsonObject objUser;
    objUser["userID"] = currentUser;
    req->get("brief", objUser, [this](const QJsonObject& data)
    {
        qDebug() << data;
        if(data.size() == 0 || !data["result"].toBool(true))
        {
            syncStatus = false;
            emit syncStatusChanged();
            return;
        }

        QMap<int, int> timeMap;
        QJsonArray arr = data["array"].toArray();
        for(int i=0; i<arr.size(); ++i)
        {
            QJsonObject brief = arr.at(i).toObject();
            timeMap[brief["noteID"].toInt()] = brief["lastEditTime"].toInt();
        }

        syncTotal = timeMap.size() + noteList.size() + deletedNotes.size() + 1; // 总项数向下逼近，不再增加，不低于已处理项数
        syncCount++;
        emit syncProgressChanged();

        QJsonObject objUser;
        objUser["userID"] = currentUser;

        QEventLoop wait;

        for(Note* note : noteList)
        {
            if(note->authorId.isEmpty())
                note->authorId = currentUser;

            if(note->webId == -1 || !timeMap.contains(note->webId))
            {
                qDebug() << "newing";
                req->get("newnote", objUser, [note, &wait](const QJsonObject& data)
                {
                    note->webId = data["noteID"].toInt(-1);
                    qDebug() << "newed " << note->webId;
                    QTimer::singleShot(0, &wait, SLOT(quit()));
                });
                wait.exec();
                if(note->webId == -1)
                {
                    qDebug() << "note #" << note->localId << " " << note->title << " get id failed";
                    continue;
                }
                qDebug() << "newnote done";
            }

            syncCount++;
            emit syncProgressChanged();

            int webTime = timeMap.value(note->webId, 0);
            if(note->webTime < webTime)
            {
                // 服务器的时间较新，下载笔记
                QJsonObject objID;
                objID["noteID"] = note->webId;
                qDebug() << "downloading " << note->webId;
                req->get("download", objID, [note, &wait](const QJsonObject& data)
                {
                    if(data.empty() || !data["result"].toBool())
                        return;
                    qDebug() << "downloaded " << note->webId;
                    note->read(data);
                    QTimer::singleShot(0, &wait, SLOT(quit()));
                });
                wait.exec();
                note->webTime = webTime;
                saveNote(note);
                qDebug() << "download done";
            }
            else if((note->webTime > webTime || note->webTime == 0) && note->authorId == currentUser)
            {
                // 本体时间较新，上传笔记，笔记作者必须是当前登录用户
                QJsonObject objNote;
                note->write(objNote);
                qDebug() << "uploading " << objNote;
                req->get("upload", objNote, [note, &wait](const QJsonObject& data)
                {
                    qDebug() << "uploaded " << note->webId;
                    note->webTime = data.value("lastEditTime").toInt(note->webTime);
                    QTimer::singleShot(0, &wait, SLOT(quit()));
                });
                wait.exec();
                saveNote(note);
                qDebug() << "upload done";
            }

            syncCount += timeMap.remove(note->webId);
            emit syncProgressChanged();

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
            syncCount++;
            emit syncProgressChanged();
        }
        for(int webId : deleted)
        {
            deletedNotes.remove(webId);
            syncCount+=timeMap.remove(webId);
        }
        emit syncProgressChanged();

        while(!timeMap.empty())
        {
            int webId = timeMap.firstKey();
            QJsonObject objID;
            objID["noteID"] = webId;
            qDebug() << "new downloading " << webId;
            req->get("download", objID, [this, &wait, &timeMap, webId](const QJsonObject& data)
            {
                qDebug() << "new downloaded " << data;
                Note* note = createNote(data);
                note->webTime = timeMap[webId];
                saveNote(note);
                QTimer::singleShot(0, &wait, SLOT(quit()));
            });
            wait.exec();
            timeMap.remove(webId);
            qDebug() << "new download done";
            syncCount++;
            emit syncProgressChanged();
        }

        syncCount = syncTotal;
        syncStatus = false;
        emit syncProgressChanged();
        emit syncStatusChanged();

        qDebug() << "Done.";

        setNotesChanged();

    });

}

double NoteList::syncProgress()
{
    return syncTotal<=0 ? 0 : syncCount>syncTotal ? 1 : (double)syncCount/syncTotal;
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
    saveIndex();
    setNotesChanged();
}

void NoteList::deleteGenre(QString genre)
{
    setSignalEnabled(false);
    genreSet.remove(genre);
    for (auto note : noteList)
    {
        if (note->genre == genre)
        {
            note->genre = "无分类";
            addGenre("无分类");
            saveNote(note);
        }
    }
    saveIndex();
    setSignalEnabled(true);
    setNotesChanged();
}

QList<QObject*> NoteList::getGenreNotesFiltered(QString genreName) const
{
    QList<QObject*> res;
    for(auto note : noteList)
    {
        if(note->genre == genreName && (filter.isEmpty() || note->title.contains(filter, Qt::CaseInsensitive)))
        {
            if(!selectedTags.empty())
            {
                for(auto tag : note->tags)
                {
                    if(selectedTags.contains(tag))
                    {
                        res.append(note);
                        break;
                    }
                }
            }
            else
            {
                res.append(note);
            }
        }
    }
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
    if(currentNote->authorId.isEmpty() && !currentUser.isEmpty())
        currentNote->authorId = currentUser;
    saveNote(currentNote);
    genreSet.insert(currentNote->genre);
    saveIndex();
    setNotesChanged();
}

void NoteList::applyNote(Note* note)
{
    if(note == nullptr)
        return;
    note->validate();
    if(note->authorId.isEmpty() && !currentUser.isEmpty())
        note->authorId = currentUser;
    genreSet.insert(note->genre);
    saveIndex();
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
            if(noteList[index]->webId != -1)
                deletedNotes.insert(noteList[index]->webId);
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

        currentUser = obj["user"].toString();

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

    saveIndex();
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

        obj.insert("user", currentUser);

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

void NoteList::toggleTag(QString tag, bool on)
{
    if(on)selectedTags.insert(tag);
    else selectedTags.remove(tag);
    setNotesChanged();
}

void NoteList::resetToggleTag()
{
    selectedTags.clear();
    setNotesChanged();
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
        obj.insert("user", currentUser);
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
        saveIndex();
        emit userChanged();
    }
    emit loginFinished(success);
}



