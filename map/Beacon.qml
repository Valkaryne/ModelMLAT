import QtQuick 2.5
import QtLocation 5.6

MapQuickItem {
    id: beacon
    property alias lastMouseX: beaconMouseArea.lastX
    property alias lastMouseY: beaconMouseArea.lastY

    anchorPoint.x: image.width / 2
    anchorPoint.y: image.width / 2

    sourceItem: Image {
        id: image
        width: 24
        height: 24
        source: "../resources/Beacon.png"
        opacity: beaconMouseArea.pressed ? 0.6 : 1.0
        MouseArea {
            id: beaconMouseArea
            property int pressX: -1
            property int pressY: -1
            property int jitterThreshold: 10
            property int lastX: -1
            property int lastY: -1
            anchors.fill: parent
            hoverEnabled: false
            drag.target: beacon
            preventStealing: true

            onPressed: {
                map.pressX = mouse.x
                map.pressY = mouse.y
                map.currentBeacon = -1
                for (var i = 0; i < map.beacons.length; i++) {
                    if (beacon == map.beacons[i]) {
                        map.currentBeacon = i
                        break
                    }
                }
            }
        }

        Text {
            id: number
            y: image.height / 4
            width: image.width
            color: "white"
            font.bold: true
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            Component.onCompleted: {
                text = map.beaconCounter
            }
        }
    }
    Component.onCompleted: coordinate = map.toCoordinate(Qt.point(beaconMouseArea.mouseX,
                                                                  beaconMouseArea.mouseY));
}
