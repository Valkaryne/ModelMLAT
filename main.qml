import QtQuick 2.5
import QtQuick.Controls 1.4
import QtLocation 5.6
import QtPositioning 5.5
import "map"
import "menus"
import "helper.js" as Helper

ApplicationWindow {
    id: appWindow
    property variant map
    property variant parameters

    // defaults

    function createMap(provider)
    {
        var plugin

        if (parameters && parameters.length > 0)
            plugin = Qt.createQmlObject('import QtLocation 5.6; Plugin{ name:"' + provider + '"; parameters: appWindow.parameters}', appWindow)
        else
            plugin = Qt.createQmlObject('import QtLocation 5.6; Plugin{ name:"' + provider + '"}', appWindow)

        var zoomLevel = null
        var tilt = null
        var bearing = null
        var fov = null
        var center = null
        var panelExpanded = null
        if (map) {
            zoomLevel = map.zoomLevel
            tilt = map.tilt
            bearing = map.bearing
            fov = map.fieldOfView
            center = map.center
            panelExpanded = map.slidersExpanded
            map.destroy()
        }

        map = mapComponent.createObject(page);
        map.plugin = plugin

        if (zoomLevel != null) {
            map.tilt = tilt
            map.bearing = bearing
            map.fieldOfView = fov
            map.zoomLevel = zoomLevel
            map.center = center
            map.slidersExpanded = panelExpanded
        } else {
            // Use an integer ZL to enable nearest interpolation, if possible.
            map.zoomLevel = Math.floor((map.maximumZoomLevel - map.minimumZoomLevel) / 2)
            // defaulting to 45 degrees, if possible.
            map.fieldOfView = Math.min(Math.max(45.0, map.minimumFieldOfView), map.maximumFieldOfView)
        }

        map.forceActiveFocus()
    }

    function getPlugins()
    {
        var plugin = Qt.createQmlObject('import QtLocation 5.6; Plugin {}', appWindow)
        var myArray = new Array()
        for (var i = 0; i < plugin.availableServiceProviders.length; i++) {
            var tempPlugin = Qt.createQmlObject('import QtLocation 5.6; Plugin {name: "' + plugin.availableServiceProviders[i] + '"}', appWindow)
            if (tempPlugin.supportsMapping())
                myArray.push(tempPlugin.name)
        }
        myArray.sort()
        return myArray
    }

    function initializeProviders(pluginParameters)
    {
        var parameters = new Array()
        for (var prop in pluginParameters) {
            var parameter = Qt.createQmlObject('import QtLocation 5.6; PluginParameter{ name: "' + prop + '"; value: "' + pluginParameters[prop] + '"}', appWindow)
            parameters.push(parameter)
        }
        appWindow.parameters = parameters
        var plugins = getPlugins()
        mainMenu.providerMenu.createMenu(plugins)
        for (var i = 0; i < plugins.length; i++) {
            if (plugins[i] === "osm")
                mainMenu.selectProvider(plugins[i])
        }
    }

    title: qsTr("MLAT Model")
    height: 480
    width: 640
    visible: true
    menuBar: mainMenu

    MainMenu {
        id: mainMenu

        onSelectProvider: {
            stackView.pop()
            for (var i = 0; i < providerMenu.items.length; i++) {
                providerMenu.items[i].checked = providerMenu.items[i].text === providerName
            }

            createMap(providerName)
            if (map.error = Map.NoError) {
                selectMapType(map.activeMapType)
            } else {
                mapTypeMenu.clear()
            }
        }

        onSelectMapType: {
            stackView.pop(page)
            for (var i = 0; i < mapTypeMenu.items.length; i++) {
                mapTypeMenu.items[i].checked = mapTypeMenu.items[i].text === mapType.name
            }
            map.activeMapType = mapType
        }
    }

    MapPopupMenu {
        id: mapPopupMenu

        function show(coordinate)
        {
            stackView.pop(page)
            mapPopupMenu.coordinate = coordinate
            mapPopupMenu.beaconsCount = map.beacons.length
            mapPopupMenu.targetExists = map.targetExists
            mapPopupMenu.mapItemsCount = map.mapItems.length
            mapPopupMenu.update()
            mapPopupMenu.popup()
        }

        onItemClicked: {
            stackView.pop(page)
            switch (item) {
            case "addBeacon":
                map.addBeacon()
                break
            case "setTarget":
                map.setTarget()
                break
            case "getCoordinate":
                map.coordinatesCaptured(coordinate.latitude, coordinate.longitude)
                break
            case "fitViewport":
                map.fitViewportToMapItems()
                break
            case "deleteBeacons":
                map.deleteBeacons()
                break
            case "deleteTarget":
                map.deleteTarget()
                break
            case "deleteItems":
                map.deleteMapItems()
                break
            default:
                console.log("Unsupported operation")
            }
        }
    }

    /*MarkerPopupMenu {
        id: markerPopupMenu

        function show(coordinate)
        {
            stackView.pop(page)
            markerPopupMenu.markersCount = map.markers.length
            markerPopupMenu.update()
            markerPopupMenu.popup()
        }

        onItemClicked: {
            stackView.pop(page)
            switch (item) {
            case "deleteMarker":
                map.deleteMarker(map.currentMarker)
                break
            case "getMarkerCoordinate":
                map.coordinatesCaptured(map.markers[map.currentMarker].coordinate.latitude, map.markers[map.currentMarker].coordinate.longitude)
                break
            case "distanceToNextPoint":
                var coordinate1 = map.markers[currentMarker].coordinate
                var coordinate2 = map.markers[currentMarker + 1].coordinate
                var distance = Helper.formatDistance(coordinate1.distanceTo(coordinate2));
                stackView.showMessage(qsTr("Distance"), "<b>" + qsTr("Distance:") + "</b> " + distance)
                break
            case "drawImage":
                map.addGeoItem("ImageItem")
                break
            case "drawRectangle":
                map.addGeoItem("RectangleItem")
                break
            case "drawCircle":
                map.addGeoItem("CircleItem")
                break
            case "drawPolyline":
                map.addGeoItem("PolylineItem")
                break
            case "drawPolygonMenu":
                map.addGeoItem("PolygonItem")
                break
            default:
                console.log("Unsupported operation")
            }
        }
    } */

    StackView {
        id: stackView
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: controlRow.top
        focus: true
        initialItem: Item {
            id: page
        }

        function showMessage(title, message, backPage)
        {
            console.log("Title: " + title + "\nMessage: " + message)

        }
    }

    Component {
        id: mapComponent

        MapComponent {
            width: page.width
            height: page.height
            onSupportedMapTypesChanged: mainMenu.mapTypeMenu.createMenu(map)
            onCoordinatesCaptured: {
                var text = "<b>" + qsTr("Latitude:") + "</b> " + Helper.roundNumber(latitude, 4) + "<br/><b>" + qsTr("Longitude:") + "</b> " + Helper.roundNumber(longitude, 4)
                stackView.showMessage(qsTr("Coordinates"), text)
            }

            onShowMainMenu: mapPopupMenu.show(coordinate)
            //onShowMarkerMenu: markerPopupMenu.show(coordinate)
        }
    }

    Row {
        id: controlRow
        anchors.bottom: parent.bottom
        Label {
            font.pixelSize: 14
            text: "Number of beacons: "
        }
        SpinBox {
            minimumValue: 2
            maximumValue: 8
            onValueChanged: {
                map.beaconMaxCount = value
            }
        }
        Label {
            font.pixelSize: 14
            text: "Time delay: "
        }
        SpinBox {
            minimumValue: -100
            maximumValue: 100
            onValueChanged: {
                map.timeDelay = value
            }
        }
    }
}
