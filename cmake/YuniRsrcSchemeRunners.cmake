include(YuniDetectPlatform)

# Generate Nmosh/Sagittarius/Gauche styled loadpath list
macro(gen_loadpath0 var first)
    if(WIN32)
        set(_pathsep ";")
    else()
        set(_pathsep ":")
    endif()
    set(_out ${first})
    foreach(e ${ARGN})
        set(_out "${_out}${_pathsep}${e}")
    endforeach()
    set(${var} "${_out}")
endmacro()

macro(gen_loadpath var)
    gen_loadpath0(_tmp ${ARGN})
    set(${var} "--loadpath=${_tmp}")
endmacro()

macro(gen_platformpath var plt) # FIXME: Merge with toplevel CMakeLists.txt
    if(${plt} STREQUAL "WIN64")
        set(${var} lib-stub/yunistub-win64)
    elseif(${plt} STREQUAL "WIN32")
        set(${var} lib-stub/yunistub-win32)
    elseif(${plt} STREQUAL "CYGWIN32")
        set(${var} lib-stub/yunistub-cygwin32)
    elseif(${plt} STREQUAL "CYGWIN64")
        set(${var} lib-stub/yunistub-cygwin64)
    else()
        set(${var} lib-stub/yunistub)
    endif()
endmacro()

macro(gen_libopts var opt)
    set(${var})
    foreach(e ${ARGN})
        list(APPEND ${var} "${opt}${e}")
    endforeach()
endmacro()

macro(gen_impl_commandline var type runtimeprefix)
    set(${var})
    if("${type}" STREQUAL NMOSH)
        gen_loadpath(${var} ${ARGN})
    else()
        if("${type}" STREQUAL GUILE)
            gen_libopts(${var} "-L;" ${ARGN})
            set(${var} -l ${runtimeprefix}/lib-runtime/guile/guile-load.scm
                ${${var}})
        elseif("${type}" STREQUAL GAUCHE)
            gen_libopts(${var} "-I;" ${ARGN})
            set(${var} -r7 ${${var}} -A ${runtimeprefix})
        elseif("${type}" STREQUAL SAGITTARIUS)
            gen_libopts(${var} "--loadpath=" ${ARGN})
        elseif("${type}" STREQUAL CHIBI_SCHEME)
            gen_libopts(${var} "-I;" ${ARGN})
        elseif("${type}" STREQUAL RACKET)
            gen_libopts(${var} "++path;" ${ARGN})
            set(${var} -I scheme/init -l- r6rs/run.rkt ${${var}})
        elseif("${type}" STREQUAL VICARE)
            gen_libopts(${var} "--source-path;" ${ARGN})
        elseif("${type}" STREQUAL CHICKEN)
            set(${var} -b -require-extension r7rs -s
                ${runtimeprefix}/yuniloader/yuniloader-csi.scm
                --yuniffi-stubdir ${YUNI_PLATFORM_LIBDIR})
        elseif("${type}" STREQUAL LARCENY)
            gen_loadpath0(_loadpath ${ARGN})
            set(${var} -r7r6 -path ${_loadpath} -program)
        elseif("${type}" STREQUAL CHEZ_SCHEME)
            gen_loadpath0(_loadpath ${ARGN})
            set(${var} "--libdirs ${_loadpath} --program")
        elseif("${type}" STREQUAL RAPID_GAMBIT)
            gen_libopts(${var} "-I;" ${ARGN})
        elseif("${type}" STREQUAL PICRIN)
            set(${var} 
                ${runtimeprefix}/yuniloader/yuniloader-picrin.scm
                --yuniffi-stubdir ${YUNI_PLATFORM_LIBDIR})
        elseif("${type}" STREQUAL GAMBIT)
            gen_libopts(${var} "-I;" ${ARGN})
            set(${var}
                ${runtimeprefix}/yuniloader/yuniloader-gsi.scm
                ${${var}} -MOD ${YUNI_PLATFORM_LIBDIR}
                -PROG)
        elseif("${type}" STREQUAL MIT_SCHEME)
            gen_libopts(${var} "-I;" ${ARGN})
            set(${var}
                -YUNIROOT ${runtimeprefix}
                --batch-mode
                --load
                ${runtimeprefix}/yuniloader/yuniloader-mit-scheme.scm
                --
                ${${var}} -MOD ${YUNI_PLATFORM_LIBDIR}
                -PROG)
        else()
            message(FATAL_ERROR "Unknown scheme type ${type}")
        endif()
    endif()
endmacro()


##
## CHIBI_SCHEME
## 
#   Chibi-scheme has run_* macros to bootstrap the tree.
##

macro(run_chibi_scheme_bootstrap cmd script root result)
    execute_process(
        COMMAND "${cmd}"
        "${script}"
        WORKING_DIRECTORY "${root}"
        RESULT_VARIABLE ${result})
endmacro()

macro(run_chibi_scheme cmd script root result)
    gen_impl_commandline(__loadpath_full
        CHIBI_SCHEME
        ${root}
        lib-stub/chibi
        lib-runtime/r7rs
        lib-runtime/chibi)
    execute_process(
        COMMAND "${cmd}"
        ${__loadpath_full} "${script}"
        WORKING_DIRECTORY "${root}"
        RESULT_VARIABLE ${result})
endmacro()

##
## NMOSH
## 
#   NMosh has run_* macros to bootstrap the tree.
##

macro(run_nmosh_bootstrap nmosh script root result)
    gen_loadpath(__loadpath_bootstrap
        scripts/lib-bootstrap
        lib
        lib-compat)
    execute_process(
        COMMAND "${nmosh}"
        "${__loadpath_bootstrap}" "${script}"
        WORKING_DIRECTORY "${root}"
        RESULT_VARIABLE ${result})
endmacro()

macro(run_nmosh nmosh script root result)
    gen_loadpath(__loadpath_full
        lib-runtime/nmosh
        lib-r6rs
        lib-stub/r6rs-common
        lib
        lib-compat
        lib-compat/yuni-srfi
        lib-stub/nmosh
        lib-stub/gen)
    execute_process(
        COMMAND "${nmosh}"
        "${__loadpath_full}" "${script}"
        WORKING_DIRECTORY "${root}"
        RESULT_VARIABLE ${result})
endmacro()

macro(add_nmosh_test nam platform nmosh script root)
    gen_platformpath(_platform ${platform})
    gen_loadpath(__loadpath_full
        ${_platform}
        lib-runtime/nmosh
        lib-r6rs
        lib-stub/r6rs-common
        lib
        lib-compat
        lib-compat/yuni-srfi
        lib-stub/nmosh
        lib-stub/gen)
    add_test(NAME ${nam}
        COMMAND "${nmosh}"
        "${__loadpath_full}" "${script}"
        WORKING_DIRECTORY "${root}")
endmacro()
