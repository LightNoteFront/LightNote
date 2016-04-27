#include "notelist.h"

NoteList::NoteList(QObject *parent)
    : QObject(parent)
    , currentNote(nullptr)
    , emptyNote(nullptr)
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
    currentNote = nullptr;
    emit currentNoteChanged();


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
    noteList.append(res);
    genreSet.insert(genre);
    setNotesChanged();
    connect(res, SIGNAL(infoChanged()), this, SLOT(setNotesChanged()));
    return res;
}

Note* NoteList::createNote(const QJsonObject& json)
{
    Note* res = new Note();
    res->read(json);
    noteList.append(res);
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
    noteList.removeAll(note);
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

void NoteList::saveNote()
{
    if(currentNote == nullptr)
        return;
    if(emptyNote == currentNote)
    {
        noteList.append(emptyNote);
        emptyNote = nullptr;
    }
    currentNote->validate();
    genreSet.insert(currentNote->genre);
    setNotesChanged();
}

void NoteList::saveNote(Note* note)
{
    if(note == nullptr)
        return;
    note->validate();
    genreSet.insert(note->genre);
    setNotesChanged();
}

void NoteList::setNotesChanged()
{
    if(signalEnabled)
        emit notesChanged();
}



