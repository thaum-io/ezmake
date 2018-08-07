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
macro(ez_proj_ext_swig)
  ez_proj_check_init()
  message("${BoldBlue}[ EZMake :: SWIG -> Python ]${ColourReset}")
  find_package(SWIG)
  find_package(PythonLibs REQUIRED)
  if (NOT SWIG_FOUND)
    message(FATAL_ERROR "${BoldRed}SWIG and PythonLibs is needed to build python modules${ColourReset}")
  endif()
  include(${SWIG_USE_FILE})
  ez_include(${PYTHON_INCLUDE_PATH})
  message(STATUS "${Green}Python: ${PYTHON_INCLUDE_PATH})${ColourReset}")
  message(STATUS "${Green}SWIG: ${SWIG_EXECUTABLE} (found version ${SWIG_VERSION})${ColourReset}")
endmacro()
