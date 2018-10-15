import QtQuick 2.5
import QtLocation 5.6

MapQuickItem {
    id: bcenter
    anchorPoint.x: image.width / 2
    anchorPoint.y: image.height / 2

    sourceItem: Image {
        id: image
        width: 12
        height: 12
        source: "../resources/Center.png"
    }
}
