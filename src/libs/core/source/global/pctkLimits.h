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

#ifndef _PCTKLIMITS_H_
#define _PCTKLIMITS_H_

#include <pctkTypes.h>

#include <limits.h>
#include <float.h>

#define PCTK_CHAR_MIN        CHAR_MIN
#define PCTK_UCHAR_MAX       UCHAR_MAX
#define PCTK_SCHAR_MIN       SCHAR_MIN

#define PCTK_SHORT_MIN       SHRT_MIN
#define PCTK_SHORT_MAX       SHRT_MAX
#define PCTK_USHORT_MAX      USHRT_MAX

#define PCTK_INT_MIN         INT_MIN
#define PCTK_INT_MAX         INT_MAX
#define PCTK_UINT_MAX        UINT_MAX

#define PCTK_INT8_MIN        INT8_MIN
#define PCTK_INT8_MAX        INT8_MAX
#define PCTK_UINT8_MAX       UINT8_MAX

#define PCTK_INT16_MIN       INT16_MIN
#define PCTK_INT16_MAX       INT16_MAX
#define PCTK_UINT16_MAX      UINT16_MAX

#define PCTK_INT32_MIN       INT32_MIN
#define PCTK_INT32_MAX       INT32_MAX
#define PCTK_UINT32_MAX      UINT32_MAX

#define PCTK_INT64_MIN       INT64_MIN
#define PCTK_INT64_MAX       INT64_MAX
#define PCTK_UINT64_MAX      UINT64_MAX

#define PCTK_LONG_MIN        LONG_MIN
#define PCTK_LONG_MAX        LONG_MAX
#define PCTK_ULONG_MAX       ULONG_MAX

#define PCTK_FLOAT_MIN       FLT_MIN
#define PCTK_FLOAT_MAX       FLT_MAX

#define PCTK_DOUBLE_MIN      DBL_MIN
#define PCTK_DOUBLE_MAX      DBL_MAX

#define PCTK_SIZE_MAX        SIZE_MAX

#ifdef SSIZE_MAX
#   define PCTK_SSIZE_MAX    SSIZE_MAX
#else
#   define PCTK_SSIZE_MAX	PCTK_LONG_MAX
#endif

#ifdef RSIZE_MAX
#   define PCTK_RSIZE_MAX    RSIZE_MAX
#else
#   define PCTK_RSIZE_MAX    PCTK_SIZE_MAX
#endif

/* supplemental group IDs are available */
#ifdef NGROUPS_MAX
#   define PCTK_NGROUPS_MAX NGROUPS_MAX
#else
#   define PCTK_NGROUPS_MAX (65536)
#endif

/* supplemental group IDs are available */
#ifdef NGROUPS_MAX
#   define PCTK_NGROUPS_MAX NGROUPS_MAX
#else
#   define PCTK_NGROUPS_MAX (65536)
#endif

/* # bytes of args + environ for exec() */
#ifdef ARG_MAX
#   define PCTK_ARG_MAX ARG_MAX
#else
#   define PCTK_ARG_MAX (131072)
#endif

/* # links a file may have */
#ifdef LINK_MAX
#   define PCTK_LINK_MAX LINK_MAX
#else
#   define PCTK_LINK_MAX (127)
#endif

/* size of the canonical input queue */
#ifdef MAX_CANON
#   define PCTK_CANON_MAX MAX_CANON
#else
#   define PCTK_CANON_MAX (255)
#endif

/* size of the type-ahead buffer */
#ifdef MAX_INPUT
#   define PCTK_INPUT_MAX MAX_INPUT
#else
#   define PCTK_INPUT_MAX (255)
#endif

/* # chars in a file name */
#ifdef NAME_MAX
#   define PCTK_NAME_MAX NAME_MAX
#else
#   define PCTK_NAME_MAX (255)
#endif

/* # chars in a path name including nul */
#ifdef PATH_MAX
#   define PCTK_PATH_MAX PATH_MAX
#else
#   define PCTK_PATH_MAX (4096)
#endif

/* # bytes in atomic write to a pipe */
#ifdef PIPE_BUF
#   define PCTK_PIPE_BUF PIPE_BUF
#else
#   define PCTK_PIPE_BUF (4096)
#endif

/* # chars in an extended attribute name */
#ifdef XATTR_NAME_MAX
#   define PCTK_XATTR_NAME_MAX XATTR_NAME_MAX
#else
#   define PCTK_XATTR_NAME_MAX (255)
#endif

/* size of an extended attribute value (64k) */
#ifdef XATTR_SIZE_MAX
#   define PCTK_XATTR_SIZE_MAX XATTR_SIZE_MAX
#else
#   define PCTK_XATTR_SIZE_MAX (65536)
#endif

/* size of extended attribute namelist (64k) */
#ifdef XATTR_LIST_MAX
#   define PCTK_XATTR_LIST_MAX XATTR_LIST_MAX
#else
#   define PCTK_XATTR_LIST_MAX (65536)
#endif

#define PCTK_HUMANOUT_MAX    PCTK_NAME_MAX
#define PCTK_LINE_MAX        PCTK_PATH_MAX

#define PCTK_ARRAY_MAX       (PCTK_UINT16_MAX * 100)
#define PCTK_ALLOC_MAX       (PCTK_SIZE_MAX - 1)
#define PCTK_BYTE_ARRAY_MAX  (PCTK_ALLOC_MAX - sizeof(utk_byte_t) - 1)
#define PCTK_STRING_MAX      ((PCTK_ALLOC_MAX - sizeof(utk_char_t)) / 2 - 1)

#define PCTK_INT32_LEN       (sizeof("-2147483648") - 1)
#define PCTK_INT64_LEN       (sizeof("-9223372036854775808") - 1)

#endif //_PCTKLIMITS_H_
