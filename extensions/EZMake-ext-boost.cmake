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

# SWIG / Python
# ----------------------------------------
# Generate Python modules from C++
# libraries.
# ----------------------------------------
macro(ez_proj_ext_boost)
  ez_proj_check_init()
  message("${BoldBlue}[ EZMake :: Boost C++ Libraries ]${ColourReset}")
  set(Boost_USE_MULTITHREADED ON)
  find_package(Boost ${ARGN})
  if (NOT Boost_FOUND)
    message(FATAL_ERROR "${BoldRed}Can not find Boost libraries. Are they installed?${ColourReset}")
  endif()
  #include(${Boost_USE_FILE})
  message(STATUS "${Green}Boost: ${Boost_INCLUDE_DIRS} (found version ${Boost_VERSION})${ColourReset}")
  ez_include(${Boost_INCLUDE_DIRS})
  #set(${EZ_PROJ_VER}_INCLUDE_DIRS ${${EZ_PROJ_VER}_INCLUDE_DIRS} $<BUILD_INTERFACE:${Boost_INCLUDE_DIRS}>)
endmacro()
