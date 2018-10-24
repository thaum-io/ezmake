#!/usr/bin/env python3
##################################################################################
# MIT License
#
# Copyright (c) 2017 Aqeel Akber <aqeel@thaum.com.au>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##################################################################################

import os
import glob
import fnmatch
import argparse


class EZMakeProject(object):
    def __init__(self, root : str, description : str,  name = "", version = "0.0.0"):
        self.root = os.path.expanduser(root)
        self.root = os.path.expandvars(self.root)
        self.root = os.path.abspath(self.root)
        self.name = name if (name) else os.path.basename(self.root)
        self.description = description
        self.version = version
        self.lib_paths = glob.iglob(self.root+"/src/lib/*")
        self.bin_paths = glob.iglob(self.root+"/src/bin/*")

        self.__ExtractBinFiles()
        self.__ExtractLibFiles()

    def __ExtractBinFiles(self):
        self.bins = {}
        for binpath in self.bin_paths:
            if (not os.path.isdir(binpath)):
                continue

            ext_name = {"h": [], "hh": [], "hxx": [], "hpp": [],
                      "c": [], "cc": [], "cxx": [], "cpp": []}
            name_ext = {}
            code = {"header": [], "source": []}
            #self.libs[os.path.basename(libpath)] = []
            for fn in os.listdir(binpath):
                header = fnmatch.fnmatch(fn, "*.h")
                header |= fnmatch.fnmatch(fn, "*.hh")
                header |= fnmatch.fnmatch(fn, "*.hxx")
                header |= fnmatch.fnmatch(fn, "*.hpp")

                source = fnmatch.fnmatch(fn, "*.c")
                source |= fnmatch.fnmatch(fn, "*.cc")
                source |= fnmatch.fnmatch(fn, "*.cxx")
                source |= fnmatch.fnmatch(fn, "*.cpp")

                if (not (header or source)):
                    continue

                split = fn.split(".")
                ext = split[-1]
                name = split[0]
                if (header):
                    key = "header"
                elif (source):
                    key = "source"

                code[key].append(fn)
                ext_name[ext].append(name)
                if (name not in name_ext):
                    name_ext[name] = {"header": [], "source": []}
                name_ext[name][key].append(ext)

            self.bins[os.path.basename(binpath)] = {"code": code,
                                                    "name_ext": name_ext,
                                                    "ext_name": ext_name}

    def __ExtractLibFiles(self):
        self.libs = {}
        for libpath in self.lib_paths:
            if (not os.path.isdir(libpath)):
                continue

            ext_name = {"h": [], "hh": [], "hxx": [], "hpp": [],
                      "c": [], "cc": [], "cxx": [], "cpp": []}
            name_ext = {}
            code = {"header": [], "source": []}
            #self.libs[os.path.basename(libpath)] = []
            for fn in os.listdir(libpath):
                header = fnmatch.fnmatch(fn, "*.h")
                header |= fnmatch.fnmatch(fn, "*.hh")
                header |= fnmatch.fnmatch(fn, "*.hxx")
                header |= fnmatch.fnmatch(fn, "*.hpp")

                source = fnmatch.fnmatch(fn, "*.c")
                source |= fnmatch.fnmatch(fn, "*.cc")
                source |= fnmatch.fnmatch(fn, "*.cxx")
                source |= fnmatch.fnmatch(fn, "*.cpp")

                if (not (header or source)):
                    continue

                split = fn.split(".")
                ext = split[-1]
                name = split[0]
                if (header):
                    key = "header"
                elif (source):
                    key = "source"

                code[key].append(fn)
                ext_name[ext].append(name)
                if (name not in name_ext):
                    name_ext[name] = {"header": [], "source": []}
                name_ext[name][key].append(ext)

            self.libs[os.path.basename(libpath)] = {"code": code,
                                                    "name_ext": name_ext,
                                                    "ext_name": ext_name}


    def GetLibUnits(self):
        return self.libs.keys()

    def GetBinUnits(self):
        return self.bins.keys()

    def TopLevel(self):
        TOP = "# EZMake %s/CMakeLists.txt\n\n" % (self.name)
        TOP += "cmake_minimum_required(VERSION 3.4.3 FATAL_ERROR)\n"
        TOP += "project(%s VERSION %s)\n" % (self.name, self.version)
        TOP += "set(PROJECT_DESCRIPTION \"%s\")\n\n" % (self.description)
        TOP += "#set(CMAKE_CXX_STANDARD 17)\n"
        TOP += "#set(CMAKE_CXX_STANDARD_REQUIRED ON)\n"
        TOP += "#set(CMAKE_CXX_EXTENSIONS OFF)\n\n"
        TOP += "set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)\n"
        TOP += "include(ezmake/EZMake)\n"
        TOP += "include(CTest)\n\n"
        TOP += "option(%s_WITH_TESTING \"Build tests/examples\" ON)\n" % (self.name)
        TOP += "option(%s_NO_INSTALL \"Skip installation process\" OFF)\n\n" % (self.name)
        TOP += "ez_proj_init()\n\n"
        #TOP += "ez_include(${PROJECT_SOURCE_DIR}/src/lib/)\n\n"
        TOP += "#add_subdirectory(${PROJECT_SOURCE_DIR}/extern)\n"
        TOP += "add_subdirectory(${PROJECT_SOURCE_DIR}/src/lib)\n"
        TOP += "add_subdirectory(${PROJECT_SOURCE_DIR}/src/bin)\n"
        TOP += "\nez_proj_export()\n"
        return TOP

    def LibLevel(self, name = ["unit"]):
        LIB = "# EZMake %s/src/lib/CMakeLists.txt\n\n" % (self.name)
        #LIB += "ez_include_this()\n\n"
        for n in name:
            LIB += "add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/%s)\n" % (n)
        return LIB

    def BinLevel(self, name = ["unit"]):
        BIN = "# EZMake %s/src/bin/CMakeLists.txt\n\n" % (self.name)
        for n in name:
            BIN += "add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/%s)\n" % (n)
        return BIN

    def UnitLevel(self, t = "lib", name = "unit"):
        if (t == "bin"):
            files = self.bins[name]
        elif (t == "lib"):
            files = self.libs[name]
        else:
            raise Exception('Invalid Argument t = %s. Must be either "lib" or "bin"' % t)

        added = set()
        UNIT = "# EZMake %s/src/%s/%s/CMakeLists.txt\n" % (self.name, t, name)
        UNIT += "ez_unit_init(%s)\n\n" % (t)

        if (len(files['code']['header']) + len(files['code']['source']) == 0):
            return UNIT

        # Add code if possible
        for fn, exts in files['name_ext'].items():
            if ( (len(exts['header']) > 0) and (len(exts['source']) > 0) ):
                hext = exts['header'][0]
                cext = exts['source'][0]
                added.add(fn+"."+hext)
                added.add(fn+"."+cext)
                UNIT += "ez_this_unit_add_code(%s %s %s)\n" % (fn, hext, cext)
        UNIT += "\n"

        # Add remaining headers
        extra = 0
        for fn in files['code']['header']: # a list with extension
            if (fn in added):
                continue
            UNIT += "ez_this_unit_add_header(%s)\n" % (fn)
            added.add(fn)
            extra += 1
        UNIT += "\n"*(extra > 0)

        # Add source code
        extra = 0
        for fn in files['code']['source']: # a list with extension
            if (fn in added):
                continue
            UNIT += "ez_this_unit_add_source(%s)\n" % (fn)
            added.add(fn)
            extra += 1
        UNIT += "\n"*(extra > 0)

        # Build link
        UNIT += "ez_this_unit_build(%s)\n" % ( "SHARED" if (t=="lib") else "")
        UNIT += "#ez_this_unit_link(PUBLIC ${PROJECT_NAME}_libunit ${PROJECT_NAME}_extern_target)\n\n"

        # Strongly suggest testing!
        if (t == "lib"):
            UNIT += "# Library unit testing\n"
            UNIT += "#ez_this_unit_add_tests(tests/test1.cc tests/test2.cc)\n"
            UNIT += "#ez_this_unit_link_tests(PUBLIC test_main)\n\n"

        # Install
        UNIT += "ez_this_unit_install()\n\n"
        return UNIT


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="EZMake Project Generator")
    parser.add_argument("-p", dest="projdir", type=str, required=True, help="Path to project base directory")
    parser.add_argument("-d", dest="desc", type=str, required=True, help="Project description")
    parser.add_argument("-e", dest="existing", type=str, choices=["backup", "overwrite", "skip", "prompt"], default="skip", help="Policy for existing CMakeLists.txt files")
    parser.add_argument("-o", dest="outdir", type=str, required=False, default="", help="(OPTIONAL) Alternative output directory")
    parser.add_argument("-n", dest="name", type=str, required=False, default="", help="(OPTIONAL) Override name of project")
    parser.add_argument("-v", dest="version", type=str, required=False, default="0.0.0", help="(OPTIONAL) Version of project")


    args = parser.parse_args()
    args.outdir = args.outdir if (args.outdir) else args.projdir

    proj = EZMakeProject(args.projdir, args.desc, args.name, args.version)

    def backup(fn : str):
        n = int(1)
        while (os.path.isfile(fn+".{}.bak".format(n))):
            n += 1
        os.rename(fn, fn+".{}.bak".format(n))
        print("Moved {} -> {}".format(fn, "{}.{}.bak".format(fn, n)))
        return open(fn, "w")

    def prompt(fn : str):
        while (True):
            existing = input("{} exists. [b]backup, [o]verwrite, [s]kip?".format(fn))
            if (existing.lower() == 'b'):
                return backup(fn)
            elif (existing.lower() == 'o'):
                return open(fn, "w")
            elif (existing.lower() == 's'):
                raise FileExistsError("File exists and policy is to skip")

    def myopen(fn : str):
        if (os.path.isfile(fn)):
            if (args.existing == "backup"):

                return backup(fn)
            elif (args.existing == "overwrite"):
                print("Overwritten: {}".format(fn))
                return open(fn, "w")
            elif (args.existing == "skip"):
                print("Skipping: {}".format(fn))
                raise FileExistsError("File exists and policy is to skip")
            elif (args.existing == "prompt"):
                return prompt(fn)
        else:
            os.makedirs(os.path.dirname(fn), exist_ok=True)
            print("Creating: {}".format(fn))
            return open(fn, "w")

    # Start generating the CMakeLists files

    fn = args.outdir+"/CMakeLists.txt"
    try:
        f = myopen(fn)
        f.write(proj.TopLevel())
        f.close()
    except FileExistsError:
        pass;

    # The basic Makefile
    fn = args.outdir+"/Makefile"
    try:
        f = myopen(fn)
        f.write("prefix = \"./built\"\n")
        f.write("opts = \"\"\n")
        f.write("SHELL:=/bin/bash\n")
        f.write("build:\n")
        f.write("\tmkdir build; cd build; cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=${prefix} ${opts} ..\n")
        f.write("\n")
        f.write("clean:\n")
        f.write("\trm -rf build\n")
        f.write("\n")
        f.write("gitreqs:\n")
        f.write("\tgit submodule update --recursive --remote --init\n")
        f.write("\n")
        f.write(".PHONY:\n")
        f.write("\tbuild clean gitreqs")
        f.close()
    except FileExistsError:
        pass;


    # Lets do the libs
    fn = args.outdir+"/src/lib/CMakeLists.txt"
    try:
        f = myopen(fn)
        f.write(proj.LibLevel(proj.GetLibUnits()))
        f.close()
    except FileExistsError:
        pass;

    ## Lib units
    for unit in proj.GetLibUnits():
        try:
            fn = args.outdir+"/src/lib/{}/CMakeLists.txt".format(unit)
            f = myopen(fn)
            f.write(proj.UnitLevel("lib", unit))
            f.close()
        except FileExistsError:
            pass;

    # Now the binaries
    fn = args.outdir+"/src/bin/CMakeLists.txt"
    try:
        f = myopen(fn)
        f.write(proj.BinLevel(proj.GetBinUnits()))
        f.close()
    except FileExistsError:
        pass;

    ## Bin units
    for unit in proj.GetBinUnits():
        fn= args.outdir+"/src/bin/{}/CMakeLists.txt".format(unit)
        try:
            f = myopen(fn)
            f.write(proj.UnitLevel("bin", unit))
            f.close()
        except FileExistsError:
            pass;

    # All done
    print("All done.")
    print("mkdir build; cd build; cmake ..; make")
