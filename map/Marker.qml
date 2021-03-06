import QtQuick 2.5
import QtLocation 5.6

//! [mqi-top]
MapQuickItem {
    id: marker
//! [mqi-top]
    property alias lastMouseX: markerMouseArea.lastX
    property alias lastMouseY: markerMouseArea.lastY

//! [mqi-anchor]
    anchorPoint.x: image.width / 2
    anchorPoint.y: image.height / 2

    sourceItem: Image {
        id: image
        width: 16
        height: 16
//! [mqi-anchor]
        source: "../resources/Beacon.png"
        opacity: markerMouseArea.pressed ? 0.6 : 1.0
        MouseArea {
            id: markerMouseArea
            property int pressX: -1
            property int pressY: -1
            property int jitterThreshold: 10
            property int lastX: -1
            property int lastY: -1
            anchors.fill: parent
            hoverEnabled: false
            drag.target: marker
            preventStealing: true

            onPressed: {
                map.pressX = mouse.x
                map.pressY = mouse.y
                map.currentMarker = -1
                for (var i = 0; i < map.markers.length; i++) {
                    if (marker == map.markers[i]) {
                        map.currentMarker = i
                        break
                    }
                }
            }

            onPressAndHold: {
                if (Math.abs(map.pressX - mouse.x) < map.jitterThreshold
                        && Math.abs(map.pressY - mouse.y) < map.jitterThreshold) {
                    var p = map.fromCoordinate(marker.coordinate)
                    lastX = p.x
                    lastY = p.y
                    map.showMarkerMenu(marker.coordinate)
                }
            }
        }

        Text {
            id: number
            y: image.height / 8
            width: image.width
            color: "white"
            font.bold: true
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            Component.onCompleted: {
                text = map.markerCounter
            }
        }
//! [mqi-closeimage]
    }
//! [mqi-closeimage]
    Component.onCompleted: coordinate = map.toCoordinate(Qt.point(markerMouseArea.mouseX,
                                                                  markerMouseArea.mouseY));
//! [mqi-close]
}
//! [mqi-close]
