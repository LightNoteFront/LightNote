#include "notelist.h"

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDir>

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
    currentNote = nullptr;
    emit currentNoteChanged();

    fullSave();

    req->send("http://localhost/test.json", QJsonObject(), [this](const QJsonObject& data)
    {
        createNote(data);
    });

    setNotesChanged();
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

        QJsonArray arr = QJsonDocument::fromJson(raw).array();

        for(int i=0; i<arr.size(); ++i)
        {
            int id = arr.at(i).toInt(-1);
            if(id == -1)continue;
            QFile filenote(QString("notes/%0.json").arg(id));
            if(filenote.open(QFile::ReadOnly))
            {
                raw = filenote.readAll();
                filenote.close();
                createNote(QJsonDocument::fromJson(raw).object(), id);
            }
        }

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
        QJsonArray arr;

        for(int i=0; i<noteList.size(); ++i)
        {
            if(saveNote(noteList[i]))
                arr.append(noteList[i]->localId);
        }

        QJsonDocument doc(arr);
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
        QJsonArray arr;
        for(int i=0; i<noteList.size(); ++i)
            arr.append(noteList[i]->localId);
        QJsonDocument doc(arr);
        file.write(doc.toJson());
        file.close();
        return true;
    }
    return false;
}



