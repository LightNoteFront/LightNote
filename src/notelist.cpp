#include "notelist.h"

NoteList::NoteList(QObject *parent)
    : QObject(parent)
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
    return genreSet.toList();
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
    emit notesChanged();
    return res;
}


