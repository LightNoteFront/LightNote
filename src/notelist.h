#ifndef NOTELIST_H
#define NOTELIST_H

#include <QObject>
#include "note.h"
#include "webrequest.h"

class NoteList : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList genreList READ getGenreList NOTIFY notesChanged)
    Q_PROPERTY(QList<QObject*> noteList READ getNotes NOTIFY notesChanged)
    Q_PROPERTY(Note* currentNote READ getCurrentNote WRITE setCurrentNote NOTIFY currentNoteChanged)
    Q_PROPERTY(QString filter MEMBER filter NOTIFY filterChanged)

public:

    explicit NoteList(QObject *parent = 0);
    ~NoteList();

    void clear();

    Q_INVOKABLE void sync();

    Q_INVOKABLE QStringList getGenreList() const;
    Q_INVOKABLE void addGenre(QString genre);

    Q_INVOKABLE QList<QObject*> getGenreNotesFiltered(QString genreName) const;
    Q_INVOKABLE QList<QObject*> getGenreNotes(QString genreName) const;
    Q_INVOKABLE QList<QObject*> getNotes() const;

    Q_INVOKABLE Note* createNote(QString genre = QString(), QString title = QString(), int id=-1);
    Q_INVOKABLE Note* createNote(const QJsonObject &json, int id=-1);

    Q_INVOKABLE void setSignalEnabled(bool enabled);

    Q_INVOKABLE Note* getCurrentNote() const;
    Q_INVOKABLE void setCurrentNote(Note* note);

    Q_INVOKABLE Note* createEmptyNote();
    Q_INVOKABLE void applyNote();
    Q_INVOKABLE void applyNote(Note* note);

    Q_INVOKABLE void fullLoad();
    Q_INVOKABLE void fullSave();

signals:

    void notesChanged();
    void currentNoteChanged();

    void filterChanged();

protected slots:

    void setNotesChanged();

protected:

    void addNote(Note* note);
    bool loadNote(Note* note);
    bool saveNote(Note* note);
    bool saveIndex();

    QList<Note*> noteList;

    QSet<QString> genreSet;

    QString filter;

    Note* currentNote;
    Note* emptyNote;

    bool signalEnabled;

    WebRequest req;

};

#endif // NOTELIST_H
