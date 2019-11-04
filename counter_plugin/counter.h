#pragma once

#include <QObject>

class Counter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(unsigned int count READ count NOTIFY countChanged)

public:
    Counter(QObject *parent = nullptr)
        : QObject{parent}
    {}

    Q_INVOKABLE void increase() noexcept
    {
        m_count++;
        emit countChanged();
    }

    unsigned int count() const noexcept { return m_count; }

signals:
    void countChanged();

private:
    unsigned int m_count;
};
