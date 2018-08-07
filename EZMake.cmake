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
# _____ _______  __       _
#| ____|__  /  \/  | __ _| | _____
#|  _|   / /| |\/| |/ _` | |/ / _ \
#| |___ / /_| |  | | (_| |   <  __/
#|_____/____|_|  |_|\__,_|_|\_\___|
#
##################################################################################

# Include provides:
## ez_proj_init(), ez_include(), ez_proj_export()
include(${CMAKE_CURRENT_LIST_DIR}/EZMake-project.cmake)

# Include provides:
## ez_unit_init(as), ez_this_unit_add_code(name),
## ez_this_unit_add_tests(names...), ez_this_unit_link_tests(extra_args_targets...)
## ez_this_unit_build(extra_args_sources), ez_this_unit_link(extra_args_targets...)
## ez_this_unit_install()
include(${CMAKE_CURRENT_LIST_DIR}/EZMake-unit.cmake)

file(GLOB extensions ${CMAKE_CURRENT_LIST_DIR}/extensions/EZMake-ext*.cmake)
message("${BoldGreen}[ EZMake :: Available Extensions ]${ColourReset}")
foreach(ext ${extensions})
  message(STATUS ${ext})
  include(${ext})
endforeach()

OPTION(${PROJECT_NAME}_WITH_TESTING "Build tests/examples" ON)
OPTION(${PROJECT_NAME}_NO_INSTALL "Skip installation process" OFF)
