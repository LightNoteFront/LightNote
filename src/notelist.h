#ifndef NOTELIST_H
#define NOTELIST_H

#include <QObject>
#include "note.h"

class NoteList : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList genreList READ getGenreList NOTIFY notesChanged)
    Q_PROPERTY(QList<QObject*> noteList READ getNotes NOTIFY notesChanged)

public:

    explicit NoteList(QObject *parent = 0);
    ~NoteList();

    Q_INVOKABLE void sync();

    Q_INVOKABLE QStringList getGenreList() const;

    Q_INVOKABLE QList<QObject*> getGenreNotes(QString genreName) const;
    Q_INVOKABLE QList<QObject*> getNotes() const;

    Q_INVOKABLE Note* createNote(QString genre = QString(), QString title = QString());
    Q_INVOKABLE Note* createNote(const QJsonObject &json);

    void setSignalEnabled(bool enabled);

signals:

    void notesChanged();

protected slots:

    void setNotesChanged();

protected:

    QList<Note*> noteList;

    bool signalEnabled;

};

#endif // NOTELIST_H
