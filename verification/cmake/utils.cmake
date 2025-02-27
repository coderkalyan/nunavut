#
# Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Helpers and utilities used in our CMakeLists.txt. Put it in here to keep from
# cluttering that file up.
#

# +===========================================================================+
# | flag replacement
# +===========================================================================+
#
# :function: replace_c_std
# Add a given C -std argument within a string or add it if its not found
#
# :param str ARG_REPLACE_IN: The string to do the replacement within.
# :param str ARG_OVERRIDE_C_STD: The flag <em>value</em> to replace (i.e. just "c99" not "-std=c99")
function(replace_c_std ARG_OVERRIDE_C_STD
                       ARG_REPLACE_INOUT)

    string(REGEX REPLACE "-std=[a-fA-F0-9+:]+"
           "-std=${ARG_OVERRIDE_C_STD}"
           LOCAL_RESULT
           ${${ARG_REPLACE_INOUT}})
    set(${ARG_REPLACE_INOUT} ${LOCAL_RESULT} PARENT_SCOPE)
endfunction()

#
# :function: replace_cxx_std
# Add a given C++ -std argument within a string or add it if its not found
#
# :param str ARG_REPLACE_IN: The string to do the replacement within.
# :param str ARG_OVERRIDE_CXX_STD: The flag <em>value</em> to replace (i.e. just "c++14" not "-std=c++14")
function(replace_cxx_std ARG_OVERRIDE_CXX_STD
                         ARG_REPLACE_INOUT)

    string(REGEX REPLACE "-std=[a-fA-F0-9+:]+"
                         "-std=${ARG_OVERRIDE_CXX_STD}"
                         LOCAL_RESULT
                         ${${ARG_REPLACE_INOUT}})
    set(${ARG_REPLACE_INOUT} ${LOCAL_RESULT} PARENT_SCOPE)
endfunction()

# +===========================================================================+
# | Flag set handling
# +===========================================================================+
#
# :function: apply_flag_set
# CMake 3.10 compatible routine for loading this project's compiler flag sets
# (found under cmake/compiler_flag_sets) and properly setting the following cmake build variables:
#       - CMAKE_C_FLAGS
#       - CMAKE_CXX_FLAGS
#       - CMAKE_EXE_LINKER_FLAGS
#       - CMAKE_ASM_FLAGS
#
# :param Path ARG_FLAG_SET:                 The flagset file to include.
# :param str  ARG_OVERRIDE_C_STD:           Locally overridden -std flag for C.
# :param str  ARG_OVERRIDE_CXX_STD:         Locally overridden -std flag for C++.
function(apply_flag_set ARG_FLAG_SET
                        ARG_OVERRIDE_C_STD
                        ARG_OVERRIDE_CXX_STD)
    include(${ARG_FLAG_SET})

    # list(JOIN ) is a thing in cmake 3.12 but we only require 3.10.
    # Why 3.10? Because this is the version in Ubuntu 18.04 LTS.
    string(REPLACE ";" " " LOCAL_CMAKE_C_FLAGS "${C_FLAG_SET}")
    string(REPLACE ";" " " LOCAL_CMAKE_CXX_FLAGS "${CXX_FLAG_SET}")
    string(REPLACE ";" " " LOCAL_CMAKE_EXE_LINKER_FLAGS "${EXE_LINKER_FLAG_SET}")
    string(REPLACE ";" " " LOCAL_CMAKE_ASM_FLAGS "${ASM_FLAG_SET}")

    if (NOT ARG_OVERRIDE_C_STD STREQUAL "")
        replace_c_std(${ARG_OVERRIDE_C_STD} LOCAL_CMAKE_C_FLAGS)
        message(STATUS "Overriding C standard from flag set ${ARG_FLAG_SET} with ${ARG_OVERRIDE_C_STD}")
    endif()

    if (NOT ARG_OVERRIDE_CXX_STD STREQUAL "")
        replace_cxx_std(${ARG_OVERRIDE_CXX_STD} LOCAL_CMAKE_CXX_FLAGS)
        message(STATUS "Overriding C++ standard from flag set ${ARG_FLAG_SET} with ${ARG_OVERRIDE_CXX_STD}")
    endif()

    # +-----------------------------------------------------------------------+
    # | CONFIGURABLE DEFINITIONS
    # +-----------------------------------------------------------------------+
    if(NOT DEFINED NUNAVUT_CPP_ENABLE_EXCEPTIONS AND "-fexceptions" IN_LIST CXX_FLAG_SET)
        set(NUNAVUT_CPP_ENABLE_EXCEPTIONS 1)
    endif()

    if(DEFINED NUNAVUT_CPP_ENABLE_EXCEPTIONS)
        set(LOCAL_CMAKE_C_FLAGS "${LOCAL_CMAKE_C_FLAGS} -DNUNAVUT_CPP_ENABLE_EXCEPTIONS=${NUNAVUT_CPP_ENABLE_EXCEPTIONS}")
        set(LOCAL_CMAKE_CXX_FLAGS "${LOCAL_CMAKE_CXX_FLAGS} -DNUNAVUT_CPP_ENABLE_EXCEPTIONS=${NUNAVUT_CPP_ENABLE_EXCEPTIONS}")
    endif()

    if(NOT DEFINED NUNAVUT_CPP_ENABLE_EXCEPTIONS AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(NUNAVUT_CPP_INTROSPECTION_ENABLE_ASSERT 1)
    endif()

    if(DEFINED NUNAVUT_CPP_INTROSPECTION_ENABLE_ASSERT)
        set(LOCAL_CMAKE_C_FLAGS "${LOCAL_CMAKE_C_FLAGS} -DNUNAVUT_CPP_INTROSPECTION_ENABLE_ASSERT=${NUNAVUT_CPP_INTROSPECTION_ENABLE_ASSERT}")
        set(LOCAL_CMAKE_CXX_FLAGS "${LOCAL_CMAKE_CXX_FLAGS} -DNUNAVUT_CPP_INTROSPECTION_ENABLE_ASSERT=${NUNAVUT_CPP_INTROSPECTION_ENABLE_ASSERT}")
    endif()

    if(NOT DEFINED NUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(NUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE 1)
    endif()

    if(DEFINED NUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE)
        set(LOCAL_CMAKE_C_FLAGS "${LOCAL_CMAKE_C_FLAGS} -DNUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE=${NUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE}")
        set(LOCAL_CMAKE_CXX_FLAGS "${LOCAL_CMAKE_CXX_FLAGS} -DNUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE=${NUNAVUT_CPP_INTROSPECTION_TRACE_ENABLE}")
    endif()

    # +-----------------------------------------------------------------------+

    set(CMAKE_C_FLAGS ${LOCAL_CMAKE_C_FLAGS} PARENT_SCOPE)
    message(STATUS "apply_flag_set: CMAKE_C_FLAGS=${LOCAL_CMAKE_C_FLAGS}")

    set(CMAKE_CXX_FLAGS ${LOCAL_CMAKE_CXX_FLAGS} PARENT_SCOPE)
    message(STATUS "apply_flag_set: CMAKE_CXX_FLAGS=${LOCAL_CMAKE_CXX_FLAGS}")

    set(CMAKE_EXE_LINKER_FLAGS ${LOCAL_CMAKE_EXE_LINKER_FLAGS} PARENT_SCOPE)
    message(STATUS "apply_flag_set: CMAKE_EXE_LINKER_FLAGS=${LOCAL_CMAKE_EXE_LINKER_FLAGS}")

    set(CMAKE_ASM_FLAGS ${LOCAL_CMAKE_ASM_FLAGS} PARENT_SCOPE)
    message(STATUS "apply_flag_set: CMAKE_ASM_FLAGS=${LOCAL_CMAKE_ASM_FLAGS}")

    add_definitions(${DEFINITIONS_SET})

endfunction()

# +===========================================================================+
# | UNIT TESTING
# +===========================================================================+
#
# function: define_native_unit_test - creates an executable target and links it
# to the "all" target to build a gtest binary for the given test source.
#
# param: ARG_FRAMEWORK string - The name of the test framework to use.
# param: ARG_TEST_NAME string - The name to give the test binary.
# param: ARG_TEST_SOURCE List[path] - A list of source files to compile into
#                               the test binary.
# param: ARG_OUTDIR path - A path to output test binaries and coverage data under.
# param: ARG_EXTRA_COMPILE_FLAGS string - Additional compile arguments to set for
#                        the ARG_TEST_SOURCE files in addition to the arguments
#                        used for the current toolchain and language.
# param: ... List[str] - Zero to many targets that generate types under test.
#
function(define_native_unit_test
         ARG_FRAMEWORK
         ARG_TEST_NAME
         ARG_TEST_SOURCE
         ARG_OUTDIR
         ARG_EXTRA_COMPILE_FLAGS)

    add_executable(${ARG_TEST_NAME} ${ARG_TEST_SOURCE})

    if(NOT "${ARG_EXTRA_COMPILE_FLAGS}" STREQUAL "")
        string(REPLACE ";" " " LOCAL_${ARG_TEST_NAME}_COMPILE_FLAGS "${ARG_EXTRA_COMPILE_FLAGS}")
        set_source_files_properties(${ARG_TEST_SOURCE}
                                    PROPERTIES
                                    COMPILE_FLAGS
                                        ${LOCAL_${ARG_TEST_NAME}_COMPILE_FLAGS}
        )
    endif()

    set(LOCAL_${ARG_TEST_NAME}_LINK_LIBS "")

    if (${ARGC} GREATER 5)
        MATH(EXPR ARG_N_LAST "${ARGC}-1")
        foreach(ARG_N RANGE 5 ${ARG_N_LAST})
            list(APPEND LOCAL_${ARG_TEST_NAME}_LINK_LIBS ${ARGV${ARG_N}})
        endforeach(ARG_N)
    endif()

    target_link_libraries(${ARG_TEST_NAME} ${LOCAL_${ARG_TEST_NAME}_LINK_LIBS} "${ARG_EXTRA_COMPILE_FLAGS}")

    if (${ARG_FRAMEWORK} STREQUAL "gtest")
        target_link_libraries(${ARG_TEST_NAME} gmock_main)
    elseif (${ARG_FRAMEWORK} STREQUAL "unity")
        target_link_libraries(${ARG_TEST_NAME} unity_core)
    else()
        message(FATAL_ERROR "${ARG_FRAMEWORK} isn't a supported unit test framework. Currently we support gtest and unity.")
    endif()

    set_target_properties(${ARG_TEST_NAME}
                          PROPERTIES
                          RUNTIME_OUTPUT_DIRECTORY "${ARG_OUTDIR}"
    )

endfunction()


#
# function: define_native_test_run - creates a makefile target that will build and
# run individual unit tests.
#
# param: ARG_TEST_NAME string - The name of the test to run. A target will be created
#                          with the name run_${ARG_TEST_NAME}
# param: ARG_OUTDIR path - The path where the test binaries live.
#
function(define_native_test_run ARG_TEST_NAME ARG_OUTDIR)
    add_custom_target(
        run_${ARG_TEST_NAME}
        COMMAND
            ${ARG_OUTDIR}/${ARG_TEST_NAME}
        DEPENDS
            ${ARG_TEST_NAME}
    )

endfunction()
