#include "mapmodel.hpp"
//#include <math.h>
#include <QtMath>

MapModel::MapModel(QObject *parent)
    : QObject (parent)
{
}

MapModel::~MapModel()
{
}

void MapModel::setBase(int key, double aY, double aX, double bY, double bX)
{
    if (aPoint_y.contains(key))
        aPoint_y.remove(key);
    if (aPoint_x.contains(key))
        aPoint_x.remove(key);
    if (bPoint_y.contains(key))
        bPoint_y.remove(key);
    if (bPoint_x.contains(key))
        bPoint_x.remove(key);

    aPoint_y.insert(key, -1 * aY - bottomY);
    aPoint_x.insert(key, aX - bottomX);
    bPoint_y.insert(key, -1 * bY - bottomY);
    bPoint_x.insert(key, bX - bottomX);

    /*
     * qDebug() << "aY: " << QString::number(aPoint_y.value(key),'f',6);
     * qDebug() << "aX: " << QString::number(aPoint_x.value(key),'f',6);
     * qDebug() << "bY: " << QString::number(bPoint_y.value(key),'f',6);
     * qDebug() << "bX: " << QString::number(bPoint_x.value(key),'f',6);
     */
}

void MapModel::setCenter(int key, double cY, double cX)
{
    if (cPoint_y.contains(key))
        cPoint_y.remove(key);
    if (cPoint_x.contains(key))
        cPoint_x.remove(key);

    cPoint_y.insert(key, -1 * cY - bottomY);
    cPoint_x.insert(key, cX - bottomX);

    /*
     * qDebug() << "cY: " << QString::number(cPoint_y.value(key),'f',6);
     * qDebug() << "cX: " << QString::number(cPoint_x.value(key),'f',6);
     */
}

void MapModel::setTarget(double targetY, double targetX)
{
    this->target_y = -1 * targetY - bottomY;
    this->target_x = targetX - bottomX;

    /*
     * qDebug() << "target_y: " << QString::number(this->target_y,'f',6);
     * qDebug() << "target_x: " << QString::number(this->target_x,'f',6);
     */
}

void MapModel::updateBasis(int key)
{
    if (basis.contains(key))
        basis.remove(key);

    QVector<double> temp_basis;
    double ax = aPoint_x.value(key);
    double ay = aPoint_y.value(key);
    double bx = bPoint_x.value(key);
    double by = bPoint_y.value(key);
    double tx = target_x;
    double ty = target_y;

    /*
     * qDebug() << "tx: " << QString::number(tx,'f',6);
     * qDebug() << "ty: " << QString::number(ty,'f',6);
     * qDebug() << "ax: " << QString::number(ax,'f',6);
     * qDebug() << "ay: " << QString::number(ay,'f',6);
     * qDebug() << "bx: " << QString::number(bx,'f',6);
     * qDebug() << "by: " << QString::number(by,'f',6);
     */

    double a_t = sqrt(pow(tx - ax, 2) + pow(ty - ay, 2));
    double b_t = sqrt(pow(tx - bx, 2) + pow(ty - by, 2));

    double a_AB = (a_t - b_t) / 2;

    double c_AB = sqrt(pow(ax - bx, 2) + pow(ay - by, 2)) / 2;
    double b_AB = sqrt(pow(c_AB, 2) - pow(a_AB, 2));

    temp_basis.append(a_AB);
    temp_basis.append(c_AB);
    temp_basis.append(b_AB);

    basis.insert(key, temp_basis);
}

QVector<double> MapModel::topCoordinates(int key)
{
    QVector<double> coordinates;

    double ax = aPoint_x.value(key);
    double ay = aPoint_y.value(key);
    double bx = bPoint_x.value(key);
    double by = bPoint_y.value(key);
    double cx = cPoint_x.value(key);
    double cy = cPoint_y.value(key);

    double a_AB = basis.value(key).at(0);

    double a_c = sqrt(pow(ax - cx, 2) + pow(ay - cy, 2));
    double lambda = (a_c - qAbs(a_AB))/(a_c - (a_c - qAbs(a_AB)));
    double a_x = (ax + lambda * cx)/(1 + lambda);
    double a_y = (ay + lambda * cy)/(1 + lambda);
    coordinates.append(a_x + bottomX);
    coordinates.append(-1 * (a_y + bottomY));

    double b_c = sqrt(pow(bx - cx, 2) + pow(by - cy, 2));
    lambda = (b_c - qAbs(a_AB))/(b_c - (b_c - qAbs(a_AB)));
    a_x = (bx + lambda * cx)/(1 + lambda);
    a_y = (by + lambda * cy)/(1 + lambda);
    coordinates.append(a_x + bottomX);
    coordinates.append(-1 * (a_y + bottomY));

    return coordinates;
}

void MapModel::updateMapEdges(double topX, double topY, double bottomX, double bottomY)
{
    this->topX = topX - bottomX / 2;
    this->bottomX = bottomX - bottomX / 2;
    this->topY = -1 * topY + bottomY / 2;
    this->bottomY = -1 * bottomY + bottomY / 2;

    /*
     * qDebug() << "topX: " << QString::number(this->topX,'f',6);
     * qDebug() << "topY: " << QString::number(this->topY,'f',6);
     * qDebug() << "bottomX: " << QString::number(this->bottomX,'f',6);
     * qDebug() << "bottomY: " << QString::number(this->bottomY,'f',6);
     */
}

QVector<double> MapModel::getCurveCoordinates(int key)
{
    if (hyperbolaX.contains(key))
        hyperbolaX.remove(key);
    if (hyperbolaY.contains(key))
        hyperbolaY.remove(key);

    QVector<double> coordinatesVector;

    double a_AB = basis.value(key).at(0);
    double b_AB = basis.value(key).at(2);
    double increment = (bottomX - topX) / samplesLength;

    double cx = cPoint_x.value(key);
    double cy = cPoint_y.value(key);

    QVector<double> x_samples;
    for (int i = 0; i < samplesLength; i++) {
        x_samples.append(topX + i * increment);
    }

    QVector<double> y_samples, y_samples_sh;
    for (int i = 0; i < x_samples.size(); i++) {
        double sample = sqrt(pow(b_AB, 2) * ((pow(x_samples.at(i), 2) - pow(a_AB, 2)) / pow(a_AB, 2)));
        y_samples_sh.append(sample);
    }

    for (int i = 0; i < y_samples_sh.size(); i++) {
        if (y_samples_sh.at(i) != y_samples_sh.at(i))
            y_samples.append(0);
        else
            y_samples.append(y_samples_sh.at(i));
    }

    for (int i = 0; i < x_samples.size(); i++) {
        coordinatesVector.append(x_samples.at(i) + cx + bottomX);
        coordinatesVector.append(-1 * (y_samples.at(i) + cy + bottomY));
    }

    hyperbolaX.insert(key, x_samples);
    hyperbolaY.insert(key, y_samples);

    return coordinatesVector;
}

void MapModel::findAngleDeviation(int key)
{
    if (angles.contains(key))
        angles.remove(key);

    double ax = aPoint_x.value(key);
    double ay = aPoint_y.value(key);
    double bx = bPoint_x.value(key);
    double by = bPoint_y.value(key);

    double ox = bx;
    double oy = ay;

    double a_b = sqrt(pow(ax - bx, 2) + pow(ay - by, 2));
    double a_o = sqrt(pow(ax - ox, 2) + pow(ay - oy, 2));
    double cos_alpha = a_o / a_b;

    double alpha = acos(cos_alpha);
    angles.insert(key, alpha);
}

QVector<double> MapModel::getRotatedCoordinates(int key, int type)
{
    QVector<double> rotatedCoordinates;

    QVector<double> x_samples_sh = hyperbolaX.value(key);
    QVector<double> y_samples_sh = hyperbolaY.value(key);
    QVector<double> x_samples, y_samples;

    double cx = cPoint_x.value(key);
    double cy = cPoint_y.value(key);

    double alpha = angles.value(key);

    switch (type) {
    case rotation_type::RED:
        qDebug() << "Red cat";
        for (int i = 0; i < x_samples_sh.size(); i++) {
            x_samples.append(x_samples_sh.at(i) * cos(alpha) - y_samples_sh.at(i) * sin(alpha));
            y_samples.append(x_samples_sh.at(i) * sin(alpha) + y_samples_sh.at(i) * cos(alpha));
        }
        break;
    case rotation_type::GREEN:
        qDebug() << "Green cat";
        for (int i = 0; i < x_samples_sh.size(); i++) {
            x_samples.append(x_samples_sh.at(i) * cos(alpha) + y_samples_sh.at(i) * sin(alpha));
            y_samples.append(-x_samples_sh.at(i) * sin(alpha) + y_samples_sh.at(i) * cos(alpha));
        }
        break;
    case rotation_type::BLUE:
        qDebug() << "Blue cat";
        for (int i = 0; i < x_samples_sh.size(); i++) {
            x_samples.append(x_samples_sh.at(i) * cos(M_PI - alpha) - y_samples_sh.at(i) * sin(M_PI - alpha));
            y_samples.append(x_samples_sh.at(i) * sin(M_PI - alpha) + y_samples_sh.at(i) * cos(M_PI - alpha));
        }
        break;
    case rotation_type::YELLOW:
        qDebug() << "Yellow cat";
        for (int i = 0; i < x_samples_sh.size(); i++) {
            x_samples.append(x_samples_sh.at(i) * cos(M_PI - alpha) + y_samples_sh.at(i) * sin(M_PI - alpha));
            y_samples.append(-x_samples_sh.at(i) * sin(M_PI - alpha) + y_samples_sh.at(i) * cos(M_PI - alpha));
        }
        break;
    default:
        qDebug() << "Not a cat";
    }

    for (int i = 0; i < x_samples.size(); i++) {
        rotatedCoordinates.append(x_samples.at(i) + cx + bottomX);
        rotatedCoordinates.append(-1 * (y_samples.at(i) + cy + bottomY));
    }

    return rotatedCoordinates;
}
