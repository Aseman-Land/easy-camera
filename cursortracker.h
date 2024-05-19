#ifndef CURSORTRACKER_H
#define CURSORTRACKER_H

#include <QObject>
#include <QPointF>
#include <QTimer>

class CursorTracker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointF position READ position NOTIFY positionChanged FINAL)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged FINAL)

public:
    CursorTracker(QObject *parent = nullptr);
    virtual ~CursorTracker();

    QPointF position() const;

    bool running() const;
    void setRunning(bool newRunning);

Q_SIGNALS:
    void positionChanged();
    void runningChanged();

protected:
    void setPosition(QPointF newPosition);

private:
    QPointF mPosition;
    bool mRunning = false;

    QTimer *mTimer = nullptr;
};

#endif // CURSORTRACKER_H
