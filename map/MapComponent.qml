import QtQuick 2.5
import QtQuick.Controls 1.4
import QtLocation 5.9
import QtPositioning 5.5
import "../helper.js" as Helper
import com.ngale.qt.mapmodel 1.0

//! [top]
Map {
    id: map
//! [top]
    property variant beacons
    property variant mapItems
    property int beaconCounter: 0 // counter for total amount of beacons. Resets to 0 when number of beacons = 0
    property int beaconMaxCount: 2
    property int currentBeacon: -1

    property variant target
    property bool targetExists: false
    property variant timeDelay
    property variant prevTimeDelay
    property variant targetPrevPosition;

    property variant top1
    //property variant top2

    property variant mainCurve
    property variant curveRed
    property variant curveGreen
    property variant curveBlue
    property variant curveYellow
    property variant mc
    property variant cr
    property variant cg
    property variant cb
    property variant cy

    property variant baseCentres: []

    property int lastX: -1
    property int lastY: -1
    property int pressX: -1
    property int pressY: -1
    property int jitterThreshold: 30
    property bool followme: false
    property variant scaleLengths: [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000, 2000000]
    property alias slidersExpanded: sliders.expanded

    signal coordinatesCaptured(double latitude, double longitude)
    signal showMainMenu(variant coordinate)
    //signal showMarkerMenu(variant coordinate)
    signal showPointMenu(variant coordinate)

    MapModel {
        id: model
    }

    DotLineItem {
        id: beaconsBaseLine
        line.color: "black"
    }

    DotLineItem {
        id: targetDirectionLine
        line.color: "#FF6300"
        opacity: 0.45
    }

    function calculateScale()
    {
        var coord1, coord2, dist, text, f
        f = 0
        coord1 = map.toCoordinate(Qt.point(0, scale.y))
        coord2 = map.toCoordinate(Qt.point(0 + scaleImage.sourceSize.width, scale.y))
        dist = Math.round(coord1.distanceTo(coord2))

        if (dist === 0) {
            // not visible
        } else {
            for (var i = 0; i < scaleLengths.length - 1; i++) {
                if (dist < (scaleLengths[i] + scaleLengths[i+1]) / 2) {
                    f = scaleLengths[i] / dist
                    dist = scaleLengths[i]
                    break;
                }
            }
            if (f === 0) {
                f = dist / scaleLengths[i]
                dist = scaleLengths[i]
            }
        }

        text = Helper.formatDistance(dist)
        scaleImage.width = (scaleImage.sourceSize.width * f) - 2 * scaleImageLeft.sourceSize.width
        scaleText.text = text
    }

    function updatePointGeometry() {
        if (beaconCounter > 0) {
            beaconsBaseLine.resetGeometry()
            beaconsBaseLine.setGeometry(beacons)
        }
        if (beaconCounter > 1) {
            setCentersForBases()
        }
        if (timeDelay !== prevTimeDelay) {
            prevTimeDelay = timeDelay
            var beaconA = beacons[0].coordinate
            var beaconB = beacons[1].coordinate
            resetTops()
            setTops(beaconA, beaconB, baseCentres[0].coordinate)
        }

        // TODO: clean the code
        /* if (targetExists) {
            targetDirectionLine.resetGeometry()
            targetDirectionLine.setSimplexGeometry(beacons, target)
            if (target.coordinate !== targetPrevPosition) {
                targetPrevPosition = target.coordinate
                resetTops()
                var beaconA = map.fromCoordinate(beacons[0].coordinate)
                var beaconB = map.fromCoordinate(beacons[1].coordinate)
                model.setBase(0, beaconA.y, beaconA.x, beaconB.y, beaconB.x)
                var baseCenter = map.fromCoordinate(baseCentres[0].coordinate)
                model.setCenter(0, baseCenter.y, baseCenter.x)
                var targetPoint = map.fromCoordinate(target.coordinate)
                model.setTarget(targetPoint.y, targetPoint.x)
                model.updateBasis(0)
                var myArray = model.topCoordinates(0)
                setTops(myArray)

                var coordArray = model.getCurveCoordinates(0);
                var pnt = new Array();
                for (var i = 0; i < coordArray.length; i += 2) {
                    pnt.push(map.toCoordinate(Qt.point(coordArray[i], coordArray[i+1])))
                }
                var co = Qt.createComponent('CurveItem' + '.qml')
                if (co.status == Component.Ready) {
                    map.removeMapItem(map.mainCurve)
                    mainCurve = co.createObject(map)
                    mainCurve.setGeometry(pnt)
                    map.addMapItem(mainCurve)
                }
                model.findAngleDeviation(0)

                var redArray = model.getRotatedCoordinates(0, 0); // red cat
                var pntRed = new Array();
                for (var i = 0; i < redArray.length; i += 2) {
                    pntRed.push(map.toCoordinate(Qt.point(redArray[i], redArray[i+1])))
                }
                var co = Qt.createComponent('CurveItem' + '.qml')
                if (co.status == Component.Ready) {
                    map.removeMapItem(map.curveRed)
                    curveRed = co.createObject(map)
                    curveRed.setGeometry(pntRed)
                    map.addMapItem(curveRed)
                    curveRed.setColor('red')
                }

                var greenArray = model.getRotatedCoordinates(0, 1); // green cat
                var pntGreen = new Array();
                for (var i = 0; i < greenArray.length; i += 2) {
                    pntGreen.push(map.toCoordinate(Qt.point(greenArray[i], greenArray[i+1])))
                }
                var co = Qt.createComponent('CurveItem' + '.qml')
                if (co.status == Component.Ready) {
                    map.removeMapItem(map.curveGreen)
                    curveGreen = co.createObject(map)
                    curveGreen.setGeometry(pntGreen)
                    map.addMapItem(curveGreen)
                    curveGreen.setColor('green')
                }

                var blueArray = model.getRotatedCoordinates(0, 2); // blue cat
                var pntBlue = new Array();
                for (var i = 0; i < blueArray.length; i += 2) {
                    pntBlue.push(map.toCoordinate(Qt.point(blueArray[i], blueArray[i+1])))
                }
                var co = Qt.createComponent('CurveItem' + '.qml')
                if (co.status == Component.Ready) {
                    map.removeMapItem(map.curveBlue)
                    curveBlue = co.createObject(map)
                    curveBlue.setGeometry(pntBlue)
                    map.addMapItem(curveBlue)
                    curveBlue.setColor('blue')
                }

                var yellowArray = model.getRotatedCoordinates(0, 3); // yellow cat
                var pntYellow = new Array();
                for (var i = 0; i < yellowArray.length; i += 2) {
                    pntYellow.push(map.toCoordinate(Qt.point(yellowArray[i], yellowArray[i+1])))
                }
                var co = Qt.createComponent('CurveItem' + '.qml')
                if (co.status == Component.Ready) {
                    map.removeMapItem(map.curveYellow)
                    curveYellow = co.createObject(map)
                    curveYellow.setGeometry(pntYellow)
                    map.addMapItem(curveYellow)
                    curveYellow.setColor('#dfdf00')
                }
            }
        } */
    }

    function setTops(beaconA, beaconB, baseCentre) {
        top1 = Qt.createQmlObject('Top {}', map)
        addMapItem(top1)
        top1.z = map.z + 1

        if (beaconA.longitude > beaconB.longitude) {
            var temp = beaconB;
            beaconB = beaconA;
            beaconA = temp
        }

        var rangeDiff = 0.5 * timeDelay * 3//* 0.3
        var topArray

        if (rangeDiff < 0) {
            topArray = Helper.calculateTopPosition(rangeDiff, beaconA.latitude, beaconA.longitude,
                                                   baseCentre.latitude, baseCentre.longitude)
        } else if (rangeDiff > 0) {
            topArray = Helper.calculateTopPosition(rangeDiff, beaconB.latitude, beaconB.longitude,
                                                   baseCentre.latitude, baseCentre.longitude)
        }
        //console.log("Top: " + topArray[0] + ", " + topArray[1])
        top1.coordinate.latitude = topArray[0]
        top1.coordinate.longitude = topArray[1]
        console.log("Top1: " + top1.coordinate.latitude + ", " + top1.coordinate.longitude)

        //top2.coordinate = map.toCoordinate(Qt.point(coordinates[2], coordinates[3]))

        /*
         * console.log("Top1: " + top1.coordinate.latitude + ", " + top1.coordinate.longitude)
         * console.log("Top2: " + top2.coordinate.latitude + ", " + top2.coordinate.longitude)
         */
    }

    function resetTops() {
        if (map.top1 !== 0) {
            map.removeMapItem(map.top1)
            //map.top1.destroy()
        }
    }

    function setCentersForBases() {
        var count = map.baseCentres.length
        for (var i = 0; i < count; i++) {
            map.removeMapItem(map.baseCentres[i])
            map.baseCentres[i].destroy()
        }
        map.baseCentres = []

        for (var i = 0; i < beacons.length; i++) {
            for (var j = i + 1; j < beacons.length; j++)
                setCenterForBase(beacons[i], beacons[j])
        }
    }

    function setCenterForBase(beacon1, beacon2) {
        var count = map.baseCentres.length
        var base = Qt.createQmlObject('Center {}', map)
        map.addMapItem(base)
        base.z = map.z + 1
        base.coordinate.latitude = (beacon1.coordinate.latitude + beacon2.coordinate.latitude) / 2
        base.coordinate.longitude = (beacon1.coordinate.longitude + beacon2.coordinate.longitude) / 2

        var myArray = new Array()
        for (var i = 0; i < count; i++) {
            myArray.push(baseCentres[i])
        }
        myArray.push(base)
        baseCentres = myArray
    }

    function deleteBeacons()
    {
        var count = map.beacons.length
        for (var i = 0; i < count; i++) {
            map.removeMapItem(map.beacons[i])
            map.beacons[i].destroy()
        }
        map.beacons = []
        beaconCounter = 0
    }

    function deleteTarget()
    {
        map.removeMapItem(target)
        target.destroy()
        target = 0
        targetExists = false
    }

    function deleteMapItems()
    {
        var count = map.mapItems.length
        for (var i = 0; i < count; i++) {
            map.removeMapItem(map.mapItems[i])
            map.mapItems[i].destroy()
        }
        map.mapItems = []
    }

    function addBeacon()
    {
        var count = map.beacons.length
        beaconCounter++
        if (beaconCounter <= beaconMaxCount) {
            currentBeacon++
            var beacon = Qt.createQmlObject('Beacon {}', map)
            map.addMapItem(beacon)
            beacon.z = map.z + 1
            beacon.coordinate = mouseArea.lastCoordinate
        } else {
            beaconCounter--
            while (currentBeacon >= beaconMaxCount)
                currentBeacon -= beaconMaxCount
            var beacon = map.beacons[currentBeacon]
            beacon.coordinate = mouseArea.lastCoordinate
        }
        // update list of beacons
        var myArray = new Array()
        for (var i = 0; i < count; i++) {
            myArray.push(beacons[i])
        }
        myArray.push(beacon)
        beacons = myArray
    }

    function setTarget() {
        if (!targetExists) {
            targetExists = true
            target = Qt.createQmlObject('Target {}', map)
            map.addMapItem(target)
            target.z = map.z + 1
            target.coordinate = mouseArea.lastCoordinate
        } else {
            target.coordinate = mouseArea.lastCoordinate
        }
    }

    function addGeoItem(item)
    {
        var count = map.mapItems.length
        var co = Qt.createComponent(item + '.qml')
        if (co.status == Component.Ready) {
            var o = co.createObject(map)
            o.setGeometry(map.beacons, currentBeacon)
            map.addMapItem(o)
            // update list of items
            var myArray = new Array()
            for (var i = 0; i < count; i++) {
                myArray.push(mapItems[i])
            }
            myArray.push(o)
            mapItems = myArray
        } else {
            console.log(item + " is not supported right now, please call us later.")
        }
    }

    function deleteBeacon(index)
    {
        // update list of beacons
        var myArray = new Array()
        var count = map.beacons.length
        for (var i = 0; i < count; i++) {
            if (index != i) myArray.push(map.beacons[i])
        }

        map.removeMapItem(map.beacons[index])
        map.beacons[index].destroy()
        map.beacons = myArray
        if (beacons.length == 0) beaconCounter = 0
    }

//! [coord]
    zoomLevel: (maximumZoomLevel - minimumZoomLevel) / 2
    center {
        // The Republic Palace in Minsk
        latitude: 53.9033
        longitude: 27.5604
    }
//! [coord]

//! [mapnavigation]
    // Enable pan, flick, and pinch gestures to zoom in and out
    gesture.acceptedGestures: MapGestureArea.PanGesture | MapGestureArea.FlickGesture | MapGestureArea.PinchGesture | MapGestureArea.RotationGesture | MapGestureArea.TiltGesture
    gesture.flickDeceleration: 3000
    gesture.enabled: true
//! [mapnavigation]
    focus: true
    onCopyrightLinkActivated: Qt.openUrlExternally(link)

    onCenterChanged: {
        scaleTimer.restart()
        if (map.followme)
            if (map.center != positionSource.position.coordinate) map.followme = false
        //var topLeft = map.toCoordinate(Qt.point(0, 0))
        //var bottomRight = map.toCoordinate(Qt.point(map.width, map.height))
        model.updateMapEdges(0, 0, map.width, map.height)
    }

    onZoomLevelChanged: {
        scaleTimer.restart()
        if (map.followme) map.center = positionSource.position.coordinate
        //var topLeft = map.toCoordinate(Qt.point(0, 0))
        //var bottomRight = map.toCoordinate(Qt.point(map.width, map.height))
        model.updateMapEdges(0, 0, map.width, map.height)
    }

    onWidthChanged: {
        scaleTimer.restart()
        model.updateMapEdges(0, 0, map.width, map.height)
    }

    onHeightChanged: {
        scaleTimer.restart()
    }

    Component.onCompleted: {
        beacons = new Array();
        mapItems = new Array();
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Plus) {
            map.zoomLevel++;
        } else if (event.key === Qt.Key_Minus) {
            map.zoomLevel--;
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right ||
                   event.key === Qt.Key_Up   || event.key === Qt.Key_Down) {
            var dx = 0;
            var dy = 0;

            switch (event.key) {
            case Qt.Key_Left:
                dx = map.width / 4;
                break;
            case Qt.Key_Right:
                dx = -map.width / 4;
                break;
            case Qt.Key_Up:
                dy = map.height / 4;
                break;
            case Qt.Key_Down:
                dy = -map.height / 4;
                break;
            }

            var mapCenterPoint = Qt.point(map.width / 2.0 - dx, map.height / 2.0 - dy);
            map.center = map.toCoordinate(mapCenterPoint);
        }
    }


    PositionSource {
        id: positionSource
        active: followme

        onPositionChanged: {
            map.center = positionSource.position.coordinate
        }
    }

    MapQuickItem {
        id: poiTheRepublicPalace
        sourceItem: Rectangle { width: 14; height: 14; color: "#e41e25"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
        coordinate: {
            latitude: 53.9033
            longitude: 27.5604
        }
        opacity: 1.0
        anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
    }

    MapQuickItem {
        sourceItem: Text {
            text: "The Republic Palace"
            color: "#242424"
            font.bold: true
            styleColor: "#ECECEC"
            style: Text.Outline
        }
        coordinate: poiTheRepublicPalace.coordinate
        anchorPoint: Qt.point(-poiTheRepublicPalace.sourceItem.width * 0.5, poiTheRepublicPalace.sourceItem.height * 1.5)
    }

    MapSliders {
        id: sliders
        z: map.z + 3
        mapSource: map
        edge: Qt.LeftEdge
    }

    Item {
        id: scale
        z: map.z + 3
        visible: scaleText.text != "0 m"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        height: scaleText.height * 2
        width: scaleImage.width

        Image {
            id: scaleImageLeft
            source: "../resources/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImage.left
        }
        Image {
            id: scaleImage
            source: "../resources/scale.png"
            anchors.bottom: parent.bottom
            anchors.right: scaleImageRight.left
        }
        Image {
            id: scaleImageRight
            source: "../resources/scale_end.png"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }
        Label {
            id: scaleText
            color: "#004EAE"
            anchors.centerIn: parent
            text: "0 m"
        }
        Component.onCompleted: {
            map.calculateScale()
        }
    }

    //! [pointdel0]
    Component {
        id: pointDelegate

        MapCircle {
            id: point
            radius: 1000
            color: "#46a2da"
            border.color: "#190a33"
            border.width: 2
            smooth: true
            opacity: 0.25
            center: locationData.coordinate
            //! [pointdel0]
            MouseArea {
                anchors.fill: parent
                id: circleMouseArea
                hoverEnabled: false
                property variant lastCoordinate

                onPressed: {
                    map.lastX = mouse.x + parent.x
                    map.lastY = mouse.y + parent.y
                    map.pressX = mouse.x + parent.x
                    map.pressY = mouse.y + parent.y
                    lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                }

                onPositionChanged: {
                    if (Math.abs(map.pressX - parent.x - mouse.x) > map.jitterThreshold ||
                            Math.abs(map.pressY - parent.y - mouse.y) > map.jitterThreshold) {
                        if (pressed) parent.radius = parent.center.distanceTo(
                                         map.toCoordinate(Qt.point(mouse.x, mouse.y)))
                    }
                    if (mouse.button == Qt.LeftButton) {
                        map.lastX = mouse.x + parent.x
                        map.lastY = mouse.y + parent.y
                    }
                }

                onPressAndHold: {
                    if (Math.abs(map.pressX - parent.x - mouse.x) < map.jitterThreshold
                            && Math.abs(map.pressY - parent.y - mouse.y) < map.jitterThreshold) {
                        showPointMenu(lastCoordinate)
                    }
                }
            }
    //! [pointdel1]
        }
    }
    //! [pointdel1]

    Timer {
        id: scaleTimer
        interval: 100
        running: false
        repeat: false
        onTriggered: {
            map.calculateScale()
        }
    }

    Timer {
        id: pointsTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            map.updatePointGeometry()
        }
    }

    MouseArea {
        id: mouseArea
        property variant lastCoordinate
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: {
            map.lastX = mouse.x
            map.lastY = mouse.y
            map.pressX = mouse.x
            map.pressY = mouse.y
            lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
        }

        onPositionChanged: {
            if (mouse.button == Qt.LeftButton) {
                map.lastX = mouse.x
                map.lastY = mouse.y
            }
        }

        onDoubleClicked: {
            var mouseGeoPos = map.toCoordinate(Qt.point(mouse.x, mouse.y))
            var preZoomPoint = map.fromCoordinate(mouseGeoPos, false);
            if (mouse.button === Qt.LeftButton) {
                map.zoomLevel = Math.floor(map.zoomLevel + 1)
            } else if (mouse.button === Qt.RightButton) {
                map.zoomLevel = Math.floor(map.zoomLevel - 1)
            }
            var postZoomPoint = map.fromCoordinate(mouseGeoPos, false);
            var dx = postZoomPoint.x - preZoomPoint.x;
            var dy = postZoomPoint.y - preZoomPoint.y;

            var mapCenterPoint = Qt.point(map.width / 2.0 + dx, map.height / 2.0 + dy);
            map.center = map.toCoordinate(mapCenterPoint);

            lastX = -1;
            lastY = -1;
        }

        onPressAndHold: {
            if (Math.abs(map.pressX - mouse.x) < map.jitterThreshold
                    && Math.abs(map.pressY - mouse.y) < map.jitterThreshold) {
                showMainMenu(lastCoordinate);
            }
        }

        onClicked: {
            if (mouse.button === Qt.LeftButton)
                console.log("I'm a cat")
        }
    }
//! [end]
}
//! [end]
