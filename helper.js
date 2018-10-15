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
