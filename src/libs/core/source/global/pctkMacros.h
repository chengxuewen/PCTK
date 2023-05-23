/***********************************************************************************************************************
**
** Library: PCTK
**
** Copyright (C) 2023 ChengXueWen. Contact: 1398831004@qq.com
**
** License: MIT License
**
** Permission is hereby granted, free of charge, to any person obtaining
** a copy of this software and associated documentation files (the "Software"),
** to deal in the Software without restriction, including without limitation
** the rights to use, copy, modify, merge, publish, distribute, sublicense,
** and/or sell copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
** SOFTWARE.
**
***********************************************************************************************************************/

#ifndef _PCTKMACROS_H_
#define _PCTKMACROS_H_

#include <pctkSystem.h>
#include <pctkCompiler.h>
#include <pctkCoreConfig.h>

#include <stdio.h>
#include <stdarg.h>


/***********************************************************************************************************************
   PCTK utils macro
***********************************************************************************************************************/
/* Avoid "unused parameter" warnings */
#define PCTK_VAR_UNUSED(x) (void)x;

/* Pragma keyword */
#if defined(_MSC_VER)
#   define PCTK_PRAGMA(X) __pragma(X)
#else
#   define PCTK_PRAGMA(X) _Pragma(#X)
#endif

/* Stringify macro or string */
#define PCTK_STRINGIFY(macro_or_string)     PCTK_STRINGIFY_ARG(macro_or_string)
#define PCTK_STRINGIFY_ARG(contents)        #contents

/* Count the number of elements in an array. The array must be defined
 * as such; using this with a dynamically allocated array will give
 * incorrect results.
 */
#define PCTK_ELEMENTS_NUM(arr)  (sizeof(arr) / sizeof((arr)[0]))

#define PCTK_ZERO_INIT  { 0 }

#define PCTK_ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))



/***********************************************************************************************************************
   PCTK struct member macro
***********************************************************************************************************************/
#if PCTK_CC_GNU >= 400 || defined(PCTK_CC_MSVC)
#   define PCTK_STRUCT_OFFSET(struct_type, member)   ((utk_long_t)offsetof(struct_type, member))
#else
#   define PCTK_STRUCT_OFFSET(struct_type, member)   ((utk_long_t)((utk_uint8_t *)&((struct_type *) 0)->member))
#endif

#define PCTK_STRUCT_MEMBER_P(struct_p, struct_offset) \
    ((utk_pointer_t)((utk_uint8_t *)(struct_p) + (utk_long_t)(struct_offset)))
#define PCTK_STRUCT_MEMBER(member_type, struct_p, struct_offset) \
    (*(member_type*)PCTK_STRUCT_MEMBER_P((struct_p), (struct_offset)))



/***********************************************************************************************************************
   PCTK conditional macro
***********************************************************************************************************************/
#define PCTK_CONDITIONAL_IF(PRED, THEN) \
    PCTK_STMT_START { \
    if (PRED) { THEN; } \
    } PCTK_STMT_END

#define PCTK_CONDITIONAL_LIKELY(PRED, THEN, ELSE) \
    PCTK_STMT_START { \
    if (PCTK_LIKELY(PRED)) { THEN; } else { ELSE; } \
    } PCTK_STMT_END

#define PCTK_CONDITIONAL_UNLIKELY(PRED, THEN, ELSE) \
    PCTK_STMT_START { \
    if (PCTK_UNLIKELY(PRED)) { THEN; } else { ELSE; } \
    } PCTK_STMT_END



/***********************************************************************************************************************
   PCTK separator macro
***********************************************************************************************************************/
#ifdef PCTK_OS_WIN32
#   define PCTK_DIR_SEPARATOR            '\\\\'
#   define PCTK_DIR_SEPARATOR_S          "\\\\"
#   define PCTK_SEARCHPATH_SEPARATOR     ';'
#   define PCTK_SEARCHPATH_SEPARATOR_S   ";"
#else
#   define PCTK_DIR_SEPARATOR            '/'
#   define PCTK_DIR_SEPARATOR_S          "/"
#   define PCTK_SEARCHPATH_SEPARATOR     ':'
#   define PCTK_SEARCHPATH_SEPARATOR_S   ":"
#endif



/***********************************************************************************************************************
   PCTK separator macro
***********************************************************************************************************************/
#ifdef PCTK_OS_WIN32
#   define PCTK_NEWLINE                  "\r\n"
#   define PCTK_NEWLINE_LEN              2
#else
#   define PCTK_NEWLINE                  "\n"
#   define PCTK_NEWLINE_LEN              1
#endif



/***********************************************************************************************************************
   PCTK arg macro
***********************************************************************************************************************/
/* va_copy is a C99 feature. In C89 implementations, it's sometimes
 * available as __va_copy. If not, memcpy() should do the trick.
 */
#ifndef va_copy
#   ifdef __va_copy
#       define PCTK_VA_COPY(a, b)    __va_copy(a, b)
#   else
#       define PCTK_VA_COPY(a, b)    memcpy(&(a), &(b), sizeof(va_list))
#   endif
#else
#   define PCTK_VA_COPY(a, b)        va_copy(a, b)
#endif

#define PCTK_VA_START(ap, x)         va_start(ap, x)
#define PCTK_VA_ARG(ap, t)           va_arg(ap, t)
#define PCTK_VA_END(ap)              va_end(ap)




/***********************************************************************************************************************
    PCTK mathematical constants define
***********************************************************************************************************************/
/* Define some mathematical constants that aren't available
 * symbolically in some strict ISO C implementations.
 */
#define PCTK_E     2.7182818284590452353602874713526624977572470937000
#define PCTK_LN2   0.69314718055994530941723212145817656807550013436026
#define PCTK_LN10  2.3025850929940456840179914546843642076011014886288
#define PCTK_PI    3.1415926535897932384626433832795028841971693993751
#define PCTK_PI_2  1.5707963267948966192313216916397514420985846996876
#define PCTK_PI_4  0.78539816339744830961566084581987572104929234984378
#define PCTK_SQRT2 1.4142135623730950488016887242096980785696718753769




/***********************************************************************************************************************
    PCTK time constants define
***********************************************************************************************************************/
#define PCTK_MINS_PER_DAY            1440
#define PCTK_MINS_PER_HOUR           60

#define PCTK_SECS_PER_DAY            86400
#define PCTK_SECS_PER_HOUR           3600
#define PCTK_SECS_PER_MIN            60

#define PCTK_MSECS_PER_DAY           86400000
#define PCTK_MSECS_PER_HOUR          3600000
#define PCTK_MSECS_PER_MIN           60000
#define PCTK_MSECS_PER_SEC           1000

#define PCTK_USECS_PER_DAY           86400000000
#define PCTK_USECS_PER_HOUR          3600000000
#define PCTK_USECS_PER_MIN           60000000
#define PCTK_USECS_PER_SEC           1000000
#define PCTK_USECS_PER_MSEC          1000

#define PCTK_NSECS_PER_DAY           86400000000000
#define PCTK_NSECS_PER_HOUR          3600000000000
#define PCTK_NSECS_PER_MIN           60000000000
#define PCTK_NSECS_PER_SEC           1000000000
#define PCTK_NSECS_PER_MSEC          1000000
#define PCTK_NSECS_PER_USEC          1000




/***********************************************************************************************************************
   PCTK math macro
***********************************************************************************************************************/
#define PCTK_MATH_ABS(a)       (((a) < 0) ? -(a) : (a))
#define PCTK_MATH_MAX(a, b)  (((a) > (b)) ? (a) : (b))
#define PCTK_MATH_MIN(a, b)  (((a) < (b)) ? (a) : (b))
#define PCTK_MATH_BOUND(min, val, max) PCTK_MATH_MAX(min, PCTK_MATH_MIN(max, val))
#define PCTK_MATH_CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#define PCTK_MATH_APPROX_VALUE(a, b, epsilon)    (((a) > (b) ? (a) - (b) : (b) - (a)) < (epsilon))



/***********************************************************************************************************************
   PCTK version macro
***********************************************************************************************************************/
/* PCTK_VERSION is (major << 16) + (minor << 8) + patch. */
#define PCTK_VERSION PCTK_VERSION_CHECK(PCTK_VERSION_MAJOR, PCTK_VERSION_MINOR, PCTK_VERSION_PATCH)
/* Can be used like #if (PCTK_VERSION >= PCTK_VERSION_CHECK(4, 4, 0)) */
#define PCTK_VERSION_CHECK(major, minor, patch) ((major << 16) | (minor << 8) | (patch))



/***********************************************************************************************************************
    PCTK gnuc version macro define
***********************************************************************************************************************/
/*
 * Note: Clang (but not clang-cl) defines __GNUC__ and __GNUC_MINOR__.
 * Both Clang 11.1 on current Arch Linux and Apple's Clang 12.0 define
 * __GNUC__ = 4 and __GNUC_MINOR__ = 2. So PCTK_GNUC_CHECK_VERSION(4, 2) on
 * current Clang will be 1.
 */
#ifdef __GNUC__
#   define PCTK_GNUC_CHECK_VERSION(major, minor) \
    ((__GNUC__ > (major)) || ((__GNUC__ == (major)) && (__GNUC_MINOR__ >= (minor))))
#else
#   define PCTK_GNUC_CHECK_VERSION(major, minor) 0
#endif



/***********************************************************************************************************************
    PCTK statement wrappers macro define
***********************************************************************************************************************/
/* Provide simple macro statement wrappers:
 *   PCTK_STMT_START { statements; } PCTK_STMT_END;
 * This can be used as a single statement, like:
 *   if (x) PCTK_STMT_START { ... } PCTK_STMT_END; else ...
 * This intentionally does not use compiler extensions like GCC's '({...})' to
 * avoid portability issue or side effects when compiled with different compilers.
 * MSVC complains about "while(0)": C4127: "Conditional expression is constant",
 * so we use __pragma to avoid the warning since the use here is intentional.
 */
#if !(defined(PCTK_STMT_START) && defined(PCTK_STMT_END))
#   define PCTK_STMT_START   do
#   if defined (_MSC_VER) && (_MSC_VER >= 1500)
#       define PCTK_STMT_END \
        __pragma(warning(push)) \
        __pragma(warning(disable:4127)) \
        while (0) \
        __pragma(warning(pop))
#   else
#       define PCTK_STMT_END   while (0)
#   endif
#endif



/***********************************************************************************************************************
   PCTK Provide a string identifying the current function, non-concatenatable macro
***********************************************************************************************************************/
#if defined (__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#   define PCTK_STRFUNC     ((const char*) (__func__))
#elif defined (__GNUC__) && defined (__cplusplus)
#   define PCTK_STRFUNC     ((const char*) (__PRETTY_FUNCTION__))
#elif defined (__GNUC__) || (defined(_MSC_VER) && (_MSC_VER > 1300))
#   define PCTK_STRFUNC     ((const char*) (__FUNCTION__))
#else
#   define PCTK_STRFUNC     ((const char*) ("???"))
#endif

/* Provide a string identifying the current code position */
#if defined(__GNUC__) && (__GNUC__ < 3) && !defined(__cplusplus)
#   define PCTK_STRLOC	__FILE__ ":" PCTK_STRINGIFY(__LINE__) ":" __PRETTY_FUNCTION__ "()"
#else
#   define PCTK_STRLOC    __FILE__ ":" PCTK_STRINGIFY(__LINE__)
#endif



/***********************************************************************************************************************
    PCTK likely unlikely macro define
***********************************************************************************************************************/
#if defined(PCTK_CC_GNU)
#   if (PCTK_CC_GNU >= 200) && defined(__OPTIMIZE__)
#       define PCTK_LIKELY(expr)    __builtin_expect(!!(expr), true)
#       define PCTK_UNLIKELY(expr)  __builtin_expect(!!(expr), false)
#   endif
#endif
#ifndef PCTK_LIKELY
#   define PCTK_LIKELY(expr) (expr)
#endif
#ifndef PCTK_UNLIKELY
#   define PCTK_UNLIKELY(expr) (expr)
#endif



/***********************************************************************************************************************
   PCTK Guard C code macro
***********************************************************************************************************************/
/* Guard C code in headers, while including them from C++ */
#ifdef  __cplusplus
#   define PCTK_BEGIN_EXTERN extern "C" {
#   define PCTK_END_EXTERN }
#else
#   define PCTK_BEGIN_EXTERN
#   define PCTK_END_EXTERN
#endif



/***********************************************************************************************************************
    PCTK has macro define
***********************************************************************************************************************/
/*
 * Clang feature detection: http://clang.llvm.org/docs/LanguageExtensions.html
 * These are not available on GCC, but since the pre-processor doesn't do
 * operator short-circuiting, we can't use it in a statement or we'll get:
 *
 * error: missing binary operator before token "("
 *
 * So we define it to 0 to satisfy the pre-processor.
 */
#ifdef __has_feature
#   define PCTK_CC_HAS_FEATURE __has_feature
#else
#   define PCTK_CC_HAS_FEATURE(x) 0
#endif

#ifdef __has_builtin
#   define PCTK_CC_HAS_BUILTIN __has_builtin
#else
#   define PCTK_CC_HAS_BUILTIN(x) 0
#endif

#ifdef __has_extension
#   define PCTK_CC_HAS_EXTENSION __has_extension
#else
#   define PCTK_CC_HAS_EXTENSION(x) 0
#endif

#ifdef __has_attribute
#   define PCTK_CC_HAS_ATTRIBUTE __has_attribute
#else
#   define PCTK_CC_HAS_ATTRIBUTE(X) 0
#endif

#ifdef __has_include
#   define PCTK_CC_HAS_INCLUDE __has_include
#else
#   define PCTK_CC_HAS_INCLUDE(X) 0
#endif


/***********************************************************************************************************************
    PCTK type of define
***********************************************************************************************************************/
#if (PCTK_GNUC_CHECK_VERSION(4, 8) || defined(__clang__))
#   define PCTK_TYPEOF(expr) __typeof__(expr)
#elif defined(__xlC__) && __xlC__ >= 0x0600
#   define PCTK_TYPEOF(expr) __typeof__(expr)
#elif (defined(__SUNPRO_CC) || defined(__SUNPRO_C)) && (__SUNPRO_CC >= 0x590)
#   define PCTK_TYPEOF(expr) __typeof__(expr)
#else
#   define PCTK_TYPEOF(expr) expr
#endif



/***********************************************************************************************************************
    PCTK type align define
***********************************************************************************************************************/
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
#   define PCTK_C_ALIGNOF(type)  _Alignof(type)
#elif defined(_MSC_VER)
#   define PCTK_C_ALIGNOF(type)  __alignof(type)
#elif defined(__GNUC__)
#   define PCTK_C_ALIGNOF(type)  __alignof__(type)
#elif defined(__xlC__) && __xlC__ >= 0x0600
#   define PCTK_C_ALIGNOF(type)  __alignof__(type)
#elif (defined(__SUNPRO_CC) || defined(__SUNPRO_C)) && __SUNPRO_CC >= 0x590
#   define PCTK_C_ALIGNOF(type)  __alignof__(type)
#else
#   define PCTK_C_ALIGNOF_UNNAMED_STRUCT
#   define PCTK_C_ALIGNOF(type)  ((sizeof(type) > 1) ? offsetof(struct { char c; PCTK_TYPEOF(type) x; }, x) : 1)
#endif



/***********************************************************************************************************************
    PCTK dll static assert macro define
***********************************************************************************************************************/
#ifndef __GI_SCANNER__ /* The static assert macro really confuses the introspection parser */
#   if defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 201112L || PCTK_CC_HAS_FEATURE(c_static_assert) || PCTK_CC_HAS_EXTENSION(c_static_assert))
#       define PCTK_C_STATIC_ASSERT(expr) _Static_assert(expr, #expr)
#       define PCTK_C_STATIC_ASSERT_X(expr, msg) _Static_assert(expr, #msg)
#   elif defined(__COUNTER__)
#       define PCTK_C_STATIC_ASSERT(expr) typedef char PCTK_PP_CONCAT(_utk_static_assert_compile_time_assertion_, __COUNTER__)[(expr) ? 1 : -1] PCTK_ATTR_UNUSED
#       define PCTK_C_STATIC_ASSERT_X(expr, msg) typedef char PCTK_PP_CONCAT(msg, __COUNTER__)[(expr) ? 1 : -1] PCTK_ATTR_UNUSED
#   else
#       define PCTK_C_STATIC_ASSERT(expr) typedef char PCTK_PP_CONCAT(_utk_static_assert_compile_time_assertion_, __LINE__)[(expr) ? 1 : -1] PCTK_ATTR_UNUSED
#       define PCTK_C_STATIC_ASSERT_X(expr, msg) typedef char PCTK_PP_CONCAT(msg, __LINE__)[(expr) ? 1 : -1] PCTK_ATTR_UNUSED
#   endif /* __STDC_VERSION__ */
#   define PCTK_C_STATIC_ASSERT_EXPR(expr) ((void) sizeof(char[(expr) ? 1 : -1]))
#endif /* !__GI_SCANNER__ */



/***********************************************************************************************************************
    PCTK dll visibility macro define
***********************************************************************************************************************/
#if defined(PCTK_CC_MINGW) || defined(PCTK_CC_MSVC)
#   define PCTK_DECL_EXPORT __declspec(dllexport)
#   define PCTK_DECL_IMPORT __declspec(dllimport)
#   define PCTK_DECL_HIDDEN
#elif defined(PCTK_CC_GNU) && (PCTK_CC_GNU > 400)
#   define PCTK_DECL_EXPORT __attribute__((visibility("default")))
#   define PCTK_DECL_IMPORT __attribute__((visibility("default")))
#   define PCTK_DECL_HIDDEN __attribute__((visibility("hidden")))
#elif defined(PCTK_CC_CLANG)
#   define PCTK_DECL_EXPORT __attribute__((visibility("default")))
#   define PCTK_DECL_IMPORT __attribute__((visibility("default")))
#   define PCTK_DECL_HIDDEN __attribute__((visibility("hidden")))
#endif

#ifndef PCTK_DECL_EXPORT
#   define PCTK_DECL_EXPORT
#endif

#ifndef PCTK_DECL_IMPORT
#   define PCTK_DECL_IMPORT
#endif

#ifndef PCTK_DECL_HIDDEN
#   define PCTK_DECL_HIDDEN
#endif



/***********************************************************************************************************************
    PCTK var exported in windows dlls macro define
***********************************************************************************************************************/
#ifdef PCTK_OS_WIN32
#   ifndef PCTK_SHARED
#       define PCTK_EXTERN_VAR extern
#   else /* !PCTK_SHARED */
#       ifdef PCTK_BUILD_CORE_LIB
#           define PCTK_EXTERN_VAR extern __declspec(dllexport)
#       else /* !PCTK_BUILD_CORE_LIB */
#           define PCTK_EXTERN_VAR extern __declspec(dllimport)
#       endif /* !PCTK_BUILD_CORE_LIB */
#   endif /* !PCTK_SHARED */
#else /* !PCTK_OS_WIN32 */
#   define PCTK_EXTERN_VAR extern
#endif /* !PCTK_OS_WIN32 */



/***********************************************************************************************************************
    PCTK force inline macro define
***********************************************************************************************************************/
/**
 * PCTK_GNUC_NO_INLINE:
 *
 * Expands to the GNU C `noinline` function attribute if the compiler is gcc.
 * If the compiler is not gcc, this macro expands to nothing.
 *
 * Declaring a function as `noinline` prevents the function from being
 * considered for inlining.
 *
 * The attribute may be placed before the declaration or definition,
 * right before the `static` keyword.
 *
 * |[<!-- language="C" -->
 * PCTK_NO_INLINE
 * static int
 * do_not_inline_this (void)
 * {
 *   ...
 * }
 * ]|
 *
 * Since: 0.3.8
 */
#if defined(PCTK_CC_MSVC)
#   define PCTK_FORCE_INLINE    __forceinline
#   define PCTK_ALWAYS_INLINE   __forceinline
#   define PCTK_NO_INLINE    __declspec(noinline)
#elif defined(PCTK_CC_GNU) && PCTK_CC_HAS_ATTRIBUTE(__noinline__)
#   define PCTK_FORCE_INLINE    inline __attribute__((always_inline))
#   define PCTK_ALWAYS_INLINE   inline __attribute__((always_inline))
#   define PCTK_NO_INLINE    __attribute__((noinline))
#elif defined(PCTK_CC_CLANG)
#   define PCTK_FORCE_INLINE    inline __attribute__((always_inline))
#   define PCTK_ALWAYS_INLINE   inline __attribute__((always_inline))
#   define PCTK_NO_INLINE
#else
#   define PCTK_FORCE_INLINE    inline // no force inline for other platforms possible
#   define PCTK_ALWAYS_INLINE   inline
#   define PCTK_NO_INLINE
#endif



/***********************************************************************************************************************
    PCTK extension macro define
***********************************************************************************************************************/
#if PCTK_GNUC_CHECK_VERSION(2, 8)
/* Here we provide PCTK_EXTENSION as an alias for __extension__,
 * where this is valid. This allows for warningless compilation of
 * "long long" types even in the presence of '-ansi -pedantic'.
 */
#   define PCTK_EXTENSION __extension__
#else
#   define PCTK_EXTENSION
#endif



/***********************************************************************************************************************
    PCTK aligned macro define
***********************************************************************************************************************/
#if defined(PCTK_CC_GNU)
#   define PCTK_ATTR_ALIGNED(size) __attribute__((aligned(size)))
#else
#   define PCTK_ATTR_ALIGNED(size)
#endif



/***********************************************************************************************************************
    PCTK likely unlikely macro define
***********************************************************************************************************************/
/**
 * PCTK_ATTR_PURE:
 *
 * Expands to the GNU C `pure` function attribute if the compiler is gcc.
 * Declaring a function as `pure` enables better optimization of calls to
 * the function. A `pure` function has no effects except its return value
 * and the return value depends only on the parameters and/or global
 * variables.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * utk_boolean_t utk_type_check_value (const Value *value) PCTK_ATTR_PURE;
 * ]|
 *
 */
#if PCTK_CC_HAS_ATTRIBUTE(__pure__)
#   define PCTK_ATTR_PURE __attribute__((__pure__))
#else
#   define PCTK_ATTR_PURE
#endif



/**
 * PCTK_ATTR_MALLOC:
 *
 * Expands to the
 * [GNU C `malloc` function attribute](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-functions-that-behave-like-malloc)
 * if the compiler is gcc.
 * Declaring a function as `malloc` enables better optimization of the function,
 * but must only be done if the allocation behaviour of the function is fully
 * understood, otherwise miscompilation can result.
 *
 * A function can have the `malloc` attribute if it returns a pointer which is
 * guaranteed to not alias with any other pointer valid when the function
 * returns, and moreover no pointers to valid objects occur in any storage
 * addressed by the returned pointer.
 *
 * In practice, this means that `PCTK_ATTR_MALLOC` can be used with any function
 * which returns unallocated or zeroed-out memory, but not with functions which
 * return initialised structures containing other pointers, or with functions
 * that reallocate memory. This definition  match the stricter definition
 * introduced around GCC 5.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * utk_pointer_t utk_allocater_malloc(utk_size_t n_bytes) PCTK_ATTR_MALLOC PCTK_ATTR_ALLOC_SIZE(1);
 * ]|
 *
 * See the
 * [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-functions-that-behave-like-malloc)
 * for more details.
 *
 * Since: 0.3.8
 */

#if PCTK_CC_HAS_ATTRIBUTE(__malloc__)
#   define PCTK_ATTR_MALLOC __attribute__ ((__malloc__))
#else
#   define PCTK_ATTR_MALLOC
#endif




/**
 * PCTK_ATTR_NULL_TERMINATED:
 *
 * Expands to the GNU C `sentinel` function attribute if the compiler is gcc.
 * This function attribute only applies to variadic functions and instructs
 * the compiler to check that the argument list is terminated with an
 * explicit %NULL.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * utk_char_t *utk_strconcat (const utk_char_t *string1, ...) PCTK_ATTR_NULL_TERMINATED;
 * ]|
 *
 * See the [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-sentinel-function-attribute) for more details.
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(__sentinel__)
#   define PCTK_ATTR_NULL_TERMINATED __attribute__((__sentinel__))
#else
#   define PCTK_ATTR_NULL_TERMINATED
#endif



/**
 * PCTK_ATTR_ALLOC_SIZE:
 * @a x: the index of the argument specifying the allocation size
 *
 * Expands to the GNU C `alloc_size` function attribute if the compiler
 * is a new enough gcc. This attribute tells the compiler that the
 * function returns a pointer to memory of a size that is specified
 * by the @a xth function parameter.
 *
 * Place the attribute after the function declaration, just before the
 * semicolon.
 *
 * |[<!-- language="C" -->
 * utk_pointer_t utk_malloc (utk_size_t n_bytes) PCTK_ATTR_MALLOC PCTK_ATTR_ALLOC_SIZE(1);
 * ]|
 *
 * See the [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-alloc_005fsize-function-attribute) for more details.
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(__alloc_size__)
#   define PCTK_ATTR_ALLOC_SIZE(x) __attribute__((__alloc_size__(x)))
#else
#   define PCTK_ATTR_ALLOC_SIZE(x)
#endif



/**
 * PCTK_ATTR_ALLOC_SIZE2:
 * @param x: the index of the argument specifying one factor of the allocation size
 * @param y: the index of the argument specifying the second factor of the allocation size
 *
 * Expands to the GNU C `alloc_size` function attribute if the compiler is a
 * new enough gcc. This attribute tells the compiler that the function returns
 * a pointer to memory of a size that is specified by the product of two
 * function parameters.
 *
 * Place the attribute after the function declaration, just before the
 * semicolon.
 *
 * |[<!-- language="C" -->
 * utk_pointer_t utk_malloc_n (utk_size_t n_blocks, utk_size_t n_block_bytes) PCTK_ATTR_MALLOC PCTK_ATTR_ALLOC_SIZE2(1, 2);
 * ]|
 *
 * See the [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-alloc_005fsize-function-attribute) for more details.
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(__alloc_size__)
#   define PCTK_ATTR_ALLOC_SIZE2(x,y) __attribute__((__alloc_size__(x,y)))
#else
#   define PCTK_ATTR_ALLOC_SIZE2(x, y)
#endif



/**
 * PCTK_ATTR_PRINTF:
 * @param format_idx: the index of the argument corresponding to the
 *     format string (the arguments are numbered from 1)
 * @param arg_idx: the index of the first of the format arguments, or 0 if
 *     there are no format arguments
 *
 * Expands to the GNU C `format` function attribute if the compiler is gcc.
 * This is used for declaring functions which take a variable number of
 * arguments, with the same syntax as `printf()`. It allows the compiler
 * to type-check the arguments passed to the function.
 *
 * Place the attribute after the function declaration, just before the
 * semicolon.
 *
 * See the
 * [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-Wformat-3288)
 * for more details.
 *
 * |[<!-- language="C" -->
 * utk_int_t utk_snprintf (utk_char_t  *string,
 *                          utk_ulong_t       n,
 *                          utk_char_t const *format,
 *                          ...) PCTK_ATTR_PRINTF(3, 4);
 * ]|
 */
#if PCTK_CC_HAS_ATTRIBUTE(__format__)
#   if !defined(__clang__) && PCTK_GNUC_CHECK_VERSION(4, 4)
#       define PCTK_ATTR_PRINTF( format_idx, arg_idx )   __attribute__((__format__ (gnu_printf, format_idx, arg_idx)))
#   else
#       define PCTK_ATTR_PRINTF( format_idx, arg_idx )  __attribute__((__format__ (__printf__, format_idx, arg_idx)))
#   endif
#else
#   define PCTK_ATTR_PRINTF(format_idx, arg_idx)
#endif


/**
 * PCTK_ATTR_SCANF:
 * @param format_idx: the index of the argument corresponding to
 *     the format string (the arguments are numbered from 1)
 * @param arg_idx: the index of the first of the format arguments, or 0 if
 *     there are no format arguments
 *
 * Expands to the GNU C `format` function attribute if the compiler is gcc.
 * This is used for declaring functions which take a variable number of
 * arguments, with the same syntax as `scanf()`. It allows the compiler
 * to type-check the arguments passed to the function.
 *
 * |[<!-- language="C" -->
 * int my_scanf (MyStream *stream,
 *               const char *format,
 *               ...) PCTK_ATTR_SCANF (2, 3);
 * int my_vscanf (MyStream *stream,
 *                const char *format,
 *                va_list ap) PCTK_ATTR_SCANF (2, 0);
 * ]|
 *
 * See the
 * [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-Wformat-3288)
 * for details.
 */
#if PCTK_CC_HAS_ATTRIBUTE(__format__)
#   if !defined(__clang__) && PCTK_GNUC_CHECK_VERSION(4, 4)
#       define PCTK_ATTR_SCANF( format_idx, arg_idx )    __attribute__((__format__(gnu_scanf, format_idx, arg_idx)))
#   else
#       define PCTK_ATTR_SCANF( format_idx, arg_idx )   __attribute__((__format__(__scanf__, format_idx, arg_idx)))
#   endif
#else
#   define PCTK_ATTR_SCANF(format_idx, arg_idx)
#endif


/**
 * PCTK_ATTR_STRFTIME:
 * @param format_idx: the index of the argument corresponding to
 *     the format string (the arguments are numbered from 1)
 *
 * Expands to the GNU C `strftime` format function attribute if the compiler
 * is gcc. This is used for declaring functions which take a format argument
 * which is passed to `strftime()` or an API implementing its formats. It allows
 * the compiler check the format passed to the function.
 *
 * |[<!-- language="C" -->
 * utk_size_t my_strftime (MyBuffer *buffer,
 *                    const char *format,
 *                    const struct tm *tm) PCTK_ATTR_STRFTIME (2);
 * ]|
 *
 * See the
 * [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-Wformat-3288)
 * for details.
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(__format__)
#   if !defined(__clang__) && PCTK_GNUC_CHECK_VERSION(4, 4)
#       define PCTK_ATTR_STRFTIME( format_idx )          __attribute__((__format__ (gnu_strftime, format_idx, 0)))
#   else
#       define PCTK_ATTR_STRFTIME( format_idx )         __attribute__((__format__ (__strftime__, format_idx, 0)))
#   endif
#else
#   define PCTK_ATTR_STRFTIME(format_idx)
#endif



/**
 * PCTK_ATTR_FORMAT:
 * @param arg_idx: the index of the argument
 *
 * Expands to the GNU C `format_arg` function attribute if the compiler
 * is gcc. This function attribute specifies that a function takes a
 * format string for a `printf()`, `scanf()`, `strftime()` or `strfmon()` style
 * function and modifies it, so that the result can be passed to a `printf()`,
 * `scanf()`, `strftime()` or `strfmon()` style function (with the remaining
 * arguments to the format function the same as they would have been
 * for the unmodified string).
 *
 * Place the attribute after the function declaration, just before the
 * semicolon.
 *
 * |[<!-- language="C" -->
 * utk_char_t *utk_dgettext (utk_char_t *domain_name, utk_char_t *msgid) PCTK_ATTR_FORMAT (2);
 * ]|
 */
#if PCTK_CC_HAS_ATTRIBUTE(__format_arg__)
#   define PCTK_ATTR_FORMAT(arg_idx)   __attribute__ ((__format_arg__ (arg_idx)))
#else
#   define PCTK_ATTR_FORMAT(arg_idx)
#endif


/**
 * PCTK_ATTR_NORETURN:
 *
 * Expands to the GNU C or MSVC `noreturn` function attribute depending on
 * the compiler. It is used for declaring functions which never return.
 * Enables optimization of the function, and avoids possible compiler warnings.
 *
 * Note that %PCTK_ATTR_NORETURN supersedes the previous %PCTK_ATTR_NORETURN macro, which
 * will eventually be deprecated. %G_NORETURN supports more platforms.
 *
 * Place the attribute before the function declaration as follows:
 *
 * |[<!-- language="C" -->
 * PCTK_ATTR_NORETURN void utk_abort (void);
 * ]|
 *
 * Expands to the GNU C or MSVC `noreturn` function attribute depending on
 * the compiler. It is used for declaring function pointers which never return.
 * Enables optimization of the function, and avoids possible compiler warnings.
 *
 * Place the attribute before the function declaration as follows:
 *
 * |[<!-- language="C" -->
 * PCTK_ATTR_NORETURN_FUNCPTR void (*funcptr) (void);
 * ]|
 *
 * Note that if the function is not a function pointer, you can simply use
 * the %PCTK_ATTR_NORETURN macro as follows:
 *
 * |[<!-- language="C" -->
 * PCTK_ATTR_NORETURN void utk_abort (void);
 * ]|
 *
 * Since: 0.3.8
 */
/* Note: We can’t annotate this with GLIB_AVAILABLE_MACRO_IN_2_68 because it’s
 * used within the GLib headers in function declarations which are always
 * evaluated when a header is included. This results in warnings in third party
 * code which includes glib.h, even if the third party code doesn’t use the new
 * macro itself. */
#if PCTK_CC_HAS_ATTRIBUTE(__noreturn__)
/* For compatibility with G_NORETURN_FUNCPTR on clang, use __attribute__((__noreturn__)), not _Noreturn.  */
#   define PCTK_ATTR_NORETURN __attribute__ ((__noreturn__))
#   define PCTK_ATTR_NORETURN_FUNCPTR __attribute__ ((__noreturn__))
#elif defined (_MSC_VER) && (1200 <= _MSC_VER)
/* Use MSVC specific syntax.  */
#   define PCTK_ATTR_NORETURN __declspec (noreturn)
#   define PCTK_ATTR_NORETURN_FUNCPTR __declspec (noreturn)
/* Use ISO C++11 syntax when the compiler supports it.  */
#elif defined (__cplusplus) && __cplusplus >= 201103
#   define PCTK_ATTR_NORETURN [[noreturn]]
#   define PCTK_ATTR_NORETURN_FUNCPTR [[noreturn]]
/* Use ISO C11 syntax when the compiler supports it.  */
#elif defined (__STDC_VERSION__) && __STDC_VERSION__ >= 201112
#   define PCTK_ATTR_NORETURN _Noreturn
#   define PCTK_ATTR_NORETURN_FUNCPTR /* empty */
#else
#   define PCTK_ATTR_NORETURN /* empty */
#   define PCTK_ATTR_NORETURN_FUNCPTR /* empty */
#endif


/**
 * PCTK_ATTR_CONST:
 *
 * Expands to the GNU C `const` function attribute if the compiler is gcc.
 * Declaring a function as `const` enables better optimization of calls to
 * the function. A `const` function doesn't examine any values except its
 * parameters, and has no effects except its return value.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * utk_char_t utk_ascii_tolower (utk_char_t c) PCTK_ATTR_CONST;
 * ]|
 *
 * See the [GNU C documentation](https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-const-function-attribute) for more details.
 *
 * A function that has pointer arguments and examines the data pointed to
 * must not be declared `const`. Likewise, a function that calls a non-`const`
 * function usually must not be `const`. It doesn't make sense for a `const`
 * function to return `void`.
 */
#if PCTK_CC_HAS_ATTRIBUTE(__const__)
#   define PCTK_ATTR_CONST    __attribute__ ((__const__))
#else
#   define PCTK_ATTR_CONST
#endif


/**
 * PCTK_ATTR_UNUSED:
 *
 * Expands to the GNU C `unused` function attribute if the compiler is gcc.
 * It is used for declaring functions and arguments which may never be used.
 * It avoids possible compiler warnings.
 *
 * For functions, place the attribute after the declaration, just before the
 * semicolon. For arguments, place the attribute at the beginning of the
 * argument declaration.
 *
 * |[<!-- language="C" -->
 * void my_unused_function (PCTK_ATTR_UNUSED utk_int_t unused_argument,
 *                          utk_int_t other_argument) PCTK_ATTR_UNUSED;
 * ]|
 *
 */
#if PCTK_CC_HAS_ATTRIBUTE(__unused__)
#   define PCTK_ATTR_UNUSED     __attribute__((__unused__))
#else
#   define PCTK_ATTR_UNUSED
#endif


/**
 * PCTK_ATTR_NO_INSTRUMENT:
 *
 * Expands to the GNU C `no_instrument_function` function attribute if the
 * compiler is gcc. Functions with this attribute will not be instrumented
 * for profiling, when the compiler is called with the
 * `-finstrument-functions` option.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * int do_uninteresting_things (void) PCTK_ATTR_NO_INSTRUMENT;
 * ]|
 *
 */
#if PCTK_CC_HAS_ATTRIBUTE(__no_instrument_function__)
#   define PCTK_ATTR_NO_INSTRUMENT    __attribute__ ((__no_instrument_function__))
#else
#   define PCTK_ATTR_NO_INSTRUMENT
#endif


/**
 * PCTK_ATTR_FALLTHROUGH:
 *
 * Expands to the GNU C `fallthrough` statement attribute if the compiler supports it.
 * This allows declaring case statement to explicitly fall through in switch
 * statements. To enable this feature, use `-Wimplicit-fallthrough` during
 * compilation.
 *
 * Put the attribute right before the case statement you want to fall through
 * to.
 *
 * |[<!-- language="C" -->
 * switch (foo)
 *   {
 *     case 1:
 *       utk_message ("it's 1");
 *       PCTK_ATTR_FALLTHROUGH;
 *     case 2:
 *       utk_message ("it's either 1 or 2");
 *       break;
 *   }
 * ]|
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(fallthrough)
#   define PCTK_ATTR_FALLTHROUGH __attribute__((fallthrough))
#else
#   define PCTK_ATTR_FALLTHROUGH
#endif



/***********************************************************************************************************************
    PCTK deprecated macro define
***********************************************************************************************************************/
/**
 * PCTK_ATTR_DEPRECATED:
 *
 * Expands to the GNU C `deprecated` attribute if the compiler is gcc.
 * It can be used to mark `typedef`s, variables and functions as deprecated.
 * When called with the `-Wdeprecated-declarations` option,
 * gcc will generate warnings when deprecated interfaces are used.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * int my_mistake (void) PCTK_ATTR_DEPRECATED;
 * ]|
 *
 * Since: 0.3.8
 */
#if PCTK_GNUC_CHECK_VERSION(3, 1) || defined(__clang__) || PCTK_CC_HAS_ATTRIBUTE(__deprecated__)
#   define PCTK_ATTR_DEPRECATED __attribute__((__deprecated__))
#   define PCTK_ATTR_DEPRECATED_X(text) __attribute__((__deprecated__(text)))
#elif defined(_MSC_VER) && (_MSC_VER >= 1300)
#   define PCTK_ATTR_DEPRECATED __declspec(deprecated)
#   define PCTK_ATTR_DEPRECATED_X(text) __declspec(deprecated(text))
#elif defined(PCTK_CC_INTEL) && __INTEL_COMPILER >= 1300 && !defined(__APPLE__)
#   define PCTK_ATTR_DEPRECATED __attribute__(__deprecated__)
#   define PCTK_ATTR_DEPRECATED_X(text) __attribute__((__deprecated__(text)))
#else
#   define PCTK_ATTR_DEPRECATED
#   define PCTK_ATTR_DEPRECATED_X(text)
#endif



/***********************************************************************************************************************
    PCTK may_alias macro define
***********************************************************************************************************************/
/**
 * PCTK_ATTR_MAY_ALIAS:
 *
 * Expands to the GNU C `may_alias` type attribute if the compiler is gcc.
 * Types with this attribute will not be subjected to type-based alias
 * analysis, but are assumed to alias with any other type, just like `char`.
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(may_alias)
#   define PCTK_ATTR_MAY_ALIAS __attribute__((may_alias))
#else
#   define PCTK_ATTR_MAY_ALIAS
#endif



/***********************************************************************************************************************
    PCTK may_alias macro define
***********************************************************************************************************************/
/**
 * PCTK_ATTR_WARN_UNUSED_RESULT:
 *
 * Expands to the GNU C `warn_unused_result` function attribute if the compiler
 * is gcc. This function attribute makes the compiler emit a warning if the
 * result of a function call is ignored.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * utk_list_t *utk_list_append (utk_list_t *list, utk_pointer_t data) PCTK_ATTR_WARN_UNUSED_RESULT;
 * ]|
 *
 * Since: 0.3.8
 */
#if PCTK_CC_HAS_ATTRIBUTE(warn_unused_result)
#   define PCTK_ATTR_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
#   define PCTK_ATTR_WARN_UNUSED_RESULT
#endif



/***********************************************************************************************************************
    PCTK Warning/diagnostic handling macro define
***********************************************************************************************************************/
#if defined(PCTK_CC_INTEL) && defined(PCTK_CC_MSVC)
/* icl.exe: Intel compiler on Windows */
#   undef PCTK_PRAGMA /* not needed */
#   define PCTK_WARNING_PUSH PCTK_PRAGMA(warning(push))
#   define PCTK_WARNING_POP PCTK_PRAGMA(warning(pop))
#   define PCTK_WARNING_DISABLE_MSVC(number)
#   define PCTK_WARNING_DISABLE_INTEL(number) PCTK_PRAGMA(warning(disable: number))
#   define PCTK_WARNING_DISABLE_CLANG(text)
#   define PCTK_WARNING_DISABLE_GCC(text)
#   define PCTK_WARNING_DISABLE_DEPRECATED PCTK_WARNING_DISABLE_INTEL(1478 1786)
#   define PCTK_WARNING_DISABLE_FLOAT_COMPARE PCTK_WARNING_DISABLE_INTEL(1572)
#   define PCTK_WARNING_DISABLE_INVALID_OFFSETOF
#elif defined(PCTK_CC_INTEL)
/* icc: Intel compiler on Linux or OS X */
#   define PCTK_WARNING_PUSH PCTK_PRAGMA(warning(push))
#   define PCTK_WARNING_POP PCTK_PRAGMA(warning(pop))
#   define PCTK_WARNING_DISABLE_INTEL(number) PCTK_PRAGMA(warning(disable : number))
#   define PCTK_WARNING_DISABLE_MSVC(number)
#   define PCTK_WARNING_DISABLE_CLANG(text)
#   define PCTK_WARNING_DISABLE_GCC(text)
#   define PCTK_WARNING_DISABLE_DEPRECATED PCTK_WARNING_DISABLE_INTEL(1478 1786)
#   define PCTK_WARNING_DISABLE_FLOAT_COMPARE PCTK_WARNING_DISABLE_INTEL(1572)
#   define PCTK_WARNING_DISABLE_INVALID_OFFSETOF
#elif defined(PCTK_CC_MSVC)
#   define PCTK_WARNING_PUSH PCTK_PRAGMA(warning(push))
#   define PCTK_WARNING_POP PCTK_PRAGMA(warning(pop))
#   define PCTK_WARNING_DISABLE_MSVC(number) PCTK_PRAGMA(warning(disable : number))
#   define PCTK_WARNING_DISABLE_INTEL(number)
#   define PCTK_WARNING_DISABLE_CLANG(text)
#   define PCTK_WARNING_DISABLE_GCC(text)
#   define PCTK_WARNING_DISABLE_DEPRECATED PCTK_WARNING_DISABLE_MSVC(4996)
#   define PCTK_WARNING_DISABLE_FLOAT_COMPARE
#   define PCTK_WARNING_DISABLE_INVALID_OFFSETOF
#elif defined(PCTK_CC_CLANG)
#   define PCTK_WARNING_PUSH PCTK_PRAGMA(clang diagnostic push)
#   define PCTK_WARNING_POP PCTK_PRAGMA(clang diagnostic pop)
#   define PCTK_WARNING_DISABLE_CLANG(text) PCTK_PRAGMA(clang diagnostic ignored text)
#   define PCTK_WARNING_DISABLE_GCC(text)
#   define PCTK_WARNING_DISABLE_INTEL(number)
#   define PCTK_WARNING_DISABLE_MSVC(number)
#   define PCTK_WARNING_DISABLE_DEPRECATED PCTK_WARNING_DISABLE_CLANG("-Wdeprecated-declarations")
#   define PCTK_WARNING_DISABLE_FLOAT_COMPARE PCTK_WARNING_DISABLE_CLANG("-Wfloat-equal")
#   define PCTK_WARNING_DISABLE_INVALID_OFFSETOF PCTK_WARNING_DISABLE_CLANG("-Winvalid-offsetof")
#elif defined(PCTK_CC_GNU) && (__GNUC__ * 100 + __GNUC_MINOR__ >= 406)
#   define PCTK_WARNING_PUSH PCTK_PRAGMA(GCC diagnostic push)
#   define PCTK_WARNING_POP PCTK_PRAGMA(GCC diagnostic pop)
#   define PCTK_WARNING_DISABLE_GCC(text) PCTK_PRAGMA(GCC diagnostic ignored text)
#   define PCTK_WARNING_DISABLE_CLANG(text)
#   define PCTK_WARNING_DISABLE_INTEL(number)
#   define PCTK_WARNING_DISABLE_MSVC(number)
#   define PCTK_WARNING_DISABLE_DEPRECATED PCTK_WARNING_DISABLE_GCC("-Wdeprecated-declarations")
#   define PCTK_WARNING_DISABLE_FLOAT_COMPARE PCTK_WARNING_DISABLE_GCC("-Wfloat-equal")
#   define PCTK_WARNING_DISABLE_INVALID_OFFSETOF PCTK_WARNING_DISABLE_GCC("-Winvalid-offsetof")
#else // All other compilers, GCC < 4.6 and MSVC < 2008
#   define PCTK_WARNING_DISABLE_GCC(text)
#   define PCTK_WARNING_PUSH
#   define PCTK_WARNING_POP
#   define PCTK_WARNING_DISABLE_INTEL(number)
#   define PCTK_WARNING_DISABLE_MSVC(number)
#   define PCTK_WARNING_DISABLE_CLANG(text)
#   define PCTK_WARNING_DISABLE_GCC(text)
#   define PCTK_WARNING_DISABLE_DEPRECATED
#   define PCTK_WARNING_DISABLE_FLOAT_COMPARE
#endif

#ifndef PCTK_IGNORE_DEPRECATIONS
#   define PCTK_IGNORE_DEPRECATIONS(statement) \
    PCTK_WARNING_PUSH \
    PCTK_WARNING_DISABLE_DEPRECATED \
    statement \
    PCTK_WARNING_POP
#endif



/**
 * PCTK_ATTR_DEPRECATED_FOR:
 * @param f: the intended replacement for the deprecated symbol,
 *     such as the name of a function
 *
 * Like %PCTK_ATTR_DEPRECATED, but names the intended replacement for the
 * deprecated symbol if the version of gcc in use is new enough to support
 * custom deprecation messages.
 *
 * Place the attribute after the declaration, just before the semicolon.
 *
 * |[<!-- language="C" -->
 * int my_mistake (void) PCTK_ATTR_DEPRECATED_FOR(my_replacement);
 * ]|
 *
 * Note that if @a f is a macro, it will be expanded in the warning message.
 * You can enclose it in quotes to prevent this. (The quotes will show up
 * in the warning, but it's better than showing the macro expansion.)
 *
 * Since: 0.3.8
 */
#if PCTK_GNUC_CHECK_VERSION(4, 5) || defined(__clang__)
#   define PCTK_ATTR_DEPRECATED_FOR(f)        __attribute__((deprecated("Use " #f " instead")))
#else
#   define PCTK_ATTR_DEPRECATED_FOR(f)       PCTK_ATTR_DEPRECATED
#endif

#ifdef __ICC
#   define PCTK_BEGIN_IGNORE_DEPRECATIONS \
    _Pragma ("warning (push)") \
    _Pragma ("warning (disable:1478)")
#   define PCTK_END_IGNORE_DEPRECATIONS	\
    _Pragma ("warning (pop)")
#elif PCTK_GNUC_CHECK_VERSION(4, 6)
#   define PCTK_BEGIN_IGNORE_DEPRECATIONS \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wdeprecated-declarations\"")
#   define PCTK_END_IGNORE_DEPRECATIONS \
    _Pragma ("GCC diagnostic pop")
#elif defined (_MSC_VER) && (_MSC_VER >= 1500) && !defined (__clang__)
#   define PCTK_BEGIN_IGNORE_DEPRECATIONS \
    __pragma (warning (push)) \
    __pragma (warning (disable : 4996))
#   define PCTK_END_IGNORE_DEPRECATIONS \
    __pragma (warning (pop))
#elif defined (__clang__)
#   define PCTK_BEGIN_IGNORE_DEPRECATIONS \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
#   define PCTK_END_IGNORE_DEPRECATIONS \
    _Pragma("clang diagnostic pop")
#else
#   define PCTK_BEGIN_IGNORE_DEPRECATIONS
#   define PCTK_END_IGNORE_DEPRECATIONS
#   define PCTK_CANNOT_IGNORE_DEPRECATIONS
#endif


/***********************************************************************************************************************
    PCTK analyzer noreturn macro define
***********************************************************************************************************************/
#if PCTK_CC_HAS_FEATURE(attribute_analyzer_noreturn) && defined(__clang_analyzer__)
#   define PCTK_ANALYZER_ANALYZING 1
#   define PCTK_ANALYZER_NORETURN __attribute__((analyzer_noreturn))
#elif defined(__COVERITY__)
#   define PCTK_ANALYZER_ANALYZING 1
#   define PCTK_ANALYZER_NORETURN __attribute__((noreturn))
#else
#   define PCTK_ANALYZER_ANALYZING 0
#   define PCTK_ANALYZER_NORETURN
#endif


/***********************************************************************************************************************
   PCTK CONSTRUCTORS DESTRUCTOR macro
***********************************************************************************************************************/
#if __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7)
#   define PCTK_HAS_CTOR_DTOR 1
#   define PCTK_DECL_CONSTRUCTOR(_func) static void __attribute__((constructor)) _func (void);
#   define PCTK_DECL_DESTRUCTOR(_func) static void __attribute__((destructor)) _func (void);
#elif defined (_MSC_VER) && (_MSC_VER >= 1500)

#   include <stdlib.h>
/* Visual studio 2008 and later has _Pragma */
#   define PCTK_HAS_CTOR_DTOR 1

/* We do some weird things to avoid the constructors being optimized
 * away on VS2015 if WholeProgramOptimization is enabled. First we
 * make a reference to the array from the wrapper to make sure its
 * references. Then we use a pragma to make sure the wrapper function
 * symbol is always included at the link stage. Also, the symbols
 * need to be extern (but not dllexport), even though they are not
 * really used from another object file.
 */

/* We need to account for differences between the mangling of symbols
 * for x86 and x64/ARM/ARM64 programs, as symbols on x86 are prefixed
 * with an underscore but symbols on x64/ARM/ARM64 are not.
 */
#   ifdef _M_IX86
#       define PCTK__MSVC_SYMBOL_PREFIX "_"
#   else
#       define PCTK__MSVC_SYMBOL_PREFIX ""
#   endif

#   define PCTK__MSVC_CTOR(_func,_sym_prefix) \
    static void _func(void); \
    extern int (* _array ## _func)(void); \
    int _func ## _wrapper(void) { _func(); return 0; } \
    PCTK_PRAGMA(comment(linker,"/include:" _sym_prefix # _func "_wrapper")) \
    PCTK_PRAGMA(section(".CRT$XCU",read)) \
    __declspec(allocate(".CRT$XCU")) int (* _array ## _func)(void) = _func ## _wrapper;

#   define PCTK__MSVC_DTOR(_func,_sym_prefix) \
    static void _func(void); \
    extern int (* _array ## _func)(void); \
    int _func ## _constructor(void) { atexit (_func); return 0; } \
    PCTK_PRAGMA(comment(linker,"/include:" _sym_prefix # _func "_constructor")) \
    PCTK_PRAGMA(section(".CRT$XCU",read)) \
    __declspec(allocate(".CRT$XCU")) int (* _array ## _func)(void) = _func ## _constructor;

#   define PCTK_DECL_CONSTRUCTOR(_func) PCTK__MSVC_CTOR(_func, PCTK__MSVC_SYMBOL_PREFIX)
#   define PCTK_DECL_DESTRUCTOR(_func) PCTK__MSVC_DTOR(_func, PCTK__MSVC_SYMBOL_PREFIX)

#elif defined (_MSC_VER)

#   define PCTK_HAS_CTOR_DTOR 1

/* Pre Visual studio 2008 must use #pragma section */
#   define PCTK__DECL_CONSTRUCTOR_PRAGMA_ARGS(_func) section(".CRT$XCU", read)
#   define PCTK_DECL_CONSTRUCTOR(_func) \
    PCTK_PRAGMA(PCTK__DECL_CONSTRUCTOR_PRAGMA_ARGS(_func)) \
    static void _func(void); \
    static int _func ## _wrapper(void) { _func(); return 0; } \
    __declspec(allocate(".CRT$XCU")) static int (*p)(void) = _func ## _wrapper;

#   define PCTK_DECL_DESTRUCTOR_PRAGMA_ARGS(_func) section(".CRT$XCU",read)
#   define PCTK_DECL_DESTRUCTOR(_func) \
    PCTK_PRAGMA(PCTK_DECL_DESTRUCTOR_PRAGMA_ARGS(_func)) \
    static void _func(void); \
    static int _func ## _constructor(void) { atexit (_func); return 0; } \
    __declspec(allocate(".CRT$XCU")) static int (* _array ## _func)(void) = _func ## _constructor;

#elif defined(__SUNPRO_C)

/* This is not tested, but i believe it should work, based on:
 * http://opensource.apple.com/source/OpenSSL098/OpenSSL098-35/src/fips/fips_premain.c
 */
#   define PCTK_HAS_CTOR_DTOR 1
#   define PCTK_DEFINE_CTOR_DTOR_NEEDS_PRAGMA

#   define PCTK__DECL_CONSTRUCTOR_PRAGMA_ARGS(_func) init(_func)
#   define PCTK_DECL_CONSTRUCTOR(_func) \
    PCTK_PRAGMA(PCTK__DECL_CONSTRUCTOR_PRAGMA_ARGS(_func)) \
    static void _func(void);

#   define PCTK_DECL_DESTRUCTOR_PRAGMA_ARGS(_func) fini(_func)
#   define PCTK_DECL_DESTRUCTOR(_func) \
    PCTK_PRAGMA(PCTK_DECL_DESTRUCTOR_PRAGMA_ARGS(_func)) \
    static void _func(void);

#else

/* constructors not supported for this compiler */
#   define PCTK_HAS_CTOR_DTOR 0

#endif

#endif //_PCTKMACROS_H_
