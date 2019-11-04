import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import MyCompany.Counter 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Counter {
        id: _counter
    }

    ColumnLayout {
        anchors.centerIn: parent

        Label {
            text: "Clicked " + _counter.count + " times."
        }

        Button {
            text: "Increment!"
            onClicked: _counter.increase()
        }
    }
}
