import QtQuick 2.5
import QtLocation 5.6
import QtPositioning 5.6

MapPolyline {
    line.color: "gray"
    line.width: 3

    opacity: 0.75
    smooth: true

    function setColor(color) {
        line.color = color
    }

    function setGeometry(points) {
        //var point = QtPositioning.coordinate(53.903342, 27.6);
        for (var i = 0; i < points.length; i++) {
            //point.longitude = longitude[i];
            //point.latitude = latitude[i];
            addCoordinate(points[i])
            //console.log(point.latitude)
            //console.log(point.longitude)
        }
    }
    MouseArea {
        anchors.fill: parent
        id: mouseArea
        drag.target: parent

    }

}
