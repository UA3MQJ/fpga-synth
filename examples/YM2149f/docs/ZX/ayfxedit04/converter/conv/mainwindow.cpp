#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QDebug>
#include <QFile>
#include <QByteArray>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_btnSelFile_clicked()
{
    qDebug() << "select file";
}

void MainWindow::on_btnGo_clicked()
{
    qDebug() << "open file" << ui->lineEdit->text();

    QFile file;
    file.setFileName(ui->lineEdit->text());

    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "Ошибка открытия для чтения";

        return;
    }

    QByteArray a = file.readAll();

    file.close();

    qDebug() << a.toHex();
    uchar volumeMask = 0x0f; // 8'b00001111
    uchar chTMask = 0x20;    // 8'b00100000
    uchar chNMask = 0x40;    // 8'b01000000

    uchar disTMask = 0x10;    // 8'b00010000
    uchar disNMask = 0x80;    // 8'b10000000

    uchar pos = 0;
    uchar volume;
    uchar T=0;
    uchar N=0;

    uchar changeT=0;
    uchar changeN=0;
    quint16 tone=0;
    quint8 noise=0;


    int state = 0; // 0- первый байт. 1- первый байт тона 2-второй байт тона 3-первый байт шума
    for(int i=0; i<a.length()-2;i++) {
         //qDebug() << i << QString::number( (uchar)a.at(i) );
        uchar byte = (uchar)a.at(i);
        //bit0..3  Громкость
        //bit4     Запрещение T
        //bit5     Изменение T
        //bit6     Изменение N
        //bit7     Запрещение N

        if (state==0) {
            changeT=0;
            changeN=0;
            volume = byte & volumeMask;
            if((byte & chTMask)) {
                T=1;
                changeT=1;
            }
            if(((byte & chNMask))) {
                N=1;
                changeN=1;
            }
            if((byte & disTMask)) {
                T=0;
            }
            if(((byte & disNMask))) {
                N=0;
            }


            if(changeT) {
                state = 1; // переходим на чтение  байт тона
            } else if (changeN) {
                state = 2; // переходим на чтение байта шума
            } else {
                //иначе выводим результат
                qDebug() << " POS" << QString::number( pos, 16 )
                         << " T" << QString::number( T )
                         << " N" << QString::number( N )
                         << " PER" << QString::number( tone, 16 )
                         << " NS" << QString::number( noise, 16 )
                        << " Volume" << QString::number( volume, 16 );
                pos++;
                state = 0;
            }
        } else if (state==1) {
            //читаем первый байт тона
            tone=byte;

            state=2;
        } else if (state==2) {
            //читаем второй байт тона
            tone +=  (quint16)byte << 8;

            if(changeN) {
                state = 3; // переходим на чтение следующих байт
            } else {
                //иначе выводим результат
                qDebug() << "byte" << QString::number( byte );

                qDebug() << " POS" << QString::number( pos, 16 )
                         << " T" << QString::number( T )
                         << " N" << QString::number( N )
                         << " PER" << QString::number( tone, 16 )
                         << " NS" << QString::number( noise, 16 )
                        << " Volume" << QString::number( volume, 16 );
                pos++;
                state = 0;
            }
        } else if (state==3) {
            //читаем второй байт шума
            noise +=  (quint16)byte;

            qDebug() << "byte" << QString::number( byte );

            qDebug() << " POS" << QString::number( pos, 16 )
                     << " T" << QString::number( T )
                     << " N" << QString::number( N )
                     << " PER" << QString::number( tone, 16 )
                     << " NS" << QString::number( noise, 16 )
                    << " Volume" << QString::number( volume, 16 );

            pos++;
            state = 0;
        }

    }
}
