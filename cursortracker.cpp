#include "cursortracker.h"

#include <QCursor>

CursorTracker::CursorTracker(QObject *parent)
    : QObject{parent}
{
    mTimer = new QTimer(this);
    mTimer->setInterval(15);
    mTimer->setSingleShot(false);

    connect(mTimer, &QTimer::timeout, this, [this](){
        setPosition(QCursor::pos());
    });
}

CursorTracker::~CursorTracker()
{
}

QPointF CursorTracker::position() const
{
    return mPosition;
}

void CursorTracker::setPosition(QPointF newPosition)
{
    if (mPosition == newPosition)
        return;
    mPosition = newPosition;
    Q_EMIT positionChanged();
}

bool CursorTracker::running() const
{
    return mRunning;
}

void CursorTracker::setRunning(bool newRunning)
{
    if (mRunning == newRunning)
        return;

    mTimer->stop();
    mRunning = newRunning;
    if (mRunning)
        mTimer->start();

    Q_EMIT runningChanged();
}
