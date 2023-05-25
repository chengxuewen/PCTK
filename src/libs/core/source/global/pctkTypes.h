/***********************************************************************************************************************
**
** Library: PCTK
**
** Copyright (C) 2023 ChengXueWen. Contact: 1398831004@qq.com
**
** License: MIT License
**
** Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
** documentation files (the "Software"), to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
** and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in all copies or substantial portions
** of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
** TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
** THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
** CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
**
***********************************************************************************************************************/

#ifndef _PCTKTYPES_H
#define _PCTKTYPES_H

#include <pctkCoreConfig.h>
#include <pctkCompiler.h>
#include <pctkMacros.h>
#include <pctkSystem.h>

#include <sys/types.h>

#if PCTK_HAS_STDINT
#   include <stdint.h>
#endif

#if PCTK_HAS_STDBOOL
#   include <stdbool.h>
#endif

#if PCTK_HAS_STDDEF
#   include <stddef.h>
#endif

#if PCTK_HAS_STDALIGN
#   include <stdalign.h>
#endif

#if defined(PCTK_OS_WIN)
#   include <windows.h>
#endif


/********************************************************************************
    PCTK type define
********************************************************************************/
#if !PCTK_HAS_SSIZET && defined(PCTK_OS_WIN)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif

typedef void *pctk_pointer_t;
typedef const void *pctk_const_pointer_t;

#if PCTK_HAS_INT8_T
typedef int8_t pctk_int8_t;
#else
typedef signed char pctk_int8_t;
#endif

#if PCTK_HAS_INT16_T
typedef int16_t pctk_int16_t;
#else
typedef signed short pctk_int16_t;
#endif

#if PCTK_HAS_INT32_T
typedef int32_t pctk_int32_t;
#else
typedef signed int pctk_int32_t;
#endif

#if PCTK_HAS_INT64_T
typedef int64_t pctk_int64_t;
#else
#   if defined(PCTK_OS_WIN) && !defined(PCTK_CC_GNU) && !defined(PCTK_CC_MWERKS)
typedef __int64             pctk_int64_t;
#   else
typedef long long pctk_int64_t;
#   endif
#endif

#if PCTK_HAS_UINT8_T
typedef uint8_t pctk_uint8_t;
#else
typedef unsigned char pctk_uint8_t;
#endif

#if PCTK_HAS_UINT16_T
typedef uint16_t pctk_uint16_t;
#else
typedef unsigned short pctk_uint16_t;
#endif

#if PCTK_HAS_UINT32_T
typedef uint32_t pctk_uint32_t;
#else
typedef unsigned int pctk_uint32_t;
#endif

#if PCTK_HAS_UINT64_T
typedef uint64_t pctk_uint64_t;
#else
#   if defined(PCTK_OS_WIN) && !defined(PCTK_CC_GNU) && !defined(PCTK_CC_MWERKS)
typedef unsigned __int64    pctk_uint64_t;
#   else
typedef unsigned long long pctk_uint64_t;
#   endif
#endif

#if PCTK_HAS_CHAR8_T
typedef char8_t             pctk_unichar8_t;
#else
typedef pctk_uint8_t pctk_unichar8_t;
#endif

#if PCTK_HAS_CHAR16_T
typedef char16_t pctk_unichar16_t;
#else
typedef pctk_uint16_t pctk_unichar16_t;
#endif

#if PCTK_HAS_CHAR32_T
typedef char32_t pctk_unichar32_t;
#else
typedef pctk_uint32_t pctk_unichar32_t;
#endif

typedef int pctk_boolean_t;
#define pctk_true            1
#define pctk_false           0

typedef pctk_int64_t pctk_longlong_t;
typedef pctk_uint64_t pctk_ulonglong_t;

typedef size_t pctk_size_t;
typedef ssize_t pctk_ssize_t;
typedef off_t pctk_off_t;
typedef int pctk_options_t;
typedef unsigned char pctk_byte_t;

typedef char pctk_char_t;
typedef short pctk_short_t;
typedef int pctk_int_t;
typedef long pctk_long_t;
typedef pctk_char_t *pctk_char_array_t;

typedef float pctk_float_t;
typedef double pctk_double_t;

typedef unsigned char pctk_uchar_t;
typedef unsigned short pctk_ushort_t;
typedef unsigned int pctk_uint_t;
typedef unsigned long pctk_ulong_t;

#if defined(PCTK_OS_WIN)
typedef unsigned char       pctk_gid_t;
typedef unsigned char       pctk_uid_t;
typedef int                 pctk_pid_t;
typedef DWORD               pctk_tid_t;
#elif defined(PCTK_OS_DARWIN)
typedef gid_t pctk_gid_t;
typedef uid_t pctk_uid_t;
typedef pid_t pctk_pid_t;
typedef pctk_pointer_t pctk_tid_t;
#else
typedef gid_t pctk_gid_t;
typedef uid_t pctk_uid_t;
typedef pid_t pctk_pid_t;
typedef unsigned long int pctk_tid_t;
#endif
#define PCTK_TID_FORMAT      PCTK_UINT64_FORMAT

typedef pctk_int_t pctk_fd_t;
typedef pctk_size_t pctk_type_t;

#if defined(PCTK_COORD_TYPE)
typedef PCTK_COORD_TYPE pctk_real_t;
#else
typedef double pctk_real_t;
#endif


/*
   Size of a pointer and the machine register size. We detect a 64-bit system by:
   * GCC and compatible compilers (Clang, ICC on OS X and Windows) always define
     __SIZEOF_POINTER__. This catches all known cases of ILP32 builds on 64-bit
     processors.
   * Most other Unix compilers define __LP64__ or _LP64 on 64-bit mode
     (Long and Pointer 64-bit)
   * If PCTK_PROCESSOR_WORDSIZE was defined above, it's assumed to match the pointer
     size.
   Otherwise, we assume to be 32-bit and then check in qglobal.cpp that it is right.
*/

#if defined __SIZEOF_POINTER__
#   define PCTK_POINTER_SIZE           __SIZEOF_POINTER__
#elif defined(__LP64__) || defined(_LP64)
#   define PCTK_POINTER_SIZE           8
#elif defined(PCTK_PROCESSOR_WORDSIZE)
#   define PCTK_POINTER_SIZE           PCTK_PROCESSOR_WORDSIZE
#else
#   define PCTK_POINTER_SIZE           4
#endif


/********************************************************************************
    PCTK type format define
********************************************************************************/
#if PCTK_SHORT_SIZE == 2
#   define PCTK_INT16_MODIFIER   "h"
#   define PCTK_INT16_FORMAT     "hi"
#   define PCTK_UINT16_FORMAT    "hu"
#elif PCTK_INT_SIZE == 2
#   define PCTK_INT16_MODIFIER   ""
#   define PCTK_INT16_FORMAT     "i"
#   define PCTK_UINT16_FORMAT    "u"
#else
#   error "Compiler provides no native 16-bit integer type"
#endif

#if PCTK_SHORT_SIZE == 4
#   define PCTK_INT32_MODIFIER   "h"
#   define PCTK_INT32_FORMAT     "hi"
#   define PCTK_UINT32_FORMAT    "hu"
#elif PCTK_INT_SIZE == 4
#   define PCTK_INT32_MODIFIER   "h"
#   define PCTK_INT32_FORMAT     "i"
#   define PCTK_UINT32_FORMAT    "u"
#elif PCTK_LONG_SIZE == 4
#   define PCTK_INT32_MODIFIER   "l"
#   define PCTK_INT32_FORMAT     "li"
#   define PCTK_UINT32_FORMAT    "lu"
#else
#   error "Compiler provides no native 32-bit integer type"
#endif

#if PCTK_INT_SIZE == 8
#   define PCTK_INT64_MODIFIER   ""
#   define PCTK_INT64_FORMAT     "i"
#   define PCTK_UINT64_FORMAT    "u"
#   define PCTK_INT64_CONSTANT(val)	(val)
#   define PCTK_UINT64_CONSTANT(val)	(val)
#elif (PCTK_LONG_SIZE == 8) && (PCTK_LONG_LONG_SIZE != PCTK_LONG_SIZE || PCTK_INT64_IS_LONG_TYPE)
#   define PCTK_INT64_MODIFIER   "l"
#   define PCTK_INT64_FORMAT     "li"
#   define PCTK_UINT64_FORMAT    "lu"
#   define PCTK_INT64_CONSTANT(val)	(val##L)
#   define PCTK_UINT64_CONSTANT(val)	(val##UL)
#elif (PCTK_LONG_LONG_SIZE == 8) && (PCTK_LONG_LONG_SIZE != PCTK_LONG_SIZE || PCTK_INT64_IS_LONG_LONG_TYPE)
#   define PCTK_INT64_MODIFIER   "ll"
#   define PCTK_INT64_FORMAT     "lli"
#   define PCTK_UINT64_FORMAT    "llu"
#   define PCTK_INT64_CONSTANT(val)    (PCTK_EXTENSION (val##LL))
#   define PCTK_UINT64_CONSTANT(val)    (PCTK_EXTENSION (val##ULL))
#else
#   error "Compiler provides no native 64-bit integer type"
#endif

#if PCTK_SIZET_IS_SHORT_TYPE
#   define PCTK_SIZE_MODIFIER    "h"
#   define PCTK_SSIZE_MODIFIER   "h"
#   define PCTK_SIZE_FORMAT      "hu"
#   define PCTK_SSZIE_FORMAT     "hi"
#elif PCTK_SIZET_IS_INT_TYPE
#   define PCTK_SIZE_MODIFIER    ""
#   define PCTK_SSIZE_MODIFIER   ""
#   define PCTK_SIZE_FORMAT      "u"
#   define PCTK_SSZIE_FORMAT     "i"
#elif PCTK_SIZET_IS_LONG_TYPE
#   define PCTK_SIZE_MODIFIER    "l"
#   define PCTK_SSIZE_MODIFIER   "l"
#   define PCTK_SIZE_FORMAT      "lu"
#   define PCTK_SSZIE_FORMAT     "li"
#elif PCTK_SIZET_IS_LONG_LONG_TYPE
#   define PCTK_SIZE_MODIFIER    "ll"
#   define PCTK_SSIZE_MODIFIER   "ll"
#   define PCTK_SIZE_FORMAT      "llu"
#   define PCTK_SSZIE_FORMAT     "lli"
#elif PCTK_SIZET_SIZE == 8
#   define PCTK_SIZE_MODIFIER    "l"
#   define PCTK_SSIZE_MODIFIER   "l"
#   define PCTK_SIZE_FORMAT      "lu"
#   define PCTK_SSZIE_FORMAT     "li"
#elif PCTK_SIZET_SIZE == 4
#   define PCTK_SIZE_MODIFIER    ""
#   define PCTK_SSIZE_MODIFIER   ""
#   define PCTK_SIZE_FORMAT      "u"
#   define PCTK_SSZIE_FORMAT     "i"
#else
#   error "Could not determine size of size_t."
#endif

#if PCTK_VOIDP_SIZE == PCTK_INT_SIZE
#   define PCTK_INTPTR_MODIFIER  ""
#   define PCTK_INTPTR_FORMAT    "i"
#   define PCTK_UINTPTR_FORMAT   "u"
#elif PCTK_VOIDP_SIZE == PCTK_LONG_SIZE
#   define PCTK_INTPTR_MODIFIER  "l"
#   define PCTK_INTPTR_FORMAT    "li"
#   define PCTK_UINTPTR_FORMAT   "lu"
#elif PCTK_VOIDP_SIZE == PCTK_LONG_LONG_SIZE
#   define PCTK_INTPTR_MODIFIER  "ll"
#   define PCTK_INTPTR_FORMAT    "lli"
#   define PCTK_UINTPTR_FORMAT   "llu"
#else
#   error "Could not determine size of void *"
#endif

#if PCTK_VOIDP_SIZE == PCTK_INT_SIZE
typedef signed int pctk_intptr_t;
typedef unsigned int pctk_uintptr_t;
#   define PCTK_INTPTR_MODIFIER      ""
#   define PCTK_INTPTR_FORMAT        "i"
#   define PCTK_UINTPTR_FORMAT       "u"
#   define PCTK_POINTER_TO_INT(p)    ((pctk_int_t)(pctk_int_t)(p))
#   define PCTK_POINTER_TO_UINT(p)    ((pctk_uint_t)(pctk_uint_t)(p))
#   define PCTK_INT_TO_POINTER(i)    ((pctk_pointer_t)(pctk_int_t)(i))
#   define PCTK_UINT_TO_POINTER(u)    ((pctk_pointer_t)(pctk_uint_t)(u))
#elif PCTK_VOIDP_SIZE == PCTK_LONG_SIZE
typedef signed long pctk_intptr_t;
typedef unsigned long pctk_uintptr_t;
#   define PCTK_INTPTR_MODIFIER      "l"
#   define PCTK_INTPTR_FORMAT        "li"
#   define PCTK_UINTPTR_FORMAT       "lu"
#   define PCTK_POINTER_TO_INT(p)    ((pctk_int_t)(pctk_long_t)(p))
#   define PCTK_POINTER_TO_UINT(p)    ((pctk_uint_t)(pctk_ulong_t)(p))
#   define PCTK_INT_TO_POINTER(i)    ((pctk_pointer_t)(pctk_long_t)(i))
#   define PCTK_UINT_TO_POINTER(u)    ((pctk_pointer_t)(pctk_ulong_t)(u))
#elif PCTK_VOIDP_SIZE == PCTK_LONG_LONG_SIZE
typedef signed long long            pctk_intptr_t;
typedef unsigned long long          pctk_uintptr_t;
#   define PCTK_INTPTR_MODIFIER      "ll"
#   define PCTK_INTPTR_FORMAT        "lli"
#   define PCTK_UINTPTR_FORMAT       "llu"
#   define PCTK_POINTER_TO_INT(p)	((pctk_int_t)(pctk_int64_t)(p))
#   define PCTK_POINTER_TO_UINT(p)	((pctk_uint_t)(pctk_uint64_t)(p))
#   define PCTK_INT_TO_POINTER(i)	((pctk_pointer_t)(pctk_int64_t)(i))
#   define PCTK_UINT_TO_POINTER(u)	((pctk_pointer_t)(pctk_uint64_t)(u))
#else
#   error "Could not determine size of void *"
#endif

#define PCTK_POINTER_TO_SIZE(p)      ((pctk_size_t)(p))
#define PCTK_SIZE_TO_POINTER(s)      ((pctk_pointer_t)(pctk_size_t)(s))

#define PCTK_TID_TO_INT(p)           PCTK_POINTER_TO_INT(p)
#define PCTK_TID_TO_UINT(p)          PCTK_POINTER_TO_UINT(p)
#define PCTK_INT_TO_TID(i)           PCTK_INT_TO_POINTER(i)
#define PCTK_UINT_TO_TID(u)          PCTK_UINT_TO_POINTER(u)



/********************************************************************************
    PCTK Overflow-checked unsigned integer arithmetic
********************************************************************************/
#ifndef PCTK_TEST_OVERFLOW_FALLBACK
/* https://bugzilla.gnome.org/show_bug.cgi?id=769104 */
#   if __GNUC__ >= 5 && !defined(__INTEL_COMPILER)
#       define PCTK_HAS_BUILTIN_OVERFLOW_CHECKS 1
#   elif PCTK_CC_HAS_BUILTIN(__builtin_add_overflow)
#       define PCTK_HAS_BUILTIN_OVERFLOW_CHECKS 1
#   endif
#endif

#ifndef PCTK_HAS_BUILTIN_OVERFLOW_CHECKS
#   define PCTK_HAS_BUILTIN_OVERFLOW_CHECKS 0
#endif

#if PCTK_HAS_BUILTIN_OVERFLOW_CHECKS

#   define PCTK_UINT_ADD_OVERFLOW(dest, a, b)        (__builtin_add_overflow(a, b, dest))
#   define PCTK_UINT_MUL_OVERFLOW(dest, a, b)        (__builtin_mul_overflow(a, b, dest))

#   define PCTK_UINT64_ADD_OVERFLOW(dest, a, b)      (__builtin_add_overflow(a, b, dest))
#   define PCTK_UINT64_MUL_OVERFLOW(dest, a, b)      (__builtin_mul_overflow(a, b, dest))

#   define PCTK_INT64_ADD_OVERFLOW(dest, a, b)       (__builtin_add_overflow(a, b, dest))
#   define PCTK_INT64_MUL_OVERFLOW(dest, a, b)       (__builtin_mul_overflow(a, b, dest))

#   define PCTK_SIZE_ADD_OVERFLOW(dest, a, b)        (__builtin_add_overflow(a, b, dest))
#   define PCTK_SIZE_MUL_OVERFLOW(dest, a, b)        (__builtin_mul_overflow(a, b, dest))

#else  /* !PCTK_HAS_BUILTIN_OVERFLOW_CHECKS */

static pctk_boolean_t pctk__uint_add_overflow(pctk_uint_t *dest, pctk_uint_t a, pctk_uint_t b)
{
    *dest = a + b;
    return *dest < a;
}
static pctk_boolean_t pctk__uint_mul_overflow(pctk_uint_t *dest, pctk_uint_t a, pctk_uint_t b)
{
    *dest = a * b;
    return a && *dest / a != b;
}
static pctk_boolean_t pctk__uint64_add_overflow(pctk_uint64_t *dest, pctk_uint64_t a, pctk_uint64_t b)
{
    *dest = a + b;
    return *dest < a;
}
static pctk_boolean_t pctk__uint64_mul_overflow(pctk_uint64_t *dest, pctk_uint64_t a, pctk_uint64_t b)
{
    *dest = a * b;
    return a && *dest / a != b;
}
static pctk_boolean_t pctk__int64_add_overflow(pctk_int64_t *dest, pctk_int64_t a, pctk_int64_t b)
{
    *dest = a + b;
    return *dest < a;
}
static pctk_boolean_t pctk__int64_mul_overflow(pctk_int64_t *dest, pctk_int64_t a, pctk_int64_t b)
{
    *dest = a * b;
    return a && *dest / a != b;
}
static pctk_boolean_t pctk__size_add_overflow(pctk_size_t *dest, pctk_size_t a, pctk_size_t b)
{
    *dest = a + b;
    return *dest < a;
}
static pctk_boolean_t pctk__size_mul_overflow(pctk_size_t *dest, pctk_size_t a, pctk_size_t b)
{
    *dest = a * b;
    return a && *dest / a != b;
}

#   define PCTK_UINT_ADD_OVERFLOW(dest, a, b)        pctk__uint_add_overflow(dest, a, b)
#   define PCTK_UINT_MUL_OVERFLOW(dest, a, b)        pctk__uint_mul_overflow(dest, a, b)

#   define PCTK_UINT64_ADD_OVERFLOW(dest, a, b)      pctk__uint64_add_overflow(dest, a, b)
#   define PCTK_UINT64_MUL_OVERFLOW(dest, a, b)      pctk__uint64_mul_overflow(dest, a, b)

#   define PCTK_INT64_ADD_OVERFLOW(dest, a, b)       pctk__int64_add_overflow(dest, a, b)
#   define PCTK_INT64_MUL_OVERFLOW(dest, a, b)       pctk__int64_mul_overflow(dest, a, b)

#   define PCTK_SIZE_ADD_OVERFLOW(dest, a, b)        pctk__size_add_overflow(dest, a, b)
#   define PCTK_SIZE_MUL_OVERFLOW(dest, a, b)        pctk__size_mul_overflow(dest, a, b)

#endif  /* !PCTK_HAS_BUILTIN_OVERFLOW_CHECKS */


/***********************************************************************************************************************
    PCTK function type define
***********************************************************************************************************************/
typedef pctk_pointer_t (*pctk_malloc_func)(pctk_size_t size);
typedef pctk_pointer_t (*pctk_realloc_func)(pctk_pointer_t ptr, pctk_size_t size);
typedef pctk_pointer_t (*pctk_calloc_func)(pctk_size_t count, pctk_size_t size);
typedef void (*pctk_free_func)(pctk_pointer_t data);

typedef void (*pctk_void_func)(void);
typedef void (*pctk_destroy_func)(pctk_pointer_t data);
typedef void (*pctk_callback_func)(pctk_pointer_t data, pctk_pointer_t user_data);

typedef pctk_pointer_t (*pctk_copy_func)(pctk_const_pointer_t src);
typedef pctk_pointer_t (*pctk_copy_data_func)(pctk_const_pointer_t src, pctk_pointer_t user_data);

typedef pctk_boolean_t (*pctk_equal_func)(pctk_const_pointer_t data1, pctk_const_pointer_t data2);

/* Return a value greater than 0 if data1 > data2, return 0 if data1 == data2, return a value less than 0 if data1 < data2*/
typedef pctk_int_t (*pctk_compare_func)(pctk_const_pointer_t data1, pctk_const_pointer_t data2);
typedef pctk_int_t (*pctk_compare_data_func)(pctk_const_pointer_t data1,
                                             pctk_const_pointer_t data2,
                                             pctk_pointer_t user_data);

typedef pctk_uint32_t (*pctk_hash_func)(pctk_const_pointer_t key);
typedef void (*pctk_hash_pair_func)(pctk_pointer_t key, pctk_pointer_t value, pctk_pointer_t user_data);
typedef pctk_boolean_t (*pctk_hash_property_func)(pctk_pointer_t key, pctk_pointer_t value, pctk_pointer_t user_data);

#endif //_PCTKTYPES_H
