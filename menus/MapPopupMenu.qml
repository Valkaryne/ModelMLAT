import QtQuick 2.5
import QtQuick.Controls 1.4

Menu {
    property variant coordinate
    property int beaconsCount
    property bool targetExists
    property int mapItemsCount
    signal itemClicked(string item)

    function update() {
        clear()
        addItem(qsTr("Add Beacon")).triggered.connect(function(){itemClicked("addBeacon")})
        addItem(qsTr("Set Target")).triggered.connect(function(){itemClicked("setTarget")})
        addItem(qsTr("Get coordinate")).triggered.connect(function(){itemClicked("getCoordinate")})
        addItem(qsTr("Fit Viewport To Map Items")).triggered.connect(function(){itemClicked("fitViewport")})

        if (beaconsCount > 0) {
            addItem(qsTr("Delete all beacons")).triggered.connect(function(){itemClicked("deleteBeacons")})
        }

        if (targetExists) {
            addItem(qsTr("Delete target")).triggered.connect(function(){itemClicked("deleteTarget")})
        }

        if (mapItemsCount > 0) {
            addItem(qsTr("Delete all items")).triggered.connect(function(){itemClicked("deleteItems")})
        }
    }
}
