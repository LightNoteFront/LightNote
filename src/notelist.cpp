#include "notelist.h"

NoteList::NoteList(QObject *parent)
    : QObject(parent)
    , currentNote(nullptr)
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

Note* NoteList::getCurrentNote() const
{
    return currentNote;
}

void NoteList::setCurrentNote(QObject* note)
{
    Note* p = nullptr;
    if(note != nullptr && (p = dynamic_cast<Note*>(note)) == nullptr)
        return;
    currentNote = p;
    emit currentNoteChanged();
}

Note* NoteList::createEmptyNote()
{
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
    setNotesChanged();
}

void NoteList::setNotesChanged()
{
    if(signalEnabled)
        emit notesChanged();
}



