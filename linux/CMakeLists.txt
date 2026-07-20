# Project-level configuration.
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Set compilers to GCC (more reliable than Clang on your system)
set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)

# Configure build options.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Enable verbose builds.
set(CMAKE_VERBOSE_MAKEFILE ON)

# Find required packages.
find_package(PkgConfig REQUIRED)

# Define the application name.
set(APPLICATION_NAME "agri_waste_connected")

# Include the Flutter tooling CMake module.
include(flutter/generated_plugins.cmake)

# Add the Flutter desktop application.
add_executable(${APPLICATION_NAME}
  main.cc
  my_application.cc
  ${FLUTTER_MANAGED_PLUGINS}
)

# Apply the Flutter tooling configuration.
apply_flutter_config(${APPLICATION_NAME})

# Add the necessary dependencies.
target_link_libraries(${APPLICATION_NAME}
  ${FLUTTER_LIBRARIES}
  ${FLUTTER_PLUGIN_LIBRARIES}
)

# Include directories.
target_include_directories(${APPLICATION_NAME}
  ${FLUTTER_INCLUDE_DIRS}
  ${FLUTTER_PLUGIN_INCLUDE_DIRS}
)

# Install the application.
install(TARGETS ${APPLICATION_NAME}
  RUNTIME DESTINATION bin
)
