import QtQuick 2.5
import QtLocation 5.6

//TODO: remove me when items are integrated

MapPolygon {
    color: "#46a2da"
    border.color: "#190a33"
    border.width: 2
    smooth: true
    opacity: 0.25

    function setGeometry(markers, index) {
        for (var i = index; i < markers.length; i++) {
            addCoordinate(markers[i].coordinate)
        }
    }
    MouseArea {
        anchors.fill: parent
        id: mouseArea
        drag.target: parent
    }
}
