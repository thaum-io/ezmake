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

include(${CMAKE_CURRENT_LIST_DIR}/colours.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../EZMake-project.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../EZMake-unit.cmake)

# CERN ROOT - Data analysis framework
# ----------------------------------------
# Include ROOT libraries and generate
# ROOT dictionaries for use at the ROOT
# interpreter.
# ----------------------------------------
macro(ez_proj_ext_root)
  ez_proj_check_init()
  message("${BoldBlue}[ EZMake :: CERN ROOT ]${ColourReset}")
  list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
  find_package(ROOT COMPONENTS RIO Net ${ARGN})
  if (NOT ROOT_FOUND)
    message(FATAL_ERROR "${BoldRed}Can not find CERN ROOT libraries. Check environment variable $ROOTSYS.${ColourReset}")
  endif()
  include(${ROOT_USE_FILE})
  ez_include(${ROOT_INCLUDE_DIRS})
  message(STATUS "${Green}ROOT: ${ROOT_INCLUDE_DIRS} (found version ${ROOT_VERSION})${ColourReset}")
  #set(${EZ_PROJ_VER}_INCLUDE_DIRS ${${EZ_PROJ_VER}_INCLUDE_DIRS} $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
endmacro()

macro(ez_this_unit_root_gen_rdict)
  ez_proj_check_init()

  set(EZ_THIS_UNIT_LINKDEF_HEADERS "// CMake EZ Make Generated CERN ROOT Linkdef")
  foreach(header ${EZ_THIS_UNIT_HEADERS})
    set(EZ_THIS_UNIT_LINKDEF_HEADERS "${EZ_THIS_UNIT_LINKDEF_HEADERS}\n#pragma link C++ defined_in ${CMAKE_CURRENT_SOURCE_DIR}/${header};")
  endforeach()

  set(EZ_THIS_UNIT_LINKDEF_FILE ${CMAKE_CURRENT_BINARY_DIR}/${EZ_THIS_UNIT_NAME_FULL}_Linkdef.h)
  if(${ARGC} STREQUAL "0")
    configure_file(${PROJECT_SOURCE_DIR}/cmake/ezmake/extensions/EZMake-ext-root-Linkdef.h.in ${EZ_THIS_UNIT_LINKDEF_FILE} @ONLY)
  else()
    configure_file(${ARGV0} ${EZ_THIS_UNIT_LINKDEF_FILE} @ONLY)
  endif()

  root_generate_dictionary(G__${EZ_THIS_UNIT_NAME_FULL} ${EZ_THIS_UNIT_HEADERS} LINKDEF ${EZ_THIS_UNIT_LINKDEF_FILE} OPTIONS "-I${CMAKE_CURRENT_SOURCE_DIR}")
  add_library(${EZ_THIS_UNIT_NAME_FULL}_rdict SHARED G__${EZ_THIS_UNIT_NAME_FULL})
  target_include_directories(${EZ_THIS_UNIT_NAME_FULL}_rdict PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
  target_link_libraries(${EZ_THIS_UNIT_NAME_FULL}_rdict ${ROOT_LIBRARIES})
  set_target_properties(${EZ_THIS_UNIT_NAME_FULL}_rdict PROPERTIES POSITION_INDEPENDENT_CODE ON)

  if (NOT ${PROJECT_NAME}_NO_INSTALL)
    install(TARGETS ${EZ_THIS_UNIT_NAME_FULL}_rdict
      EXPORT ${EZ_THIS_UNIT_NAME_FULL}-config
      LIBRARY DESTINATION ${EZ_INSTALL_LIBDIR}
      ARCHIVE DESTINATION ${EZ_INSTALL_LIBDIR})
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lib${EZ_THIS_UNIT_NAME_FULL}_rdict.pcm
      DESTINATION ${EZ_INSTALL_LIBDIR})
  endif()

endmacro()

macro(ez_proj_ext_root_gen_logon)
  set(EZ_ROOTLOGON_LIBS "// Libraries")
  get_property(libs GLOBAL PROPERTY EZ_PROJ_LIBS)
  foreach (lib ${libs})
    set(EZ_ROOTLOGON_LIBS "${EZ_ROOTLOGON_LIBS}\ngROOT->ProcessLine(\".L ${CMAKE_INSTALL_PREFIX}/${EZ_INSTALL_LIBDIR}/lib${lib}.so\");")
  endforeach()

  set(EZ_ROOTLOGON_INCLUDES "// Includes")
  set(EZ_ROOTLOGON_INCLUDES "${EZ_ROOTLOGON_INCLUDES}\ngROOT->ProcessLine(\".include ${CMAKE_INSTALL_PREFIX}/${EZ_INSTALL_INCDIR}\");")
  file(GLOB_RECURSE includes RELATIVE "${PROJECT_SOURCE_DIR}/src/lib" "${PROJECT_SOURCE_DIR}/src/lib/*.hh")

  foreach(inc ${includes})
    set(EZ_ROOTLOGON_INCLUDES "${EZ_ROOTLOGON_INCLUDES}\ngROOT->ProcessLine(\"#include <${inc}>\");")
  endforeach()

  configure_file(${PROJECT_SOURCE_DIR}/cmake/ezmake/extensions/EZMake-ext-root-logon.cc.in ${PROJECT_BINARY_DIR}/${PROJECT_NAME}logon.cc @ONLY)
  if (NOT ${PROJECT_NAME}_NO_INSTALL)
    install(FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}logon.cc DESTINATION ${EZ_INSTALL_DATADIR})
  endif()

endmacro()
