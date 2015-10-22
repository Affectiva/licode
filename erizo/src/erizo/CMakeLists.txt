cmake_minimum_required(VERSION 2.6)
find_package(PkgConfig)
#functions
function(test_lib LIB_NAME)
  if (${LIB_NAME} MATCHES "^.*-NOTFOUND")
    message(FATAL_ERROR "lib not found: " ${LIB_NAME} " check README")
    return()
  endif(${LIB_NAME} MATCHES "^.*-NOTFOUND")
endfunction(test_lib)
project (ERIZO)


set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/")
set(ERIZO_VERSION_MAJOR 0)
set(ERIZO_VERSION_MINOR 1)
set(CMAKE_CXX_FLAGS "-g -Wall")

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

include_directories("${ERIZO_SOURCE_DIR}" "${ERIZO_SOURCE_DIR}/rtp" "${THIRD_PARTY_INCLUDE}")

file(GLOB_RECURSE ERIZO_SOURCES "${ERIZO_SOURCE_DIR}/*.h" "${ERIZO_SOURCE_DIR}/*.c" "${ERIZO_SOURCE_DIR}/*.cpp" "${ERIZO_SOURCE_DIR}/*.cc")

add_library(erizo SHARED ${ERIZO_SOURCES})

# GLIB
find_package(Glib REQUIRED)
include_directories(${GLIB_INCLUDE_DIRS})
target_link_libraries(erizo ${GLIB_LIBRARIES})

# BOOST
set (BOOST_LIBS thread regex system)
find_package(Boost COMPONENTS ${BOOST_LIBS} REQUIRED)
target_link_libraries(erizo ${Boost_LIBRARIES})

# GTHREAD
find_library(GTHREAD gthread-2.0 HINTS "${THIRD_PARTY_LIB}")
test_lib(${GTHREAD})

# SRTP
find_library(SRTP srtp HINTS "${THIRD_PARTY_LIB}")
test_lib(${SRTP})

# NICE
find_library(NICE nice HINTS "${THIRD_PARTY_LIB}")
test_lib(${NICE})

# OPENSSL
find_library(SSL ssl HINTS "${THIRD_PARTY_LIB}")
test_lib(${SSL})
find_library(CRYPTO crypto HINTS "${THIRD_PARTY_LIB}")
test_lib(${CRYPTO})

# Libav
find_library(AVUTIL avutil HINTS "${THIRD_PARTY_LIB}")
test_lib(${AVUTIL})
set (LIBS ${AVUTIL})
find_library(AVCODEC avcodec HINTS "${THIRD_PARTY_LIB}")
test_lib(${AVCODEC})
set (LIBS ${LIBS} ${AVCODEC})
find_library(AVFORMAT avformat HINTS "${THIRD_PARTY_LIB}")
test_lib(${AVFORMAT})
set (LIBS ${LIBS} ${AVFORMAT})

# LOG4CXX
find_library(LOG log4cxx)
test_lib(${LOG})

#message("Libs ${SRTP} ${NICE} ${GTHREAD} ${SSL} ${CRYPTO} ${LIBS} ${LOG}")

target_link_libraries(erizo ${SRTP} ${NICE} ${GTHREAD} ${SSL} ${CRYPTO} ${LIBS} ${LOG})
