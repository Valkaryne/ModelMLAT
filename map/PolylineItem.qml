import QtQuick 2.5
import QtLocation 5.6

//TODO: remove/refactor me when items are integrated

MapPolyline {
    line.color: "#46a2da"
    line.width: 4
    opacity: 0.25
    smooth: true

    function setGeometry(markers, index) {
        for (var i = index; i < markers.length; i++) {
            addCoordinate(markers[i].coordinate)
        }
    }
}
