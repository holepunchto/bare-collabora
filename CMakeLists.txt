cmake_minimum_required(VERSION 4.0)

find_package(cmake-bare REQUIRED PATHS node_modules/cmake-bare)
find_package(cmake-fetch REQUIRED PATHS node_modules/cmake-fetch)
find_package(cmake-ports REQUIRED PATHS node_modules/cmake-ports)

project(bare_collabora C CXX)

fetch_package("github:holepunchto/libjstl#6b78e1e")

find_port(libreoffice)

bare_target(target)

set(name bare-collabora-${target})

add_bare_module(bare_collabora NAME ${name})

set_target_properties(
  ${bare_collabora}
  PROPERTIES
  CXX_SCAN_FOR_MODULES OFF
)

target_sources(
  ${bare_collabora}
  PRIVATE
    binding.cc
)

target_link_libraries(
  ${bare_collabora}
  PRIVATE
    jstl
  PUBLIC
    libreoffice
)

get_target_property(libraries libreoffice COLLABORA_RUNTIME_DEPENDENCIES)

get_target_property(assets libreoffice COLLABORA_ASSETS_DIR)

install(
  IMPORTED_RUNTIME_ARTIFACTS ${libraries}
  DESTINATION ${target}/${name}
)

install(
  DIRECTORY "${assets}"
  DESTINATION ${target}/${name}/assets
  FILES_MATCHING
    # Configuration
    PATTERN "bootstraprc"
    PATTERN "bootstrap.ini"
    PATTERN "fundamentalrc"
    PATTERN "fundamental.ini"
    PATTERN "lounorc"
    PATTERN "louno.ini"
    PATTERN "unorc"
    PATTERN "uno.ini"

    # UNO services
    PATTERN "*.rdb"

    # ICU data
    PATTERN "ICU.dat"

    # Fontconfig
    PATTERN "fonts.conf"
    PATTERN "*.conf"

    # Directories
    REGEX "/filter/"
    REGEX "/fontconfig/"
    REGEX "/gallery/"
    REGEX "/liblangtag/"
    REGEX "/palette/"
    REGEX "/presets/"
    REGEX "/registry/"
    REGEX "/services/"
    REGEX "/types/"
    REGEX "/ure/"

    # UI
    PATTERN "*.ui"

    # Fonts
    PATTERN "Caladea-*.ttf"
    PATTERN "Carlito-*.ttf"
    PATTERN "EmojiOne*.ttf"
    PATTERN "Gen*.ttf"
    PATTERN "Liberation*.ttf"
    PATTERN "opens___.ttf"
)
