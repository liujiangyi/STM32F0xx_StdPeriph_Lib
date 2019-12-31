#!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: create_stm32_stdperiph_lib_project.sh <StdPeriph_Lib_Dir> <Project_Dir> <MCU>"
	exit 0
fi

STM32_STDPERIPH_LIB_DIR="$1"
DEST_PROJECT_DIR="$2"
DEST_PROJECT_NAME=`basename "$DEST_PROJECT_DIR"`
MCU="$3"
if [ -z "$MCU" ]; then
	MCU="STM32F030C8"
fi

if [ ! -d "$DEST_PROJECT_DIR" ]; then
	mkdir -p "$DEST_PROJECT_DIR"
fi

mkdir "${DEST_PROJECT_DIR}/Drivers"
mkdir "${DEST_PROJECT_DIR}/Inc"
mkdir "${DEST_PROJECT_DIR}/Src"
mkdir "${DEST_PROJECT_DIR}/Utilities"

cp -a "$STM32_STDPERIPH_LIB_DIR"/Projects/STM32F0xx_StdPeriph_Templates/.lvimrc  "${DEST_PROJECT_DIR}"
cp -a "$STM32_STDPERIPH_LIB_DIR/Libraries/CMSIS"  "${DEST_PROJECT_DIR}/Drivers"
# FIXME: F0xx 
cp -a "$STM32_STDPERIPH_LIB_DIR/Libraries/STM32F0xx_StdPeriph_Driver"  "${DEST_PROJECT_DIR}/Drivers"
cp -a "$STM32_STDPERIPH_LIB_DIR/Projects/STM32F0xx_StdPeriph_Templates/MDK-ARM"  "${DEST_PROJECT_DIR}"
cp -a "$STM32_STDPERIPH_LIB_DIR"/Projects/STM32F0xx_StdPeriph_Templates/*.h  "${DEST_PROJECT_DIR}/Inc"
cp -a "$STM32_STDPERIPH_LIB_DIR"/Projects/STM32F0xx_StdPeriph_Templates/*.c  "${DEST_PROJECT_DIR}/Src"
cp -a "$STM32_STDPERIPH_LIB_DIR"/Utilities/STM32F0xx_AN4055_V1.0.1  "${DEST_PROJECT_DIR}/Utilities"

cd "${DEST_PROJECT_DIR}/MDK-ARM"
rm -rf STM32F051
sed -i -e "s#Project.uvprojx#${DEST_PROJECT_NAME}#g" ../.lvimrc
sed -i -e 's#..\\..\\..\\Libraries#..\\Drivers#g' Project.uvprojx Project.uvoptx
sed -i -e "s#STM32F051,USE_STM320518_EVAL#${MCU:0:9}#g" Project.uvprojx
sed -i -e "s#STM32F051K8#${MCU}#g" Project.uvprojx
sed -i -e "s#STM32F051#${DEST_PROJECT_NAME}#g" Project.uvprojx
sed -i -e 's#..\\main.c#..\\Src\\main.c#g' Project.uvprojx
sed -i -e 's#..\\stm32f0xx_it.c#..\\Src\\stm32f0xx_it.c#g' Project.uvprojx
sed -i -e 's#..\\hal.c#..\\Src\\hal.c#g' Project.uvprojx
sed -i -e 's#..\\system_stm32f0xx.c#..\\Src\\system_stm32f0xx.c#g' Project.uvprojx
sed -i -e 's#<IncludePath>..\\;#<IncludePath>..\\Inc;#g' Project.uvprojx
sed -i -e 's#<CreateHexFile>0</CreateHexFile>#<CreateHexFile>1</CreateHexFile>#g' Project.uvprojx
mv Project.uvprojx "${DEST_PROJECT_NAME}.uvprojx"
mv Project.uvoptx "${DEST_PROJECT_NAME}.uvoptx"
rm -f Project.uvguix.*
