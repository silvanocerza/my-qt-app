#pragma once

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

#include "counter.h"

class MyQmlPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) { qmlRegisterType<Counter>(uri, 1, 0, "Counter"); }
};
