# Temporary change
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install"
    CACHE STRING "Install path prefix, prepended onto install directories"
    FORCE)

set(install_dir ${CMAKE_INSTALL_PREFIX})
set(bin_dir ${install_dir}/bin)
set(lib_dir ${install_dir}/lib)

INSTALL(
    TARGETS robomongo
    DESTINATION ${bin_dir})

INSTALL(
    FILES
        ${CMAKE_SOURCE_DIR}/LICENSE
        ${CMAKE_SOURCE_DIR}/COPYRIGHT
        ${CMAKE_SOURCE_DIR}/CHANGELOG
    DESTINATION
        ${install_dir})

INSTALL(
    PROGRAMS
        ${CMAKE_SOURCE_DIR}/install/linux/robomongo.sh
    DESTINATION
        ${bin_dir})


function(install_qt_lib)
    foreach(module ${ARGV})
        set(module_name Qt5${module})
        set(target_name Qt5::${module})

        # Get full path to library (i.e. /path/to/libQt5Widgets.so.5.5.1)
        get_target_property(target_path ${target_name} LOCATION)

        # Resolve symlinks if any
        get_filename_component(real_target_path ${target_path} REALPATH)

        # Get folder path of library (i.e. /path/to)
        get_filename_component(target_dir ${real_target_path} DIRECTORY)

        # Get file name of library (i.e. libQt5Widgets.so.5.5.1)
        get_filename_component(target_file ${real_target_path} NAME)

        # Install library
        install(
            FILES ${real_target_path}
            DESTINATION ${lib_dir})

        if(SYSTEM_LINUX)
            # Find major version (5 for Qt5)
            set(module_version_major ${${module_name}_VERSION_MAJOR})

            # Prepare symlink file name (for Qt5Core it will be libQt5Core.so.5)
            set(symlink_file_name ${CMAKE_SHARED_LIBRARY_PREFIX}${module_name}${CMAKE_SHARED_LIBRARY_SUFFIX}.${module_version_major})

            # Create symlink (for Qt5Core it will be: libQt5Core.so.5 => libQt5Core.so.5.5.1)
            install(CODE "
                message(STATUS \"Installing: ${lib_dir}/${symlink_file_name}\")
                execute_process(
                    COMMAND ln -sf ${target_file} ${symlink_file_name}
                    WORKING_DIRECTORY ${lib_dir})")
        endif()
    endforeach()
endfunction()

function(install_icu_libs)
    # We are trying to get 'lib' folder of Qt installation.
    # For this we take some known target (Qt5::Core in this case)
    # and taking path to this library.

    # Get full path to known library (i.e. /path/to/lib/libQt5Core.so.5.5.1)
    get_target_property(target_path Qt5::Core LOCATION)

    # Get absolute path to 'lib' folder (which is a parent folder of 'known' library)
    get_filename_component(qt_lib_dir ${target_path} DIRECTORY)

    # Not very good solution, but we simply take all files with *icu* in names (including symlinks)
    file(GLOB icu_libs ${qt_lib_dir}/${CMAKE_SHARED_LIBRARY_PREFIX}icu*)

    # Install to "lib" folder
    install(FILES ${icu_libs}
            DESTINATION ${lib_dir})
endfunction()

install_qt_lib(Core Gui Widgets)
install_icu_libs()
