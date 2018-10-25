.pragma library



function roundNumber(number, digits)
{
    var multiple = Math.pow(10, digits)
    return Math.round(number * multiple) / multiple
}

function formatDistance(meters)
{
    var dist = Math.round(meters)
    if (dist > 1000) {
        if (dist > 100000) {
            dist = Math.round(dist / 1000)
        } else {
            dist = Math.round(dist / 100)
            dist = dist / 10
        }
        dist = dist + " km"
    } else {
        dist = dist + " m"
    }
    return dist
}

function calculateTopPosition(distance, point_lat, point_lng, centre_lat, centre_lng)
{
    var dLat = 0.000009031055490301464
    var dLng = 0.00001518152830162021924

    var point_x = point_lat / dLat
    var point_y = point_lng / dLng
    var centre_x = centre_lat / dLat
    var centre_y = centre_lng / dLng

    var range = Math.sqrt(Math.pow(centre_x - point_x, 2) + Math.pow(centre_y - point_y, 2))
    if (distance < 0)
        var radAngle = Math.acos((centre_x - point_x) / range)
    else
        radAngle = Math.acos((point_x - centre_x) / range)

    console.log("Angle: " + radAngle)

    var x = distance * Math.cos(radAngle) + centre_x
    var y = distance * Math.sin(radAngle) + centre_y

    var myArray = new Array()
    myArray.push(x * dLat)
    myArray.push(y * dLng)

    return myArray
}
