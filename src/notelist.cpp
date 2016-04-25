#include "notelist.h"

NoteList::NoteList(QObject *parent)
    : QObject(parent)
    , signalEnabled(true)
{

}

NoteList::~NoteList()
{
    qDeleteAll(noteList);
    noteList.clear();
}

void NoteList::sync()
{
    emit notesChanged();
}

QStringList NoteList::getGenreList() const
{
    QSet<QString> genreSet;
    for(auto note : noteList)
        genreSet.insert(note->genre);
    auto list = genreSet.toList();
    qSort(list);
    return list;
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
        res.append(note);
    return res;
}

Note* NoteList::createNote(QString genre, QString title)
{
    Note* res = new Note();
    res->genre = genre;
    res->title = title;
    noteList.push_back(res);
    setNotesChanged();
    connect(res, SIGNAL(infoChanged()), this, SLOT(setNotesChanged()));
    return res;
}

Note* NoteList::createNote(const QJsonObject& json)
{
    Note* res = new Note();
    res->read(json);
    noteList.push_back(res);
    setNotesChanged();
    connect(res, SIGNAL(infoChanged()), this, SLOT(setNotesChanged()));
    return res;
}

void NoteList::setSignalEnabled(bool enabled)
{
    signalEnabled = enabled;
}

void NoteList::setNotesChanged()
{
    if(signalEnabled) emit notesChanged();
}



