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
include(${CMAKE_CURRENT_LIST_DIR}/EZMake-project.cmake)

## EASY MAKE UNIT INTIALIZATION.
# ------------------------------------------------------------------------
# ez_unit_init()
# This macro does the following:
#
# Defines the following variables
#
#   EZ_THIS_UNIT_NAME               - pulled from the folder name
#   EZ_THIS_UNIT_NAME_FULL          - {PROJECT_NAME}_{EZ_THIS_UNIT_NAME}
#   EZ_THIS_UNIT_HEADERS            - list
#   EZ_THIS_UNIT_SOURCES            - list
#  {EZ_THIS_UNIT_NAME_FULL}_HEADERS - list
#  {EZ_THIS_UNIT_NAME_FULL}_SOURCES - list
#
macro(ez_unit_init as)
  ez_proj_check_init()

  # VARIABLES
  # ----------------------------------------
  set(EZ_THIS_UNIT_HEADERS "")
  set(EZ_THIS_UNIT_SOURCES "")
  set(${EZ_THIS_UNIT_NAME_FULL}_HEADERS "")
  set(${EZ_THIS_UNIT_NAME_FULL}_SOURCES "")
  set(EZ_THIS_UNIT_TYPE ${as})

  if (${as} STREQUAL "lib")
    get_filename_component(EZ_THIS_UNIT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    set(EZ_THIS_UNIT_NAME_FULL ${PROJECT_NAME}_${EZ_THIS_UNIT_NAME})
    message("${Blue}[ EZMake :: Library Unit ${EZ_THIS_UNIT_NAME_FULL} ]${ColourReset}")
  elseif (${as} STREQUAL "bin")
    get_filename_component(EZ_THIS_UNIT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    set(EZ_THIS_UNIT_NAME_FULL ${EZ_THIS_UNIT_NAME})
    message("${Blue}[ EZMake :: Application Unit ${EZ_THIS_UNIT_NAME_FULL} ]${ColourReset}")
  else()
    message(FATAL_ERROR "${BoldRed}[ EZMake :: Unit ${name} ] Unit type must be - lib, bin${ColourReset}")
  endif()

  message(STATUS "Unit initialized at ${CMAKE_CURRENT_SOURCE_DIR}")
endmacro()

## EZ MAKE UNIT ERROR MESSAGE
# ------------------------------------------------------------------------
macro(ez_unit_check_init)
  if (NOT DEFINED EZ_THIS_UNIT_NAME_FULL)
    message(FATAL_ERROR "${BoldRed}[ EZMake :: ERROR ] Initialize unit first\n${BoldBlue} Use ez_unit_init() at\n ${CMAKE_CURRENT_SOURCE_DIR}${ColourReset}")
  endif()
endmacro()

## EZ MAKE UNIT ADD HEADER
# ------------------------------------------------------------------------
# ez_unit_add_header(unitname filename)
# This macro does the following:
#
# Appends to variables
#  {filename} to {unitname}_HEADERS
#
# Also see:
#   ez_this_unit_add_header(filename)
#   ez_unit_add_source(unitname filename)
#
macro(ez_unit_add_header unitname filename)
  set(${unitname}_HEADERS ${$unitname}_HEADERS ${filename})
endmacro()

## EZ MAKE THIS UNIT ADD HEADER
# ------------------------------------------------------------------------
# ez_this_unit_add_header(filename)
# This macro calls: ez_unit_add_header assuming name is of this unit.
#
# Also see:
#   ez_this_unit_add_source(filelname)
#
macro(ez_this_unit_add_header filename)
  ez_unit_check_init()
  ez_unit_add_header(${EZ_THIS_UNIT_NAME_FULL} ${filename})
  set(EZ_THIS_UNIT_HEADERS ${EZ_THIS_UNIT_HEADERS} ${filename})
endmacro()

## EZ MAKE UNIT ADD SOURCE
# ------------------------------------------------------------------------
# ez_unit_add_source(unitname filename)
# This macro does the following:
#
# Appends to variables
#  {filename} to {unitname}_SOURCES
#
# Also see:
#   ez_this_unit_add_source(filename)
#   ez_unit_add_header(unitname filename)
#
macro(ez_unit_add_source unitname filename)
    set(${unitname}_SOURCES ${$unitname}_SOURCES ${filename})
endmacro()

## EZ MAKE THIS UNIT ADD SOURCE
# ------------------------------------------------------------------------
# ez_this_unit_add_source(filename)
# This macro calls: ez_unit_add_source assuming name is of this unit.
#
# Also see:
#   ez_this_unit_add_header(filelname)
#
macro(ez_this_unit_add_source filename)
  ez_unit_check_init()
  ez_unit_add_source(${EZ_THIS_UNIT_NAME_FULL} ${filename})
  set(EZ_THIS_UNIT_SOURCES ${EZ_THIS_UNIT_SOURCES} ${filename})
endmacro()


## EZ MAKE UNIT ADD CODE
# ------------------------------------------------------------------------
# ez_unit_add(unitname filename)
# This macro does the following:
#
# Appends to variables
#  {filename}.${cc} to {unitname}_SOURCES
#  {filename}.${hh} to {unitname}_HEADERS
#
# Also see:
#   ez_this_unit_add(filename)
#   ez_unit_add_header(unitname filename)
#   ez_unit_add_source(unitname filename)
#   ez_this_unit_add_header(filename)
#   ez_this_unit_add_source(filename)
#
macro(ez_unit_add_code unitname filename hh cc)
  ez_unit_add_header(${unitname} ${filename}.${hh})
  ez_unit_add_source(${unitname} ${filename}.${cc})
endmacro()

## EZ MAKE THIS UNIT ADD CODE
# ------------------------------------------------------------------------
# ez_this_unit_add(filename)
# This macro calls: ez_unit_add assuming name is of this unit.
#
macro(ez_this_unit_add_code filename hh cc)
  ez_unit_check_init()
  ez_unit_add_code(${EZ_THIS_UNIT_NAME_FULL} ${filename} ${hh} ${cc})
  set(EZ_THIS_UNIT_SOURCES ${EZ_THIS_UNIT_SOURCES} ${filename}.${cc})
  set(EZ_THIS_UNIT_HEADERS ${EZ_THIS_UNIT_HEADERS} ${filename}.${hh})
endmacro()

## EZ MAKE UNIT ADD BUILD TARGET
# ------------------------------------------------------------------------
macro(ez_this_unit_build)
  ez_unit_check_init()
  if (${EZ_THIS_UNIT_TYPE} STREQUAL "lib")
    add_library(${EZ_THIS_UNIT_NAME_FULL} ${ARGN} ${EZ_THIS_UNIT_SOURCES})
  elseif (${EZ_THIS_UNIT_TYPE} STREQUAL "bin")
    add_executable(${EZ_THIS_UNIT_NAME} ${ARGN} ${EZ_THIS_UNIT_SOURCES})
  endif()
endmacro()
## EZ MAKE UNIT LINK BUILD TARGET
# ------------------------------------------------------------------------
macro(ez_this_unit_link)
  ez_unit_check_init()
  target_link_libraries(${EZ_THIS_UNIT_NAME_FULL} ${ARGN})
endmacro()


## EZ MAKE THIS UNIT ADD TESTS
# ------------------------------------------------------------------------
macro(ez_this_unit_add_tests)
  if (${${PROJECT_NAME}_WITH_TESTING})
    ez_unit_check_init()
    add_executable(${PROJECT_NAME}test_${EZ_THIS_UNIT_NAME} ${ARGN})
    target_link_libraries(${PROJECT_NAME}test_${EZ_THIS_UNIT_NAME} ${EZ_THIS_UNIT_NAME_FULL})
    add_test(NAME ${EZ_THIS_UNIT_TYPE}${EZ_THIS_UNIT_NAME_FULL} COMMAND ${PROJECT_NAME}test_${EZ_THIS_UNIT_NAME})
    set(tick "")
    foreach(arg ${ARGN})
      set(tick "✔${tick}")
    endforeach()
    message(STATUS "${Green}Added ${ARGC} unit test files - ${tick}${ColourReset}")
  endif()
endmacro()

## EZ MAKE THIS UNIT LINK TEST
# ------------------------------------------------------------------------
macro(ez_this_unit_link_tests)
  if (${${PROJECT_NAME}_WITH_TESTING})
    ez_unit_check_init()
    target_link_libraries(${PROJECT_NAME}test_${EZ_THIS_UNIT_NAME} ${ARGN})
  endif()
endmacro()


## EZ MAKE INSTALL UNIT
# ------------------------------------------------------------------------
# ez_install_unit(unitname as)
# This macro does the following:
#
# Appends to variables
#  {unitname} to EZ_PROJ_{upper(as)} - These get exported with project
#
# Installs unit as a component given by {as} into directories as
# defined during project initialization. It also exports the unit
# into the file {EZ_INSTALL_DATADIR}/cmake/{unitname}-config.cmake
# This way ussers should be able to use find_package(fullunitname)
# to import just a single library out of a project.
#
# Also see:
#   ez_install_this_unit(as)
#
macro(ez_unit_install name as)
  if (NOT ${PROJECT_NAME}_NO_INSTALL)
    if (${as} STREQUAL "lib")
      set_property(GLOBAL APPEND PROPERTY EZ_PROJ_LIBS ${name})
      install(FILES ${EZ_THIS_UNIT_HEADERS} DESTINATION ${EZ_INSTALL_INCDIR}/${EZ_THIS_UNIT_NAME})
      message(STATUS "Library Unit ${name} - installed")
    elseif (${as} STREQUAL "bin")
      set_property(GLOBAL APPEND PROPERTY EZ_PROJ_APPS ${name})
      message(STATUS "Application Unit ${name} - installed")
    else()
      message(FATAL_ERROR "${BoldRed}[ EZMake :: Unit ${name} ] Install type must be - lib, bin${ColourReset}")
    endif()

    install(TARGETS ${name}
      EXPORT ${name}-config
      RUNTIME DESTINATION ${EZ_INSTALL_BINDIR}
      LIBRARY DESTINATION ${EZ_INSTALL_LIBDIR}
      ARCHIVE DESTINATION ${EZ_INSTALL_LIBDIR}
      PUBLIC_HEADER DESTINATION ${EZ_INSTALL_INCDIR}/${EZ_THIS_UNIT_NAME}
      INCLUDES DESTINATION ${EZ_INSTALL_INCDIR}/${EZ_THIS_UNIT_NAME}
      COMPONENT ${as})

    install(EXPORT ${name}-config DESTINATION ${EZ_INSTALL_DATADIR}/cmake)
  endif()
endmacro()


## EZ MAKE INSTALL THIS UNIT
# ------------------------------------------------------------------------
# ez_this_unit_install()
# This macro calls: ez_install_unit assuming name and type is of this unit.
#
# Also see:
#   ez_install_unit(unitname as)
#
macro(ez_this_unit_install)
  ez_unit_check_init()
  ez_unit_install(${EZ_THIS_UNIT_NAME_FULL} ${EZ_THIS_UNIT_TYPE})
endmacro()
