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
    Q_PROPERTY(int noteCount READ noteCount NOTIFY notesChanged)
    Q_PROPERTY(Note* currentNote READ getCurrentNote WRITE setCurrentNote NOTIFY currentNoteChanged)
    Q_PROPERTY(QString filter MEMBER filter NOTIFY filterChanged)
    Q_PROPERTY(QStringList popularTags READ getPopularTags NOTIFY popularTagsChanged)
    Q_PROPERTY(QString user MEMBER currentUser NOTIFY userChanged)
    Q_PROPERTY(bool syncStatus MEMBER syncStatus NOTIFY syncStatusChanged)
    Q_PROPERTY(double syncProgress READ syncProgress NOTIFY syncProgressChanged)

public:

    explicit NoteList(WebRequest* request, QObject *parent = 0);
    ~NoteList();

    void clear();

    Q_INVOKABLE void sync();
    Q_INVOKABLE double syncProgress();

    Q_INVOKABLE QStringList getGenreList() const;
    Q_INVOKABLE void addGenre(QString genre);
    Q_INVOKABLE void deleteGenre(QString genre);

    Q_INVOKABLE QList<QObject*> getGenreNotesFiltered(QString genreName) const;
    Q_INVOKABLE QList<QObject*> getGenreNotes(QString genreName) const;
    Q_INVOKABLE QList<QObject*> getNotes() const;

    Q_INVOKABLE int noteCount() const;

    Q_INVOKABLE Note* createNote(QString genre = QString(), QString title = QString(), int id=-1);
    Q_INVOKABLE Note* createNote(const QJsonObject &json, int id=-1);

    Q_INVOKABLE void setSignalEnabled(bool enabled);

    Q_INVOKABLE Note* getCurrentNote() const;
    Q_INVOKABLE void setCurrentNote(Note* note);

    Q_INVOKABLE Note* createEmptyNote();
    Q_INVOKABLE void applyNote();
    Q_INVOKABLE void applyNote(Note* note);
    Q_INVOKABLE void deleteNote(Note* note);

    Q_INVOKABLE void fullLoad();
    Q_INVOKABLE void fullSave();

    Q_INVOKABLE QStringList getPopularTags(int limit = 10) const;
    Q_INVOKABLE void addPopularTag(QString tag, int weight = 1);

    Q_INVOKABLE void toggleTag(QString tag, bool on);
    Q_INVOKABLE void resetToggleTag();

    Q_INVOKABLE QString getColor(int index) const;

    Q_INVOKABLE void loginUser(QString username, QString password);
    Q_INVOKABLE void registerUser(QString username, QString password, QString phoneno);

signals:

    void notesChanged();
    void currentNoteChanged();

    void filterChanged();

    void popularTagsChanged();

    void loginFinished(bool success);
    void userChanged();

    void syncStatusChanged();
    void syncProgressChanged();

protected slots:

    void setNotesChanged();

protected:

    void addNote(Note* note);
    bool loadNote(Note* note);
    bool saveNote(Note* note);
    bool saveIndex();

    void setCurrentUser(QString name, bool success);

    QList<Note*> noteList; // 保存现有所有的Note对象（不包含emptyNote），清空时需释放对象

    QSet<QString> genreSet;

    QString filter;
    QSet<QString> selectedTags;

    Note* currentNote; // 指向现在的Note对象，不对对象的释放负责
    Note* emptyNote; // 保存一个Note对象，或者为空。清空时要delete或者转移对象。

    bool signalEnabled;

    WebRequest* req;

    QList<QString> colorList;

    QMap<QString, int> popTags;
    QMap<QPair<int, QString>, QString> tagPop;
    const int maxPopTag = 30;

    QString currentUser;

    QSet<int> deletedNotes;

    bool syncStatus;
    int syncCount;
    int syncTotal;

};

#endif // NOTELIST_H
