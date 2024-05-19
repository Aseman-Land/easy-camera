#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QIcon>

#include "cursortracker.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Aseman");
    app.setOrganizationDomain("land.aseman");
    app.setApplicationName("Easy Camera");
    app.setWindowIcon(QIcon(":/icon.png"));

    qmlRegisterType<CursorTracker>("EasyCamera", 1, 0, "CursorTracker");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("homePath", QDir::homePath());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
