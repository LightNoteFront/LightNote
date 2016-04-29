#ifndef NOTE_H
#define NOTE_H

#include <QObject>
#include <QQuickTextDocument>
#include <QTextDocument>

class Note : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString title MEMBER title NOTIFY infoChanged)
    Q_PROPERTY(QString genre MEMBER genre NOTIFY infoChanged)
    Q_PROPERTY(QStringList tags MEMBER tags NOTIFY infoChanged)
    Q_PROPERTY(QString content MEMBER content NOTIFY infoChanged)

public:

    explicit Note(QObject *parent = 0, int id=0);
    Note(const Note& other);

    void read(const QJsonObject &json);
    void write(QJsonObject &json) const;

    Note& operator=(const Note& other);
    bool operator==(const Note& other);

    Q_INVOKABLE void setText(const QQuickTextDocument& doc);

    Q_INVOKABLE void validate();

    friend class NoteList;

signals:

    void infoChanged();

protected:

    int localId;

    QString webId; // 网络索引id，用于标记笔记是否对应服务器上的笔记记录，新建时为空

    QString title;

    QString genre;
    QStringList tags;

    QString authorId;

    QString content; // QT rich text以默认形式格式化存储的笔记本体内容


};

#endif // NOTE_H
