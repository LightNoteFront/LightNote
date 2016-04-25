#ifndef WEBREQUEST_H
#define WEBREQUEST_H

#include <QObject>
#include <QJsonObject>
#include <QHash>
#include <QNetworkAccessManager>
#include <QMutex>

#include <functional>

class WebRequest : public QObject
{
    Q_OBJECT

public:

    typedef std::function<void(const QJsonObject& data)> CallbackReply;

    explicit WebRequest(QString webroot, QObject *parent = 0);
    WebRequest(QString webroot, QString username, QString password, QObject *parent = 0);

    Q_INVOKABLE bool post(QString type, const QJsonObject& data);
    Q_INVOKABLE bool get(QString type, const QJsonObject& data, CallbackReply callback);

    Q_INVOKABLE bool send(QString url, const QJsonObject& data, CallbackReply callback);

    Q_INVOKABLE void registerUrl(QString type, QString url, bool rootBased = true);
    Q_INVOKABLE void unregisterUrl(QString type);

protected slots:

    void replyFinished(QNetworkReply* reply);

protected:

    QNetworkAccessManager* manager;

    QString root;
    QString user;
    QString pass;

    QHash<QString, QString> mapReqType;

    QHash<QNetworkReply*, CallbackReply> mapCallback;

    QMutex mtxCallback;

};

#endif // WEBREQUEST_H
