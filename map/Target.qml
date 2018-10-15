import QtQuick 2.5
import QtLocation 5.6

MapQuickItem {
    id: target

    anchorPoint.x: image.width / 2
    anchorPoint.y: image.height / 2

    sourceItem: Image {
        id: image
        width: 16
        height: 16
        source: "../resources/Target.png"
        opacity: targetMouseArea.pressed ? 0.6 : 1.0
        MouseArea {
            id: targetMouseArea
            property int pressX: -1
            property int pressY: -1
            property int jitterThreshold: 10
            property int lastX: -1
            property int lastY: -1
            anchors.fill: parent
            hoverEnabled: false
            drag.target: target
            preventStealing: true
        }
    }
    Component.onCompleted: coordinate = map.toCoordinate(Qt.point(targetMouseArea.mouseX,
                                                                  targetMouseArea.mouseY));
}
