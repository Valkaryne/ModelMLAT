import QtQuick 2.5
import QtQuick.Controls 1.4
import QtLocation 5.6

MenuBar {
    property variant providerMenu: providerMenu
    property variant mapTypeMenu: mapTypeMenu

    signal selectProvider(string providerName)
    signal selectMapType(variant mapType)

    Menu {
        id: providerMenu
        title: qsTr("Provider")

        function createMenu(plugins)
        {
            clear()
            for (var i = 0; i < plugins.length; i++) {
                createProviderMenuItem(plugins[i]);
            }
        }

        function createProviderMenuItem(provider)
        {
            var item = addItem(provider);
            item.checkable = true;
            item.triggered.connect(function(){selectProvider(provider)})
        }
    }

    Menu {
        id: mapTypeMenu
        title: qsTr("MapType")

        function createMenu(map)
        {
            clear()
            for (var i = 0; i < map.supportedMapTypes.length; i++) {
                createMapTypeMenuItem(map.supportedMapTypes[i]).checked =
                        (map.activeMapType === map.supportedMapTypes[i]);
            }
        }

        function createMapTypeMenuItem(mapType)
        {
            var item = addItem(mapType.name)
            item.checkable = true
            item.triggered.connect(function(){selectMapType(mapType)})
            return item
        }
    }
}
