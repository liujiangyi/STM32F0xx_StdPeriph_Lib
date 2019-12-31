#!/usr/bin/env python3
# vim: fileencoding=utf-8 fileformat=unix expandtab tabstop=4 softtabstop=4 shiftwidth=4:
#
#
#
import argparse
import glob
import os.path
import re
import shutil
import sys


def copy_files(src_pat, dst_dir):
    for f in glob.glob(src_pat):
        if os.path.isdir(f): continue
        shutil.copy2(f, dst_dir)


def rm_files(pat):
    for f in glob.glob(pat):
        os.remove(f)


def create_proj(proj_dir, mcu):
    proj_dir = os.path.expanduser(proj_dir)
    proj_dir = os.path.expandvars(proj_dir)
    proj_dir = os.path.abspath(proj_dir)
    proj_name = os.path.basename(os.path.normpath(proj_dir))
    lib_dir = sys.path[0]

    if not os.path.exists(proj_dir):
        # prompt?
        os.makedirs(proj_dir)
    #os.mkdir(proj_dir + '/MDK-ARM')
    shutil.copy2(lib_dir + "/Projects/STM32F0xx_StdPeriph_Templates/.lvimrc", proj_dir)
    copy_files(lib_dir + "/Projects/STM32F0xx_StdPeriph_Templates/MDK-ARM/*", proj_dir)
    #copy_files(lib_dir + "/Projects/STM32F0xx_StdPeriph_Templates/*.h", proj_dir)
    #copy_files(lib_dir + "/Projects/STM32F0xx_StdPeriph_Templates/*.c", proj_dir)
    #shutil.copytree(lib_dir + "/Utilities/STM32F0xx_AN4055_V1.0.1", proj_dir +  "/Utilities/STM32F0xx_AN4055_V1.0.1")

    rel_lib_dir = os.path.relpath(sys.path[0], proj_dir)
    with open(proj_dir + "/Project.uvprojx", 'r+t') as f:
        content = f.read()
        content = content.replace('..\\..\\..\\Libraries', rel_lib_dir + '\\Libraries')
        content = content.replace('STM32F051,USE_STM320518_EVAL', mcu[0:9])
        content = content.replace('STM32F051K8', mcu)
        content = content.replace('STM32F051', proj_name)
        content = content.replace('<CreateHexFile>0</CreateHexFile>', '<CreateHexFile>1</CreateHexFile>')
        f.seek(0)
        f.truncate()
        f.write(content)

    shutil.move(proj_dir + "/Project.uvprojx", proj_dir + "/" + proj_name + ".uvprojx")

    with open(proj_dir + "/Project.uvoptx", 'r+t') as f:
        content = f.read()
        content = content.replace('..\\..\\..\\Libraries', rel_lib_dir + '\\Libraries')
        f.seek(0)
        f.truncate()
        f.write(content)

    shutil.move(proj_dir + "/Project.uvoptx", proj_dir + "/" + proj_name + ".uvoptx")

    rm_files(proj_dir + '/Project*')

    with open(proj_dir + "/.lvimrc", 'r+t') as f:
        content = f.read()
        content = content.replace('$PROJ_NAME$', proj_name)
        content = content.replace('$REL_LIB_DIR$', rel_lib_dir)
        f.seek(0)
        f.truncate()
        f.write(content)


def main():
    parser = argparse.ArgumentParser(description="Create a Yongnuo STM32F0xx StdPeriph Project")
    parser.add_argument('proj_dir', help="proj directory (will be used as project name also)", type=str)
    parser.add_argument('mcu', help='STM32F0xx MCU. Example: STM32F072', type=str)

    args = parser.parse_args()
    print(args)

    create_proj(args.proj_dir, args.mcu)


if __name__ == '__main__':
    main()
