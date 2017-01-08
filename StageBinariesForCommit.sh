#/bin/bash
mkdir bin
cd bin
rm -r ./*
cd ..

cp -r application.linux32/lib bin/
cp -r application.linux32/data bin/
cp application.linux32/SpaceInvaders bin/SpaceInvaders-linux32.sh
cp application.linux64/SpaceInvaders bin/SpaceInvaders-linux64.sh
cp application.linux-armv6hf/SpaceInvaders bin/SpaceInvaders-linux-arm.sh
cp application.windows32/SpaceInvaders.exe bin/SpaceInvaders-windows32.exe
cp application.windows32/SpaceInvaders.exe bin/SpaceInvaders-windows64.exe

cd bin
zip -r SpaceInvaders.zip ./*

rm -r data lib *.sh *.exe
