########################################################################################################################
#
# Library: PCTK
#
# Copyright (C) 2023 ChengXueWen. Contact: 1398831004@qq.com
#
# License: MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
########################################################################################################################


pctk_configure_feature("ENABLE_ASSERT" PUBLIC
        LABEL "Enable this to build enable assert"
        CONDITION ON)

pctk_configure_feature("ENABLE_CHECK" PUBLIC
        LABEL "Enable this to build enable check"
        CONDITION ON)

pctk_configure_feature("ENABLE_DEBUG" PUBLIC
        LABEL "Enable this to build enable debug"
        CONDITION ON)

pctk_configure_feature("ENABLE_VALGRIND" PUBLIC
        LABEL "Enable this to build enable valgrind"
        DISABLE MSVC
        CONDITION ON)


# libuv for io backend
pctk_configure_feature("LIBUV_BACKEND" PUBLIC
        LABEL "Enable this to build libuv as the backend"
        CONDITION OFF)

# icu (International Component for Unicode) feature
pctk_configure_feature("ICU" PUBLIC
        LABEL "Enable this to build icu as the timezone backend"
        AUTODETECT NOT WIN32
        CONDITION ICU_FOUND)


# std atomics
pctk_configure_compile_test(STD_ATOMIC
        LABEL "Check standard c atomic"
        CODE
        "#include <stdatomic.h>
         #if defined(__STDC_NO_ATOMICS__) || __STDC_NO_ATOMICS__
         #   error \"no stdc atomics\"
         #endif
         int main(void)
         {
         _Atomic int value;
         return 0;
         }")
pctk_configure_feature("STD_ATOMIC" PUBLIC
        LABEL "Use standard c atomic"
        AUTODETECT ${TEST_STD_ATOMIC}
        CONDITION ${TEST_STD_ATOMIC})


# std threads
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)
set(PCTK_BUILD_WITH_THREAD ${Threads_FOUND})
set(PCTK_BUILD_USE_PTHREADS ${CMAKE_USE_PTHREADS_INIT})
set(PCTK_BUILD_USE_WIN32_THREADS ${CMAKE_USE_WIN32_THREADS_INIT})
pctk_configure_compile_test(STD_THREAD
        LABEL "Check standard c thread"
        CODE
        "#include <threads.h>
         #if defined(__STDC_NO_THREADS__) || __STDC_NO_THREADS__
         #   error \"no stdc threads\"
         #endif
         int main(void)
         {
         cnd_t cond;
         mtx_t mutex;
         tss_t key;
         thrd_t thread;
         return 0;
         }")
pctk_configure_feature("STD_THREAD" PUBLIC
        LABEL "Use standard c thread"
        AUTODETECT ${TEST_STD_THREAD}
        CONDITION ${TEST_STD_THREAD})


# std time
pctk_configure_compile_test(STD_TIME
        LABEL "Check standard c time"
        CODE
        "#include <time.h>
         #if !defined(TIME_UTC) || !TIME_UTC
         #   error \"no stdc time\"
         #endif
         int main(void)
         {
         struct timespec ts;
         timespec_get(&ts, TIME_UTC);
         return 0;
         }")
pctk_configure_feature("STD_TIME" PUBLIC
        LABEL "Use standard c time"
        AUTODETECT ${TEST_STD_TIME}
        CONDITION ${TEST_STD_TIME})


pctk_configure_feature("TIMEZONE" PUBLIC
        SECTION "Utilities"
        LABEL "pctk_timezone_t"
        PURPOSE "Provides support for time-zone handling."
        CONDITION NOT PCTK_SYSTEM_EMSCRIPTEN)


# pctk version
pctk_configure_definition("PCTK_VERSION_STR" PUBLIC VALUE "\"${PROJECT_VERSION}\"")
pctk_configure_definition("PCTK_VERSION_MAJOR" PUBLIC VALUE ${PROJECT_VERSION_MAJOR})
pctk_configure_definition("PCTK_VERSION_MINOR" PUBLIC VALUE ${PROJECT_VERSION_MINOR})
pctk_configure_definition("PCTK_VERSION_PATCH" PUBLIC VALUE ${PROJECT_VERSION_PATCH})

# pctk lib type
if(BUILD_SHARED_LIBS)
    pctk_configure_definition("PCTK_SHARED" PUBLIC)
else()
    pctk_configure_definition("PCTK_STATIC" PUBLIC)
endif()

# pctk debug/optimization type
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    pctk_configure_definition("PCTK_DEBUG" PUBLIC)
endif()

# int8_t type
pctk_configure_compile_test_type(INT8_T
        TYPE "int8_t"
        LABEL "Check int8_t type")
# int16_t type
pctk_configure_compile_test_type(INT16_T
        TYPE "int16_t"
        LABEL "Check int16_t type")
# int32_t type
pctk_configure_compile_test_type(INT32_T
        TYPE "int32_t"
        LABEL "Check int32_t type")
# int64_t type
pctk_configure_compile_test_type(INT64_T
        TYPE "int64_t"
        LABEL "Check int64_t type")
# uint8_t type
pctk_configure_compile_test_type(UINT8_T
        TYPE "uint8_t"
        LABEL "Check uint8_t type")
# uint16_t type
pctk_configure_compile_test_type(UINT16_T
        TYPE "uint16_t"
        LABEL "Check uint16_t type")
# uint32_t type
pctk_configure_compile_test_type(UINT32_T
        TYPE "uint32_t"
        LABEL "Check uint32_t type")
# uint64_t type
pctk_configure_compile_test_type(UINT64_T
        TYPE "uint64_t"
        LABEL "Check uint64_t type")
# __uint128_t type
pctk_configure_compile_test_type(UINT128_T
        TYPE "__uint128_t"
        LABEL "Check __uint128_t type")
# wchar_t type
pctk_configure_compile_test_type(WCHAR_T
        TYPE "wchar_t"
        LABEL "Check wchar_t type")
# char8_t type
pctk_configure_compile_test_type(CHAR8_T
        TYPE "char8_t"
        LABEL "Check char8_t type")
# char16_t type
pctk_configure_compile_test_type(CHAR16_T
        TYPE "char16_t"
        LABEL "Check char16_t type")
# char32_t type
pctk_configure_compile_test_type(CHAR32_T
        TYPE "char32_t"
        LABEL "Check char32_t type")
# char type
pctk_configure_compile_test_type(CHAR
        TYPE "char"
        LABEL "Check char type")
# short type
pctk_configure_compile_test_type(SHORT
        TYPE "short"
        LABEL "Check short type")
# int type
pctk_configure_compile_test_type(INT
        TYPE "int"
        LABEL "Check int type")
# float type
pctk_configure_compile_test_type(FLOAT
        TYPE "float"
        LABEL "Check float type")
# double type
pctk_configure_compile_test_type(DOUBLE
        TYPE "double"
        LABEL "Check double type")
# long type
pctk_configure_compile_test_type(LONG
        TYPE "long"
        LABEL "Check long type")
# long long type
pctk_configure_compile_test_type(LONG_LONG
        TYPE "long long"
        LABEL "Check long long type")
# unsigned char type
pctk_configure_compile_test_type(UCHAR
        TYPE "unsigned char"
        LABEL "Check unsigned char type")
# unsigned short type
pctk_configure_compile_test_type(USHORT
        TYPE "unsigned short"
        LABEL "Check unsigned short type")
# unsigned int type
pctk_configure_compile_test_type(UINT
        TYPE "unsigned int"
        LABEL "Check unsigned int type")
# unsigned long type
pctk_configure_compile_test_type(ULONG
        TYPE "unsigned long"
        LABEL "Check unsigned long type")
# unsigned long long type
pctk_configure_compile_test_type(ULONG_LONG
        TYPE "unsigned long long"
        LABEL "Check unsigned long long type")
# void* type
pctk_configure_compile_test_type(VOIDP
        TYPE "void*"
        LABEL "Check void* type")
# size_t type
pctk_configure_compile_test_type(SIZE_T
        TYPE "size_t"
        LABEL "Check size_t type")
# ssize_t type
pctk_configure_compile_test_type(SSIZE_T
        TYPE "ssize_t"
        LABEL "Check ssize_t type")
# ptrdiff_t type
pctk_configure_compile_test_type(PTRDIFF_T
        TYPE "ptrdiff_t"
        LABEL "Check ptrdiff_t type")


pctk_configure_definition("PCTK_HAS_INT8_T" PUBLIC VALUE ${TEST_INT8_T})
pctk_configure_definition("PCTK_HAS_INT16_T" PUBLIC VALUE ${TEST_INT16_T})
pctk_configure_definition("PCTK_HAS_INT32_T" PUBLIC VALUE ${TEST_INT32_T})
pctk_configure_definition("PCTK_HAS_INT64_T" PUBLIC VALUE ${TEST_INT64_T})
pctk_configure_definition("PCTK_HAS_UINT8_T" PUBLIC VALUE ${TEST_UINT8_T})
pctk_configure_definition("PCTK_HAS_UINT16_T" PUBLIC VALUE ${TEST_UINT16_T})
pctk_configure_definition("PCTK_HAS_UINT32_T" PUBLIC VALUE ${TEST_UINT32_T})
pctk_configure_definition("PCTK_HAS_UINT64_T" PUBLIC VALUE ${TEST_UINT64_T})
pctk_configure_definition("PCTK_HAS_UINT128_T" PUBLIC VALUE ${TEST_UINT128_T})
pctk_configure_definition("PCTK_HAS_WCHAR_T" PUBLIC VALUE ${TEST_WCHAR_T})
pctk_configure_definition("PCTK_HAS_CHAR8_T" PUBLIC VALUE ${TEST_CHAR8_T})
pctk_configure_definition("PCTK_HAS_CHAR16_T" PUBLIC VALUE ${TEST_CHAR16_T})
pctk_configure_definition("PCTK_HAS_CHAR32_T" PUBLIC VALUE ${TEST_CHAR32_T})
pctk_configure_definition("PCTK_HAS_SSIZE_T" PUBLIC VALUE ${TEST_SSIZE_T})
pctk_configure_definition("PCTK_HAS_PTRDIFF_T" PUBLIC VALUE ${TEST_PTRDIFF_T})
pctk_configure_definition("PCTK_CHAR_SIZE" PUBLIC VALUE ${SIZEOF_CHAR})
pctk_configure_definition("PCTK_SHORT_SIZE" PUBLIC VALUE ${SIZEOF_SHORT})
pctk_configure_definition("PCTK_INT_SIZE" PUBLIC VALUE ${SIZEOF_INT})
pctk_configure_definition("PCTK_FLOAT_SIZE" PUBLIC VALUE ${SIZEOF_FLOAT})
pctk_configure_definition("PCTK_DOUBLE_SIZE" PUBLIC VALUE ${SIZEOF_DOUBLE})
pctk_configure_definition("PCTK_LONG_SIZE" PUBLIC VALUE ${SIZEOF_LONG})
pctk_configure_definition("PCTK_LONG_LONG_SIZE" PUBLIC VALUE ${SIZEOF_LONG_LONG})
pctk_configure_definition("PCTK_UCHAR_SIZE" PUBLIC VALUE ${SIZEOF_UCHAR})
pctk_configure_definition("PCTK_USHORT_SIZE" PUBLIC VALUE ${SIZEOF_USHORT})
pctk_configure_definition("PCTK_UINT_SIZE" PUBLIC VALUE ${SIZEOF_UINT})
pctk_configure_definition("PCTK_ULONG_SIZE" PUBLIC VALUE ${SIZEOF_ULONG})
pctk_configure_definition("PCTK_ULONG_LONG_SIZE" PUBLIC VALUE ${SIZEOF_ULONG_LONG})
pctk_configure_definition("PCTK_VOIDP_SIZE" PUBLIC VALUE ${SIZEOF_VOIDP})
pctk_configure_definition("PCTK_SIZE_T_SIZE" PUBLIC VALUE ${SIZEOF_SIZE_T})
pctk_configure_definition("PCTK_SSIZE_T_SIZE" PUBLIC VALUE ${SIZEOF_SSIZE_T})
pctk_configure_definition("PCTK_PTRDIFF_T_SIZE" PUBLIC VALUE ${SIZEOF_PTRDIFF_T})


# stpcpy
pctk_configure_compile_test_symbol(STPCPY
        SYMBOL "stpcpy"
        INCLUDE_FILES "string.h"
        LABEL "Check stpcpy symbol.")
# strcpy
pctk_configure_compile_test_symbol(STRCPY
        SYMBOL "strcpy"
        INCLUDE_FILES "string.h"
        LABEL "Check strcpy symbol.")
# strcpy_s
pctk_configure_compile_test_symbol(STRCPY_S
        SYMBOL "strcpy_s"
        INCLUDE_FILES "string.h"
        LABEL "Check strcpy_s symbol.")
# strncpy
pctk_configure_compile_test_symbol(STRNCPY
        SYMBOL "strncpy"
        INCLUDE_FILES "string.h"
        LABEL "Check strncpy symbol.")
# strncpy_s
pctk_configure_compile_test_symbol(STRNCPY_S
        SYMBOL "strncpy_s"
        INCLUDE_FILES "string.h"
        LABEL "Check strncpy_s symbol.")
# strlcpy
pctk_configure_compile_test_symbol(STRLCPY
        SYMBOL "strlcpy"
        INCLUDE_FILES "string.h"
        LABEL "Check strlcpy symbol.")
# strlcat
pctk_configure_compile_test_symbol(STRLCAT
        SYMBOL "strlcat"
        INCLUDE_FILES "string.h"
        LABEL "Check strlcat symbol.")
# strcasecmp
pctk_configure_compile_test_symbol(STRCASECMP
        SYMBOL "strcasecmp"
        INCLUDE_FILES "string.h"
        LABEL "Check strcasecmp symbol.")
# strncasecmp
pctk_configure_compile_test_symbol(STRNCASECMP
        SYMBOL "strncasecmp"
        INCLUDE_FILES "string.h"
        LABEL "Check strncasecmp symbol.")
# vprintf
pctk_configure_compile_test_symbol(VPRINTF
        SYMBOL "vprintf"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vprintf symbol.")
# vfprintf
pctk_configure_compile_test_symbol(VFPRINTF
        SYMBOL "vfprintf"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vfprintf symbol.")
# vsprintf
pctk_configure_compile_test_symbol(VSPRINTF
        SYMBOL "vsprintf"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vsprintf symbol.")
# vsprintf
pctk_configure_compile_test_symbol(VSNPRINTF
        SYMBOL "vsnprintf"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vsnprintf symbol.")
# vprintf_s
pctk_configure_compile_test_symbol(VPRINTF_S
        SYMBOL "vprintf_s"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vprintf_s symbol.")
# vfprintf_s
pctk_configure_compile_test_symbol(VFPRINTF_S
        SYMBOL "vfprintf_s"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vfprintf_s symbol.")
# vsprintf_s
pctk_configure_compile_test_symbol(VSPRINTF_S
        SYMBOL "vsprintf_s"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vsprintf_s symbol.")
# vsnprintf_s
pctk_configure_compile_test_symbol(VSNPRINTF_S
        SYMBOL "vsnprintf_s"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vsnprintf_s symbol.")
# vasprintf
pctk_configure_compile_test_symbol(VASPRINTF
        SYMBOL "vasprintf"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vasprintf symbol.")
# vasnprintf
pctk_configure_compile_test_symbol(VASNPRINTF
        SYMBOL "vasnprintf"
        INCLUDE_FILES "stdio.h"
        LABEL "Check vasnprintf symbol.")
# accept4
pctk_configure_compile_test_symbol(ACCEPT4
        SYMBOL "accept4"
        INCLUDE_FILES "sys/socket.h"
        LABEL "Check accept4 symbol.")
# prlimit
pctk_configure_compile_test_symbol(PRLIMIT
        SYMBOL "prlimit"
        INCLUDE_FILES "sys/resource.h"
        LABEL "Check prlimit symbol.")
# setlocale
pctk_configure_compile_test_symbol(LOCALE
        SYMBOL "setlocale"
        INCLUDE_FILES "locale.h"
        LABEL "Check setlocale symbol.")
# setenv
pctk_configure_compile_test_symbol(SETENV
        SYMBOL "setenv"
        INCLUDE_FILES "stdlib.h"
        LABEL "Check setenv symbol.")
# unsetenv
pctk_configure_compile_test_symbol(UNSETENV
        SYMBOL "unsetenv"
        INCLUDE_FILES "stdlib.h"
        LABEL "Check unsetenv symbol.")
# _NSGetEnviron
pctk_configure_compile_test_symbol(NSGETENVIRON
        SYMBOL "_NSGetEnviron"
        INCLUDE_FILES "stdlib.h"
        LABEL "Check _NSGetEnviron symbol.")
# nl_langinfo
pctk_configure_compile_test_symbol(LANGINFO
        SYMBOL "nl_langinfo"
        INCLUDE_FILES "langinfo.h"
        LABEL "Check nl_langinfo symbol.")
# SYS_sched_getattr
pctk_configure_compile_test_symbol(SYS_SCHED_GETATTR
        SYMBOL "SYS_sched_getattr"
        INCLUDE_FILES "sys/syscall.h"
        LABEL "Check SYS_sched_getattr symbol.")
# memalign
pctk_configure_compile_test_symbol(MEMALIGN
        SYMBOL "memalign"
        INCLUDE_FILES "stdlib.h" "malloc.h"
        LABEL "Check memalign symbol.")
# aligned_alloc
pctk_configure_compile_test_symbol(ALIGNED_ALLOC
        SYMBOL "aligned_alloc"
        INCLUDE_FILES "stdlib.h"
        LABEL "Check aligned_alloc symbol.")
# nl_langinfo
pctk_configure_compile_test_symbol(LANGINFO
        SYMBOL "nl_langinfo"
        INCLUDE_FILES "langinfo.h"
        LABEL "Check nl_langinfo symbol.")
# posix_memalign
pctk_configure_compile_test_symbol(POSIX_MEMALIGN
        SYMBOL "posix_memalign"
        INCLUDE_FILES "stdlib.h"
        LABEL "Check posix_memalign symbol.")
# posix_spawn
pctk_configure_compile_test_symbol(POSIX_SPAWN
        SYMBOL "posix_spawn"
        INCLUDE_FILES "spawn.h"
        LABEL "Check posix_spawn symbol.")
# pthread_attr_setstacksize
pctk_configure_compile_test_symbol(PTHREAD_ATTR_SETSTACKSIZE
        SYMBOL "pthread_attr_setstacksize"
        LIBRARIES ${CMAKE_THREAD_LIBS_INIT}
        INCLUDE_FILES "pthread.h"
        LABEL "Check pthread_attr_setstacksize symbol.")
# pthread_attr_setinheritsched
pctk_configure_compile_test_symbol(PTHREAD_ATTR_SETINHERITSCHED
        SYMBOL "pthread_attr_setinheritsched"
        LIBRARIES ${CMAKE_THREAD_LIBS_INIT}
        INCLUDE_FILES "pthread.h"
        LABEL "Check pthread_attr_setinheritsched symbol.")
# pthread_condattr_setclock
pctk_configure_compile_test_symbol(PTHREAD_CONDATTR_SETCLOCK
        SYMBOL "pthread_condattr_setclock"
        LIBRARIES ${CMAKE_THREAD_LIBS_INIT}
        INCLUDE_FILES "pthread.h"
        LABEL "Check pthread_condattr_setclock symbol.")
# pthread_cond_timedwait_relative_np
pctk_configure_compile_test_symbol(PTHREAD_COND_TIMEDWAIT_RELATIVE_NP
        SYMBOL "pthread_cond_timedwait_relative_np"
        LIBRARIES ${CMAKE_THREAD_LIBS_INIT}
        INCLUDE_FILES "pthread.h"
        LABEL "Check pthread_cond_timedwait_relative_np symbol.")
# pthread_getname_np
pctk_configure_compile_test_symbol(PTHREAD_GETNAME_NP
        SYMBOL "pthread_getname_np"
        LIBRARIES ${CMAKE_THREAD_LIBS_INIT}
        INCLUDE_FILES "pthread.h"
        LABEL "Check pthread_getname_np symbol.")

pctk_configure_definition("PCTK_HAS_STPCPY" PUBLIC VALUE ${TEST_STPCPY})
pctk_configure_definition("PCTK_HAS_STRCPY" PUBLIC VALUE ${TEST_STRCPY})
pctk_configure_definition("PCTK_HAS_STRCPY_S" PUBLIC VALUE ${TEST_STRCPY_S})
pctk_configure_definition("PCTK_HAS_STRNCPY" PUBLIC VALUE ${TEST_STRNCPY})
pctk_configure_definition("PCTK_HAS_STRNCPY_S" PUBLIC VALUE ${TEST_STRNCPY_S})
pctk_configure_definition("PCTK_HAS_STRLCPY" PUBLIC VALUE ${TEST_STRLCPY})
pctk_configure_definition("PCTK_HAS_STRLCAT" PUBLIC VALUE ${TEST_STRLCAT})
pctk_configure_definition("PCTK_HAS_STRCASECMP" PUBLIC VALUE ${TEST_STRCASECMP})
pctk_configure_definition("PCTK_HAS_STRNCASECMP" PUBLIC VALUE ${TEST_STRNCASECMP})
pctk_configure_definition("PCTK_HAS_VPRINTF" PUBLIC VALUE ${TEST_VPRINTF})
pctk_configure_definition("PCTK_HAS_VFPRINTF" PUBLIC VALUE ${TEST_VFPRINTF})
pctk_configure_definition("PCTK_HAS_VSPRINTF" PUBLIC VALUE ${TEST_VSPRINTF})
pctk_configure_definition("PCTK_HAS_VSNPRINTF" PUBLIC VALUE ${TEST_VSNPRINTF})
pctk_configure_definition("PCTK_HAS_VPRINTF_S" PUBLIC VALUE ${TEST_VPRINTF_S})
pctk_configure_definition("PCTK_HAS_VFPRINTF_S" PUBLIC VALUE ${TEST_VFPRINTF_S})
pctk_configure_definition("PCTK_HAS_VSPRINTF_S" PUBLIC VALUE ${TEST_VSPRINTF_S})
pctk_configure_definition("PCTK_HAS_VSNPRINTF_S" PUBLIC VALUE ${TEST_VSNPRINTF_S})
pctk_configure_definition("PCTK_HAS_VASPRINTF" PUBLIC VALUE ${TEST_VASPRINTF})
pctk_configure_definition("PCTK_HAS_VASNPRINTF" PUBLIC VALUE ${TEST_VASNPRINTF})
pctk_configure_definition("PCTK_HAS_ACCEPT4" PUBLIC VALUE ${TEST_ACCEPT4})
pctk_configure_definition("PCTK_HAS_PRLIMIT" PUBLIC VALUE ${TEST_PRLIMIT})
pctk_configure_definition("PCTK_HAS_LOCALE" PUBLIC VALUE ${TEST_LOCALE})
pctk_configure_definition("PCTK_HAS_SETENV" PUBLIC VALUE ${TEST_SETENV})
pctk_configure_definition("PCTK_HAS_UNSETENV" PUBLIC VALUE ${TEST_UNSETENV})
pctk_configure_definition("PCTK_HAS_NSGETENVIRON" PUBLIC VALUE ${TEST_NSGETENVIRON})
pctk_configure_definition("PCTK_HAS_LANGINFO" PUBLIC VALUE ${TEST_LANGINFO})
pctk_configure_definition("PCTK_HAS_SYS_SCHED_GETATTR" PUBLIC VALUE ${TEST_SYS_SCHED_GETATTR})
pctk_configure_definition("PCTK_HAS_MEMALIGN" PUBLIC VALUE ${TEST_MEMALIGN})
pctk_configure_definition("PCTK_HAS_ALIGNED_ALLOC" PUBLIC VALUE ${TEST_ALIGNED_ALLOC})
pctk_configure_definition("PCTK_HAS_LANGINFO" PUBLIC VALUE ${TEST_LANGINFO})
pctk_configure_definition("PCTK_HAS_POSIX_MEMALIGN" PUBLIC VALUE ${TEST_POSIX_MEMALIGN})
pctk_configure_definition("PCTK_HAS_POSIX_SPAWN" PUBLIC VALUE ${TEST_POSIX_SPAWN})
pctk_configure_definition("PCTK_HAS_PTHREAD_ATTR_SETSTACKSIZE" PUBLIC VALUE ${TEST_PTHREAD_ATTR_SETSTACKSIZE})
pctk_configure_definition("PCTK_HAS_PTHREAD_ATTR_SETINHERITSCHED" PUBLIC VALUE ${TEST_PTHREAD_ATTR_SETINHERITSCHED})
pctk_configure_definition("PCTK_HAS_PTHREAD_CONDATTR_SETCLOCK" PUBLIC VALUE ${TEST_PTHREAD_CONDATTR_SETCLOCK})
pctk_configure_definition("PCTK_HAS_PTHREAD_COND_TIMEDWAIT_RELATIVE_NP" PUBLIC VALUE ${TEST_PTHREAD_COND_TIMEDWAIT_RELATIVE_NP})
pctk_configure_definition("PCTK_HAS_PTHREAD_GETNAME_NP" PUBLIC VALUE ${TEST_PTHREAD_GETNAME_NP})


# stdint.h
pctk_configure_compile_test_include(STDINT
        INCLUDE "stdint.h"
        LABEL "Check stdint.h header.")
# stdbool.h
pctk_configure_compile_test_include(STDBOOL
        INCLUDE "stdint.h"
        LABEL "Check stdbool.h header.")
# stddef.h
pctk_configure_compile_test_include(STDDEF
        INCLUDE "stddef.h"
        LABEL "Check stddef.h header.")
# stdalign.h
pctk_configure_compile_test_include(STDALIGN
        INCLUDE "stdalign.h"
        LABEL "Check stdalign.h header.")
# alloca.h
pctk_configure_compile_test_include(ALLOCA
        INCLUDE "alloca.h"
        LABEL "Check alloca.h header.")
# inttypes.h
pctk_configure_compile_test_include(INTTYPES
        INCLUDE "inttypes.h"
        LABEL "Check inttypes.h header.")
# sys/prctl.h
pctk_configure_compile_test_include(SYS_PRCTL
        INCLUDE "sys/prctl.h"
        LABEL "Check sys/prctl.h header.")
# sys/time.h
pctk_configure_compile_test_include(SYS_TIME
        INCLUDE "sys/time.h"
        LABEL "Check sys/time.h header.")

pctk_configure_definition("PCTK_HAS_STDINT" PUBLIC VALUE ${TEST_STDINT})
pctk_configure_definition("PCTK_HAS_STDBOOL" PUBLIC VALUE ${TEST_STDBOOL})
pctk_configure_definition("PCTK_HAS_STDDEF" PUBLIC VALUE ${TEST_STDDEF})
pctk_configure_definition("PCTK_HAS_STDALIGN" PUBLIC VALUE ${TEST_STDALIGN})
pctk_configure_definition("PCTK_HAS_ALLOCA" PUBLIC VALUE ${TEST_ALLOCA})
pctk_configure_definition("PCTK_HAS_INTTYPES" PUBLIC VALUE ${TEST_INTTYPES})
pctk_configure_definition("PCTK_HAS_SYS_PRCTL" PUBLIC VALUE ${TEST_SYS_PRCTL})
pctk_configure_definition("PCTK_HAS_SYS_TIME" PUBLIC VALUE ${TEST_SYS_TIME})


# gnu typeof
pctk_configure_compile_test(TYPEOF
        LABEL "Check gnu typeof"
        CODE
        "#include <stdlib.h>
         int main(void)
         {
         typeof(int) i = 0;
         return 0;
         }")
# gnuc varargs macros
pctk_configure_compile_test(GNUC_VARARGS
        LABEL "Check gnuc varargs macros"
        CODE
        "#include <stdarg.h>
         void output(void *p, char *str, ...) {}
         #define call(p, args...) output(p, ##args)
         int main(void)
         {
         call(0, \"test %d\", 1);
         return 0;
         }")
# iso varargs macros
pctk_configure_compile_test(ISO_VARARGS
        LABEL "Check iso varargs macros"
        CODE
        "#include <stdarg.h>
         void output(void *p, char *str, ...) {}
         #define call(p, ...) output(p, __VA_ARGS__)
         int main(void)
         {
         call(0, \"test %d\", 1);
         return 0;
         }")
# int64_t is long type
pctk_configure_compile_test(INT64_IS_LONG_TYPE
        LABEL "Check int64_t is long type"
        FLAGS -Werror
        CODE
        "#if defined(_AIX) && !defined(__GNUC__)
         #pragma options langlvl=stdc99
         #endif
         #pragma GCC diagnostic error \"-Wincompatible-pointer-types\"
         #include <stdint.h>
         #include <stdio.h>
         int main(void)
         {
         int64_t i1 = 1;
         long *i2 = &i1;
         return 0;
         }")
# int64_t is long long type
pctk_configure_compile_test(INT64_IS_LONG_LONG_TYPE
        LABEL "Check int64_t is long long type"
        FLAGS -Werror
        CODE
        "#if defined(_AIX) && !defined(__GNUC__)
         #pragma options langlvl=stdc99
         #endif
         #pragma GCC diagnostic error \"-Wincompatible-pointer-types\"
         #include <stdint.h>
         #include <stdio.h>
         int main(void)
         {
         int64_t i1 = 1;
         long long *i2 = &i1;
         return 0;
         }")
# size_t is short type
pctk_configure_compile_test(SIZET_IS_SHORT_TYPE
        LABEL "Check size_t is short type"
        FLAGS -Werror
        CODE
        "#include <stddef.h>
         size_t f (size_t *i) { return *i + 1; }
         int main(void)
         {
         unsigned short i = 0;
         f (&i);
         return 0;
         }")
# size_t is int type
pctk_configure_compile_test(SIZET_IS_INT_TYPE
        LABEL "Check size_t is int type"
        FLAGS -Werror
        CODE
        "#include <stddef.h>
         size_t f (size_t *i) { return *i + 1; }
         int main(void)
         {
         unsigned int i = 0;
         f (&i);
         return 0;
         }")
# size_t is long type
pctk_configure_compile_test(SIZET_IS_LONG_TYPE
        LABEL "Check size_t is long type"
        FLAGS -Werror
        CODE
        "#include <stddef.h>
         size_t f (size_t *i) { return *i + 1; }
         int main(void)
         {
         unsigned long i = 0;
         f (&i);
         return 0;
         }")
# size_t is long long type
pctk_configure_compile_test(SIZET_IS_LONG_LONG_TYPE
        LABEL "Check size_t is long long type"
        FLAGS -Werror
        CODE
        "#include <stddef.h>
         size_t f (size_t *i) { return *i + 1; }
         int main(void)
         {
         unsigned long long i = 0;
         f (&i);
         return 0;
         }")
# Mac OS X Carbon support
pctk_configure_compile_test(CARBON
        LABEL "Check Mac OS X Carbon support"
        CODE
        "#include <Carbon/Carbon.h>
         #include <CoreServices/CoreServices.h>
         int main(void)
         {
         return 0;
         }")
# Mac OS X Cocoa support
pctk_configure_compile_test(COCOA
        LABEL "Check Mac OS X Cocoa support"
        CODE
        "#include <Cocoa/Cocoa.h>
         #ifdef GNUSTEP_BASE_VERSION
         #   error \"Detected GNUstep, not Cocoa\"
         #endif
         int main(void)
         {
         return 0;
         }")
# nl_langinfo and CODESET
pctk_configure_compile_test(LANGINFO_CODESET
        LABEL "Check for nl_langinfo and CODESET"
        CODE
        "#include <langinfo.h>
         int main(void)
         {
         char *codeset = nl_langinfo(CODESET);
         return 0;
         }")
# nl_langinfo and _NL_TIME_CODESET
pctk_configure_compile_test(LANGINFO_TIME_CODESET
        LABEL "Check for nl_langinfo and _NL_TIME_CODESET"
        CODE
        "#include <langinfo.h>
         int main(void)
         {
         char *codeset = nl_langinfo(_NL_TIME_CODESET);
         return 0;
         }")


pctk_configure_definition("PCTK_HAS_COCOA" PUBLIC VALUE ${TEST_COCOA})
pctk_configure_definition("PCTK_HAS_CARBON" PUBLIC VALUE ${TEST_CARBON})
pctk_configure_definition("PCTK_HAS_TYPEOF" PUBLIC VALUE ${TEST_TYPEOF})
pctk_configure_definition("PCTK_HAS_GNUC_VARARGS" PUBLIC VALUE ${TEST_GNUC_VARARGS})
pctk_configure_definition("PCTK_HAS_ISO_VARARGS" PUBLIC VALUE ${TEST_ISO_VARARGS})
pctk_configure_definition("PCTK_HAS_CODESET" PUBLIC VALUE ${TEST_LANGINFO_CODESET})
pctk_configure_definition("PCTK_HAS_LANGINFO_CODESET" PUBLIC VALUE ${TEST_LANGINFO_CODESET})
pctk_configure_definition("PCTK_HAS_LANGINFO_TIME_CODESET" PUBLIC VALUE ${TEST_LANGINFO_TIME_CODESET})
pctk_configure_definition("PCTK_INT64_IS_LONG_TYPE" PUBLIC VALUE ${TEST_INT64_IS_LONG_TYPE})
pctk_configure_definition("PCTK_INT64_IS_LONG_LONG_TYPE" PUBLIC VALUE ${TEST_INT64_IS_LONG_LONG_TYPE})
pctk_configure_definition("PCTK_SIZET_IS_SHORT_TYPE" PUBLIC VALUE ${TEST_SIZET_IS_SHORT_TYPE})
pctk_configure_definition("PCTK_SIZET_IS_INT_TYPE" PUBLIC VALUE ${TEST_SIZET_IS_INT_TYPE})
pctk_configure_definition("PCTK_SIZET_IS_LONG_TYPE" PUBLIC VALUE ${TEST_SIZET_IS_LONG_TYPE})
pctk_configure_definition("PCTK_SIZET_IS_LONG_LONG_TYPE" PUBLIC VALUE ${TEST_SIZET_IS_LONG_LONG_TYPE})


# Detect endian
include(TestBigEndian)
test_big_endian(PCTK_IS_BIG_ENDIAN)
pctk_configure_definition("PCTK_IS_BIG_ENDIAN" PUBLIC VALUE ${PCTK_IS_BIG_ENDIAN})