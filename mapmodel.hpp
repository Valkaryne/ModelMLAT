#ifndef MAPMODEL_HPP
#define MAPMODEL_HPP

#include <QObject>
#include <QMap>
#include <QVector>
#include <QDebug>
#include <QVector2D>

class MapModel : public QObject
{
    Q_OBJECT
public:
    explicit MapModel(QObject *parent = nullptr);
    ~MapModel();

    Q_INVOKABLE void setBase(int key, double aY, double aX, double bY, double bX);
    Q_INVOKABLE void setCenter(int key, double cY, double cX);
    Q_INVOKABLE void updateBasis(int key, double topY, double topX, double delay);
    Q_INVOKABLE void updateMapEdges(double topX, double topY, double bottomX, double bottomY);
    Q_INVOKABLE QVector<double> getCurveCoordinates(int key, bool isForward);
    Q_INVOKABLE void findAngleDeviation(int key);
    Q_INVOKABLE QVector<double> getRotatedCoordinates(int key, int type);

private:
    const double dLat = 0.000009031055490301464;
    const double dLng = 0.00001518152830162021924;

    double topX, topY, bottomX, bottomY;

    QMap<int, double> aPoint_y;
    QMap<int, double> aPoint_x;
    QMap<int, double> bPoint_y;
    QMap<int, double> bPoint_x;
    QMap<int, double> cPoint_y;
    QMap<int, double> cPoint_x;
    QMap<int, double> delays;
    QMap<int, double> angles;
    QMap<int, QVector<double>> basis;
    QMap<int, QVector<double>> hyperbolaX;
    QMap<int, QVector<double>> hyperbolaY;

    int samplesLength = 512;

    enum rotation_type {
        RED,
        GREEN,
        BLUE,
        YELLOW
    };
};

#endif // MAPMODEL_HPP
