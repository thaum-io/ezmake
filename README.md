Copyright (C) 2017 Aqeel Akber <aqeel@thaum.com.au>
```
 _____ _______  __       _
| ____|__  /  \/  | __ _| | _____
|  _|   / /| |\/| |/ _` | |/ / _ \
| |___ / /_| |  | | (_| |   <  __/
|_____/____|_|  |_|\__,_|_|\_\___|
```

## EZMAKE C++ BEST PRACTICE BOILERPLATE PROJECT STRUCTURE
#### Author: Aqeel Akber <aqeel@thaum.com.au>

This CMake Module provides a series of macros will make all your
CMakeLists.txt files look almost identical and contain very
little. This is achieved if you follow the EZMake Project structure,
the idea being the structure is best practice.  At this stage, the
focus is on development for GNU/Linux operating systems. This is
constantly evolving, your suggestions are absolutely most welcome.

### Vision / Objective

An EZMake C++ Project is highly modular, contains documentation,
unit tests, is git aware, include vendored/external libraries, and can
provide extensions. It can be installed, packaged, and easily
integrated into other CMake projects.

## 1 Really quick start, use the generator

### 1.1 Structure project

Structure your project as follows:

```
myproj.cc [your project name]
├── cmake
│   └── ezmode [this git repo / as submodule recommended]
└── src
    ├── bin
    │   └── app1
    │       └── main.cc
    └── lib
        └── lib1
            ├── myclass.cc
            └── myclass.hh
```

You can refer to headers in your project relative to
`lib`. e.g. `#include <lib1/myclass.hh>` may exist in `main.cc`.

### 1.2 Generate EZMake `CMakeLists.txt` files

Now run:

```shell
python3 cmake/ezmode/ezproj.py -p . -d "myproj.cc description"
```

See `ezproj.py --help`

### 1.3 Build!

A `Makefile` to run CMake is in generated. It's simple. Read it.

```shell
# generated Makefile runs cmake
make
cd build
# actually build
make
# don't worry, installs into ./built
make install
```

It will likely fail at first. You will need to edit generated
`CMakeLists.txt` files to link to appropriate libraries.

For example:
To link `app1` to `lib1`: uncomment/modify the generated
`src/bin/app1/CMakeLists.txt` file to have `ez_this_unit_link(PUBLIC
${PROJECT_NAME}_lib1)`.

### 1.4 Make complex, highly modular/maintainable projects

Proof of the generalisation of this process to arbitrary number of
`lib` and `bin` units / code files is left as an exercise for the
reader.

## 2 Details

EZMake is expected to be installed in `myproj.cc/cmake/ezmode/`

The workflow of using the macros included in this module is
described in detail below.

### 2.1 Project Level `myproj.cc/CMakeLists.txt`
#### 2.1.1 Initialise a project
`ez_proj_init()` does the following:

Defines the following variables
```
  EZ_PROJ_VER
  GIT_REVISION
  EZ_INSTALL_BINDIR
  EZ_INSTALL_LIBDIR
  EZ_INSTALL_INCDIR
  EZ_INSTALL_DATADIR
  EZ_INSTALL_DOCDIR
 {EZ_PROJ_VER}_INCLUDE_DIRS
```
Intializes the following global properties:
```
  EZ_PROJ_LIBS - List of libraries that get installed by ezmode.
  EZ_PROJ_APPS - List of applications that get installed by ezmode.
```

Also adds `$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/lib>` to
include directories. This allows you to `#include <unit/header.hh>`
all units in `lib` across your project and is consistent with the
install structure inside `EZ_INSTALL_INCDIR`

#### 2.1.2 Add additional include folders
`ez_include(folder)` adds folder as an include directory to the build
interface. If you include the directory one above your units then you
make refer to them across project with `#include <unit/header.hh>`
which will be consistent with the structure inside
`EZ_INSTALL_INCDIR`.

Example: `ez_include(extern)`

#### 2.1.3 Export a project
`ez_proj_export()` should be the last macro called in your CMake
project build. If OPTION `{PROJECT_NAME}_NO_INSTALL` is `OFF` this
macro creates a `${PROJECT_NAME}-config.cmake` file that includes all
units config files. Other CMake uses can then easily include all units
in this project by using `find_package({PROJECT_NAME})`.

### 2.2 Library / Binary Level `myproj.cc/src/{lib,bin}/CMakeLists.txt`
#### 2.2.1 Add units
Simply `add_subdirectory(unit)` appropriately.

### 2.3 Unit level `myproj.cc/src/{lib,bin}/{units...}/CMakeLists.txt`
#### 2.3.1 Initialise a unit
`ez_unit_init("lib" or "bin")` does the following:

Defines the following variables
```
  EZ_THIS_UNIT_NAME               - pulled from the folder name
  EZ_THIS_UNIT_NAME_FULL (lib)    - {PROJECT_NAME}_{EZ_THIS_UNIT_NAME}
  EZ_THIS_UNIT_NAME_FULL (bin)    - EZ_THIS_UNIT_NAME
  EZ_THIS_UNIT_HEADERS            - list
  EZ_THIS_UNIT_SOURCES            - list
 {EZ_THIS_UNIT_NAME_FULL}_HEADERS - list
 {EZ_THIS_UNIT_NAME_FULL}_SOURCES - list
  EZ_THIS_UNIT_TYPE               - "lib" or "bin"
```

#### 2.3.2 Add code
`ez_this_unit_add_code(filename_no_ext)` adds `filename_no_ext.hh` and
`filename_no_ext.cc` to `EZ_THIS_UNIT_NAME_FULL_HEADERS` and
`EZ_THIS_UNIT_NAME_FULL_SOURCES` respectively.

While it's recommended to use the above macro as it enforces best
practice. There are also functions `ez_this_unit_add_header(filename)`
and `ez_this_unit_add_source(filename)` to add to these variables
separately.

#### 2.3.3 Build unit
`ez_this_unit_build(args_extra...)` creates a build target named
`EZ_THIS_UNIT_NAME_FULL` as either an executable or library depending on
the initialisation type with sources defined in
`EZ_THIS_UNIT_NAME_FULL_SOURCES`.

#### 2.3.4 Link unit
`ez_this_unit_link(args_targets...)` links target `EZ_THIS_UNIT_NAME_FULL`
with given arguments and targets.

#### 2.3.5 Add tests
`ez_this_unit_add_tests(args_sources...)` creates an test executable
with these sources and links it to this unit. It then adds this
executable as a CMake test. If OPTION `{PROJECT_NAME}_WITH_TESTING` is
`OFF` this macro does nothing.

#### 2.3.6 Link test
`ez_this_unit_link_tests(args_targets...)` links test executable made
with the macro above with given arguments and targets. If OPTION
`{PROJECT_NAME}_WITH_TESTING` is `OFF` this macro does nothing.

#### 2.3.7 Install unit
`ez_this_unit_install()` appends `EZ_THIS_UNIT_NAME_FULL` to
`EZ_PROJ_{upper{EZ_THIS_UNIT_TYPE}}` - these get iterated upon during
`ez_proj_export()`

Installs unit as a component given by `EZ_THIS_UNIT_TYPE` into
directories as defined during project initialization. It also exports
the unit into the file
`{EZ_INSTALL_DATADIR}/cmake/{unitname}-config.cmake` This way users
should be able to use `find_package(fullunitname)` to import just a
single library out of a project.

## 3 Licence and contributing

Thank you very much for your interest in EZMake. We warmly invite
you into contribute and use our software.

### 3.1 Licensing

To keep contributing and usage simple, licences along with clear
statement of copyright are to be included at the top of all files,
they apply to that file only. To be 100% clear, using EZMake macros
as part of your software's build system does not make your software a
derivative work of EZMake.

### 3.2 Contributing ❤

There are many ways you can contribute.

#### 3.2.1 Use EZMake and let us know!

The easiest way to is to use EZMake in your project, add a link in
the next section, and make a pull request.

#### 3.2.2 Writing extensions

1. Write extensions in a file `extensions/EZMake-ext-<name>.cmake`.
2. Follow the style `ez_proj_ext_<name>` for the intialization macro
   for this extension.
   + Using `ez_include(${MYEXT_INCLUDE_DIRS})` might be useful here.
   + Until a better method is devised, follow the same message/print
     verbosity and style as existing extensions.
3. Remember the point of extensions to make use of the all the
   variables defined by EZMake so that there is a consistent
   styling.
4. Include your licence at the top of the file.
5. Make a pull request and it's likely it will be merged quickly.

#### 3.2.3 Bug reporting

We strive to have as few bugs as possible. If you find (or even
suspect) one, please report it as an issue on GitHub including as much
information as possible, the following things are important:

1. Operating system, cmake version, IDE (if applicable)
2. What you did, and what you expected to happen
3. A copy of the CMake output
4. Ideally but not necessary: a link to your project/commit where the
   error is occurring.

Report issues liberally. If it doesn't just work, it's an issue.

#### 3.2.4 Writing documentation

Documentation improvements are always welcome, this includes code
comments.

Contributing documentation does not have to be boring. Links to your
projects as examples are fantastic. If you have a blog and like using
EZMake, write about and how you use it in your workflow as a
tutorial.

#### 3.2.5 Feature requests

To request a new feature, please open a new issue on GitHub. A feature
request needs to find a developer and maintainer to adopt and
implement it.

## 4 Further reading

### 4.1 Projects using EZMake
