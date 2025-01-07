#!/bin/bash
echo "
  ******************************************
  * Creador JoeArchV                       *
  * Herramienta para flashear dispositivos *
  ******************************************                                                                              
"
echo "Tenga cuidado al usar esta herramienta asegurese de que se descargue bien la rom aveces se puede descargar currupta y al momento de flashear el dispositivo se pondra todo en negro solo veras el fastboot pero se soluciona volviendo a descargar la rom"
read -p "Estas seguro? (si/no): " choice
if [ "$choice" != "si" ]; then
    echo "Saliendo."
    exit 1
fi

ADB_PATH=$(which adb)
FASTBOOT_PATH=$(which fastboot)

if [ -z "$ADB_PATH" ] || [ -z "$FASTBOOT_PATH" ]; then
    echo "Se requieren ADB y Fastboot pero no están instalados."
    exit 1
fi

$ADB_PATH devices | grep -q device$
if [ $? -ne 0 ]; then
    echo "No hay ningún dispositivo conectado o el dispositivo no se reconoce."
    exit 1
fi

echo "Por favor, introduzca la ruta a su directorio ROM:"
read -r ROM_PATH

if [ ! -d "$ROM_PATH" ]; then
    echo "El directorio especificado no existe."
    exit 1
fi

echo "Reiniciando el gestor de arranque..."
$ADB_PATH reboot bootloader

echo "Esperando que el dispositivo ingrese al cargador de arranque..."
sleep 10

$FASTBOOT_PATH devices | grep -q fastboot$
if [ $? -ne 0 ]; then
    echo "El dispositivo no está en modo de arranque."
    exit 1
fi

echo "Flasheando imagen boot..."
$FASTBOOT_PATH flash boot "$ROM_PATH/boot.img"

echo "Flasheando imagen system..."
$FASTBOOT_PATH flash system "$ROM_PATH/system.img"

echo "Flasheando imagen vendor..."
$FASTBOOT_PATH flash vendor "$ROM_PATH/vendor.img"

echo "Flasheando otras imagenes..."
$FASTBOOT_PATH flash recovery "$ROM_PATH/recovery.img"
$FASTBOOT_PATH flash userdata "$ROM_PATH/userdata.img"

echo "Reiniciando el dispositivo..."
$FASTBOOT_PATH reboot

echo "Dispositivo flasheado correctamente"