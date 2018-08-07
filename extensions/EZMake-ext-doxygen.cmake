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

# DOXYGEN DOCUMENTATION
# ----------------------------------------
# Automatic API documentation generation
# based on Doxygen. Input and output
# files and directories are hard coded
# intentionally to sane defaults / best
# practice.
# ----------------------------------------
macro(ez_proj_ext_doxygen)
  ez_proj_check_init()
  message("${BoldBlue}[ EZMake :: Doxygen ]${ColourReset}")
  find_package(Doxygen)
  if (NOT DOXYGEN_FOUND)
    message(FATAL_ERROR "${BoldRed}Doxygen is needed to build API documentation${ColourReset}")
  endif()

  set(doxy_main_page ${PROJECT_SOURCE_DIR}/docs/Doxymain.md)
  set(DOXYGEN_IN ${PROJECT_SOURCE_DIR}/docs/Doxyfile.in)
  set(DOXYGEN_OUT ${PROJECT_BINARY_DIR}/docs/Doxyfile)
  configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
  message("${Magenta}[ EZMake :: Configured Doxygen file ]${ColourReset}")
  message(STATUS "${DOXYGEN_OUT}")

  add_custom_target(doc
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Generating API documentation with Doxygen"
    VERBATIM)
  if (NOT ${PROJECT_NAME}_NO_INSTALL)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/docs/ DESTINATION ${EZ_INSTALL_DOCDIR} OPTIONAL)
  endif()

  message(STATUS "${Green}Doxygen: ${DOXYGEN_EXECUTABLE}${ColourReset}")

endmacro()
