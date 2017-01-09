#/bin/sh
#set up directory structure for zip file
mkdir bin
rm -r bin/*
mkdir -p bin/SpaceInvaders/lib
mkdir -p bin/SpaceInvaders/data

#copy dependency jars and other data into folder to be zipped
cd bin
cp -r application.*/lib/* SpaceInvaders/lib/
cp -r application.linux32/data/* SpaceInvaders/data/

#copy each executable to the folder
cp application.linux32/SpaceInvaders SpaceInvaders/SpaceInvaders-linux32.sh
cp application.linux64/SpaceInvaders SpaceInvaders/SpaceInvaders-linux64.sh
cp application.linux-armv6hf/SpaceInvaders SpaceInvaders/SpaceInvaders-linux-armv6.sh
cp application.windows32/SpaceInvaders.exe SpaceInvaders/SpaceInvaders-windows32.exe
cp application.windows32/SpaceInvaders.exe SpaceInvaders/SpaceInvaders-windows64.exe

#zip it up
zip -r SpaceInvaders.zip ./SpaceInvaders

#delete the folder that has been zipped and the other compiled versions
#leaving only the zip with all versions included
rm -r SpaceInvaders
cd ..
rm -r application.*
