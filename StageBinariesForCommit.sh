#/bin/sh
rm -r bin/*
mkdir -pv bin/SpaceInvaders/lib
mkdir -v bin/SpaceInvaders/data



pwd

cp -r application.*/lib/* bin/SpaceInvaders/lib/
cp -r application.linux32/data/* bin/SpaceInvaders/data/
cp application.linux32/SpaceInvaders bin/SpaceInvaders/SpaceInvaders-linux32.sh
cp application.linux64/SpaceInvaders bin/SpaceInvaders/SpaceInvaders-linux64.sh
cp application.linux-armv6hf/SpaceInvaders bin/SpaceInvaders/SpaceInvaders-linux-arm.sh
cp application.windows32/SpaceInvaders.exe bin/SpaceInvaders/SpaceInvaders-windows32.exe
cp application.windows32/SpaceInvaders.exe bin/SpaceInvaders/SpaceInvaders-windows64.exe

cd bin
zip -r SpaceInvaders.zip ./SpaceInvaders

rm -r SpaceInvaders

cd ..
rm -r application.*