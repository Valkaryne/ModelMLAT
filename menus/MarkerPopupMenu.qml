import QtQuick 2.5
import QtQuick.Controls 1.4

Menu {
    property int currentMarker
    property int markersCount
    signal itemClicked(string item)

    function update() {
        clear()
        addItem(qsTr("Delete")).triggered.connect(function(){itemClicked("deleteMarker")})
        addItem(qsTr("Coordinates")).triggered.connect(function(){itemClicked("getMarkerCoordinate")})
        if (currentMarker <= markersCount - 2) {
            addItem(qsTr("Distance to next point")).triggered.connect(function(){itemClicked("distanceToNextPoint")})
        }

        var menu = addMenu(qsTr("Draw..."))
        menu.addItem(qsTr("Image")).triggered.connect(function(){itemClicked("drawImage")})

        if (currentMarker <= markersCount - 2) {
            menu.addItem(qsTr("Rectangle")).triggered.connect(function(){itemClicked("drawRectngle")})
            menu.addItem(qsTr("Circle")).triggered.connect(function(){itemClicked("drawCircle")})
            menu.addItem(qsTr("Polyline")).triggered.connect(function(){itemClicked("drawPolyline")})
        }

        if (currentMarker < markersCount - 2) {
            menu.addItem(qsTr("Polygon")).triggered.connect(function(){itemClicked("drawPolygonMenu")})
        }
    }
}
