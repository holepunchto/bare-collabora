cmake_minimum_required(VERSION 4.0)

find_package(cmake-bare REQUIRED PATHS node_modules/cmake-bare)
find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)
find_package(cmake-ports REQUIRED PATHS node_modules/cmake-ports)

project(bare_collabora C CXX)

find_port(libreoffice)

add_bare_module(bare_collabora)

target_sources(
  ${bare_collabora}
  PRIVATE
    binding.cc
)

target_link_libraries(
  ${bare_collabora}
  PUBLIC
    libreoffice
)

get_target_property(libraries libreoffice COLLABORA_RUNTIME_DEPENDENCIES)

get_target_property(assets libreoffice COLLABORA_ASSETS_DIR)

bare_target(target)

bare_module_target("." module NAME name)

install(
  IMPORTED_RUNTIME_ARTIFACTS ${libraries}
  DESTINATION ${target}/${name}
)

install(
  DIRECTORY "${assets}"
  DESTINATION "${CMAKE_SOURCE_DIR}/assets/${target}"
  FILES_MATCHING
    # Configuration
    PATTERN "bootstraprc"
    PATTERN "fundamentalrc"
    PATTERN "lounorc"

    # Directories
    REGEX "/filter/"
    REGEX "/gallery/"
    REGEX "/liblangtag/"
    REGEX "/palette/"
    REGEX "/presets/"
    REGEX "/registry/"
    REGEX "/services/"
    REGEX "/types/"
    REGEX "/ure/"

    # Fonts
    PATTERN "Caladea-*.ttf"
    PATTERN "Carlito-*.ttf"
    PATTERN "EmojiOne*.ttf"
    PATTERN "Gen*.ttf"
    PATTERN "Liberation*.ttf"
    PATTERN "opens___.ttf"
)
