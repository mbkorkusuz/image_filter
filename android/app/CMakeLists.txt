cmake_minimum_required(VERSION 3.4.1)

project(image_filter_ffi)

add_library(
    filters
    SHARED
    ../../src/filter.cpp
)

target_include_directories(filters PRIVATE
    ../../src
    ../../opencv/include
)

set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--hash-style=both -Wl,-z,max-page-size=16384")

target_link_libraries(filters
    ${CMAKE_CURRENT_SOURCE_DIR}/../../opencv/libs/${ANDROID_ABI}/libopencv_java4.so
    log
    android
)
