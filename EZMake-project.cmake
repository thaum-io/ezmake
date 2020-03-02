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

include(${CMAKE_CURRENT_LIST_DIR}/extensions/colours.cmake)

## EZMAKE PROJECT INTIALIZATION.
# ------------------------------------------------------------------------
# ez_proj_init()
# This macro does the following:
#
# Defines the following variables
#
#   EZ_PROJ_VER
#   GIT_REVISION
#   EZ_INSTALL_BINDIR
#   EZ_INSTALL_LIBDIR
#   EZ_INSTALL_INCDIR
#   EZ_INSTALL_DATADIR
#   EZ_INSTALL_DOCDIR
#  {EZ_PROJ_VER}_INCLUDE_DIRS
#
# Defines the following global properties:
#
#   EZ_PROJ_LIBS - List of libraries that get EZ installed.
#   EZ_PROJ_APPS - List of applications that get  EZ installed.
#
macro(ez_proj_init)
  # PREREQUISITES
  # ----------------------------------------
  # First check if PROJECT is defined.
  # EZMake must initialized after project
  # is defined.
  # ----------------------------------------
  if (NOT DEFINED PROJECT_NAME)
    message(FATAL_ERROR "${BoldRed}[ EZMake :: ERROR] ez_proj_init(): Set PROJECT_NAME ! See PROJECT()${ColourReset}")
  elseif (NOT DEFINED PROJECT_VERSION_MAJOR)
    message(FATAL_ERROR "${BoldRed}[ EZMake :: ERROR] ez_proj_init(): Set PROJECT_VERSION_MAJOR ! See PROJECT()${ColourReset}")
  elseif (NOT DEFINED PROJECT_VERSION_MINOR)
    message(FATAL_ERROR "${BoldRed}[ EZMake :: ERROR] ez_proj_init(): Set PROJECT_VERSION_MINOR ! See PROJECT()${ColourReset}")
  endif()

  # From https://github.com/bast/cmake-example/

  if(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE "Debug")
  endif()

  if(${PROJECT_SOURCE_DIR} STREQUAL ${PROJECT_BINARY_DIR})
    MESSAGE(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there.")
  endif()

  STRING(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type_tolower)
  STRING(TOUPPER "${CMAKE_BUILD_TYPE}" cmake_build_type_toupper)

  if(NOT cmake_build_type_tolower STREQUAL "debug" AND
      NOT cmake_build_type_tolower STREQUAL "release" AND
      NOT cmake_build_type_tolower STREQUAL "relwithdebinfo")
    MESSAGE(FATAL_ERROR "Unknown build type \"${CMAKE_BUILD_TYPE}\". Allowed values are Debug, Release, RelWithDebInfo (case-insensitive).")
  endif()


  # VARIABLES
  # ----------------------------------------
  # The first of a few variables
  # ----------------------------------------
  set(EZ_PROJ_VER ${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
  message("${BoldCyan}[ EZMake :: ${EZ_PROJ_VER} ]${ColourReset}")

  define_property(GLOBAL PROPERTY EZ_PROJ_LIBS
    BRIEF_DOCS "List of libraries that are installed in ${PROJECT}"
    FULL_DOCS "List of libraries that are installed in ${PROJECT}"
    )

  define_property(GLOBAL PROPERTY EZ_PROJ_APPS
    BRIEF_DOCS "List of applications that are installed in ${PROJECT}"
    FULL_DOCS "List of applicatoins that are installed in ${PROJECT}"
    )

  # VARIABLES cont.
  # ----------------------------------------
  # Install directories for this project.
  # At the moment, only for GNU/Linux
  #
  include(GNUInstallDirs)

  set(EZ_INSTALL_BINDIR ${CMAKE_INSTALL_BINDIR})
  set(EZ_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR}/${EZ_PROJ_VER})
  set(EZ_INSTALL_INCDIR ${CMAKE_INSTALL_INCLUDEDIR}/${EZ_PROJ_VER})
  set(EZ_INSTALL_DATADIR ${CMAKE_INSTALL_DATADIR}/${EZ_PROJ_VER})
  set(EZ_INSTALL_DOCDIR ${CMAKE_INSTALL_DOCDIR})

  message("${BoldMagenta}[ EZMake :: Install Directories ]${ColourReset}")
  message(STATUS "   Prefix: ${CMAKE_INSTALL_PREFIX}")
  message(STATUS " Binaries: ${EZ_INSTALL_BINDIR}")
  message(STATUS "Libraries: ${EZ_INSTALL_LIBDIR}")
  message(STATUS "  Headers: ${EZ_INSTALL_INCDIR}")
  message(STATUS "     Data: ${EZ_INSTALL_DATADIR}")
  message(STATUS "     Docs: ${EZ_INSTALL_DOCDIR}")

  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${EZ_INSTALL_LIBDIR}")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

  #
  # Start setting the include directory
  # paths. We will keep adding to this until
  # the end of the macro.
  # ----------------------------------------
  set(${EZ_PROJ_VER}_INCLUDE_DIRS
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src/lib>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/src/lib>
    #$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/extern>
    $<INSTALL_INTERFACE:${EZ_INSTALL_INCDIR}>
    )

  # GIT
  # ----------------------------------------
  # Find git, get the revision number
  # From  https://github.com/bast/cmake-example
  # ----------------------------------------
  find_package(Git)
  if (GIT_FOUND)
    # Get the git revision
    execute_process(
      COMMAND ${GIT_EXECUTABLE} rev-list --max-count=1 HEAD
      OUTPUT_VARIABLE GIT_REVISION
      ERROR_QUIET
      )
    if (NOT ${GIT_REVISION} STREQUAL "")
      string(STRIP ${GIT_REVISION} GIT_REVISION)
    endif()
    message(STATUS "Current git revision is ${GIT_REVISION}")
  else()
    set(GIT_REVISION "unknown")
  endif()

  # Add appropriate include directories
  message("${BoldMagenta}[ EZMake :: Include directories ]${ColourReset}")
  foreach(dir ${${EZ_PROJ_VER}_INCLUDE_DIRS})
    message(STATUS "${dir}")
    include_directories(${dir})
  endforeach()
  message("${BoldCyan}[ EZMake :: ${EZ_PROJ_VER} ${BoldGreen}initialised${BoldCyan} ]${ColourReset}")

endmacro()

macro(ez_proj_check_init)
  if (NOT DEFINED EZ_PROJ_VER)
    message(FATAL_ERROR "${BoldRed}[ EZMake :: ERROR ] ez_unit_init(): Initialize project first \n${BoldBlue} Use ez_proj_init() at ${CMAKE_SOURCE_DIR}.${ColourReset}")
  endif()
endmacro()


## EZMAKE ADD INCLUDE DIRECTORY
# ------------------------------------------------------------------------
# ez_include(folder)
# This macro does the following:
#
# Adds the folder to ${EZ_PROJ_VER}_INCLUDE_DIRS
#
macro(ez_include folder)
  ez_proj_check_init()
  set(${EZ_PROJ_VER}_INCLUDE_DIRS ${${EZ_PROJ_VER}_INCLUDE_DIRS} $<BUILD_INTERFACE:${folder}>)
  include_directories($<BUILD_INTERFACE:${folder}>)
  message("${Magenta}[ EZMake :: Added include directory ]${ColourReset}")
  message(STATUS "$<BUILD_INTERFACE:${folder}>")
endmacro()

macro(ez_include_this)
  ez_include(${CMAKE_CURRENT_SOURCE_DIR})
  ez_include(${CMAKE_CURRENT_BINARY_DIR})
endmacro()

## EZMAKE EXPORT PROJECT - SHOULD BE THE LAST THING
# ------------------------------------------------------------------------
# ez_proj_export()
# This macro does the following:
#
# Iterates over EZ_PROJ_LIBS and EZ_PROJ_APPS
# Populates it with the above units exported config files.
# ${EZ_PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake
# And installs the above total project config file.
#
# This enables the end user to use find_package({PROJECT_NAME})
# and it'll be equivalent to including every installed library
# individually.
#
# In most conceivable cases be the last function that CMake runs.
#
# Also see:
#   ez_install_this_unit(as)
#
macro(ez_proj_export)
  if (NOT ${PROJECT_NAME}_NO_INSTALL)
    ez_proj_check_init()
    message("${Cyan}[ EZMake :: ${EZ_PROJ_VER} ${Green}exporting${Cyan} ]${ColourReset}")
    message(STATUS "Exporting units...")
    get_property(export_libs GLOBAL PROPERTY EZ_PROJ_LIBS)
    get_property(export_apps GLOBAL PROPERTY EZ_PROJ_APPS)
    #get_filename_component(SELF_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
    set(EZ_PROJ_LIBS_EXPORT "# libraries")
    set(EZ_PROJ_APPS_EXPORT "# applications")

    # First generate the list of includes for libraries
    foreach(lib ${export_libs})
      set(EZ_PROJ_LIBS_EXPORT "${EZ_PROJ_LIBS_EXPORT}\ninclude(\${CMAKE_CURRENT_LIST_DIR}/${lib}-config.cmake)")
      message(STATUS "Library Unit ${lib} - included")
    endforeach()
    # now the apps
    foreach(app ${export_apps})
      set(EZ_PROJ_APPS_EXPORT "${EZ_PROJ_APPS_EXPORT}\ninclude(\${CMAKE_CURRENT_LIST_DIR}/${app}-config.cmake)")
      message(STATUS "Application Unit ${app} - included")
    endforeach()

    # Make the substitution in the project cmake file
    configure_file(${PROJECT_SOURCE_DIR}/cmake/ezmake/EZMake_thisproj-config.cmake.in
      ${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake @ONLY)

    # Install the file
    install(FILES ${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake
      DESTINATION ${EZ_INSTALL_DATADIR}/cmake)

    message(STATUS "Done... users can now find_package(${PROJECT_NAME}) after install.")

    message("${BoldCyan}[ EZMake :: ${EZ_PROJ_VER} ${BoldGreen}DONE!${BoldCyan} ]${ColourReset}")
  endif()

endmacro()
