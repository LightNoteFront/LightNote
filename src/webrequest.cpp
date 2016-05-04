#include "webrequest.h"

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkReply>

WebRequest::WebRequest(QString webroot, QObject* parent)
    : QObject(parent)
    , manager(new QNetworkAccessManager(this))
    , root(webroot)
{
    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
}

WebRequest::WebRequest(QString webroot, QString username, QString password, QObject *parent)
    : QObject(parent)
    , manager(new QNetworkAccessManager(this))
    , root(webroot)
    , user(username)
    , pass(password)
{
    connect(manager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(replyFinished(QNetworkReply*)));
}

bool WebRequest::post(QString type, const QJsonObject& data)
{
    if(mapReqType.count(type) == 0)
        return false;
    return send(mapReqType[type], data, CallbackReply());
}

bool WebRequest::get(QString type, const QJsonObject& data, CallbackReply callback)
{
    if(mapReqType.count(type) == 0)
        return false;
    return send(mapReqType[type], data, callback);
}

bool WebRequest::send(QString url, const QJsonObject& data, CallbackReply callback)
{
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonDocument doc(data);
    QByteArray raw = doc.toJson();

    mtxCallback.lock();
    QNetworkReply* reply = manager->post(req, raw);
    if(reply != nullptr)
        mapCallback[reply] = callback;
    else
        qDebug() << "null reply !!";
    mtxCallback.unlock();

    qDebug() << "sended" << raw;

    return reply != nullptr;
}

void WebRequest::registerUrl(QString type, QString url, bool rootBased)
{
    mapReqType[type] = (rootBased ? root + url : url);
}

void WebRequest::unregisterUrl(QString type)
{
    mapReqType.remove(type);
}

void WebRequest::replyFinished(QNetworkReply* reply)
{
    if(reply == nullptr)
        return;

    mtxCallback.lock();
    CallbackReply callback = mapCallback[reply];
    mapCallback.remove(reply);
    mtxCallback.unlock();

    if(reply->error() == QNetworkReply::NoError)
    {
        QByteArray raw = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(raw);
        if(doc.isArray())
        {
            QJsonObject obj;
            obj["array"] = doc.array();
            callback(obj);
        }
        else
        {
            callback(doc.object());
        }
    }
    else
    {
        callback(QJsonObject());
    }

    reply->deleteLater();
}

