@echo off
cd C:\Users\62895\Downloads\smartKos
C:\Users\62895\AppData\Local\Arduino15\packages\esp32\tools\mklittlefs\3.0.0-gnu12-dc7f933\mklittlefs.exe -c data -s 0x160000 -b 4096 -p 256 littlefs.bin
C:\Users\62895\AppData\Local\Arduino15\packages\esp32\tools\esptool_py\4.5.1\esptool.exe --chip esp32 --port COM19 --baud 921600 write_flash 0x290000 littlefs.bin
echo Done!
pause