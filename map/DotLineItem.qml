import QtQuick 2.5
import QtLocation 5.6

MapPolyline {
    line.color: "black"
    line.width: 2

    opacity: 0.15
    smooth: true

    function setColor(color) {
        line.color = color
    }

    function setGeometry(beaconArray) {
        for (var i = 0; i < beaconArray.length; i++) {
            for (var j = 0; j < beaconArray.length; j++) {
                addCoordinate(beaconArray[i].coordinate)
                addCoordinate(beaconArray[j].coordinate)
            }
        }
    }

    function setSimplexGeometry(beaconArray, target) {
        for (var i = 0; i < beaconArray.length; i++) {
            addCoordinate(target.coordinate)
            addCoordinate(beaconArray[i].coordinate)
        }
    }

    function resetGeometry() {
        setPath([])
    }
}
