/*****************************************************************************************************************************
**
** Library: PCTK
**
** Copyright (C) 2022 ChengXueWen. Contact: 1398831004@qq.com
** Copyright (C) 2016 The Qt Company Ltd.
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
*************************************************************************************/

#ifndef _PCTK_WIN32_GXX_PLATFORM_DEFS_H
#define _PCTK_WIN32_GXX_PLATFORM_DEFS_H


#ifdef UNICODE
#   ifndef _UNICODE
#       define _UNICODE
#   endif
#endif

#include <unistd.h> // Defines _POSIX_THREAD_SAFE_FUNCTIONS and others


#include <tchar.h>
#include <io.h>
#include <direct.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <limits.h>

#if !defined(_WIN32_WINNT) || (_WIN32_WINNT-0 < 0x0500)
typedef enum {
    NameUnknown           = 0,
    NameFullyQualifiedDN  = 1,
    NameSamCompatible     = 2,
    NameDisplay           = 3,
    NameUniqueId          = 6,
    NameCanonical         = 7,
    NameUserPrincipal     = 8,
    NameCanonicalEx       = 9,
    NameServicePrincipal  = 10,
    NameDnsDomain         = 12
} EXTENDED_NAME_FORMAT, *PEXTENDED_NAME_FORMAT;
#endif

#ifdef PCTK_LARGEFILE_SUPPORT
#   define PCTK_STATBUF              struct _stati64         // non-ANSI defs
#   define PCTK_STATBUF4TSTAT        struct _stati64         // non-ANSI defs
#   define PCTK_STAT                 ::_stati64
#   define PCTK_FSTAT                ::_fstati64
#else
#   define PCTK_STATBUF              struct _stat            // non-ANSI defs
#   define PCTK_STATBUF4TSTAT        struct _stat            // non-ANSI defs
#   define PCTK_STAT                 ::_stat
#   define PCTK_FSTAT                ::_fstat
#endif
#define PCTK_STAT_REG             _S_IFREG
#define PCTK_STAT_DIR             _S_IFDIR
#define PCTK_STAT_MASK            _S_IFMT
#if defined(_S_IFLNK)
#   define PCTK_STAT_LNK           _S_IFLNK
#endif
#define PCTK_FILENO               _fileno
#define PCTK_OPEN                 ::_open
#define PCTK_CLOSE                ::_close
#ifdef PCTK_LARGEFILE_SUPPORT
#   define PCTK_LSEEK                ::_lseeki64
#   ifndef UNICODE
#       define PCTK_TSTAT                ::_stati64
#   else
#       define PCTK_TSTAT                ::_wstati64
#   endif
#else
#   define PCTK_LSEEK                ::_lseek
#   ifndef UNICODE
#       define PCTK_TSTAT                ::_stat
#   else
#       define PCTK_TSTAT                ::_wstat
#   endif
#endif
#define PCTK_READ                 ::_read
#define PCTK_WRITE                ::_write
#define PCTK_ACCESS               ::_access
#define PCTK_GETCWD               ::_getcwd
#define PCTK_CHDIR                ::_chdir
#define PCTK_MKDIR                ::_mkdir
#define PCTK_RMDIR                ::_rmdir
#define PCTK_OPEN_LARGEFILE       0
#define PCTK_OPEN_RDONLY          _O_RDONLY
#define PCTK_OPEN_WRONLY          _O_WRONLY
#define PCTK_OPEN_RDWR            _O_RDWR
#define PCTK_OPEN_CREAT           _O_CREAT
#define PCTK_OPEN_TRUNC           _O_TRUNC
#define PCTK_OPEN_APPEND          _O_APPEND
#if defined(O_TEXT)
#   define PCTK_OPEN_TEXT           _O_TEXT
#   define PCTK_OPEN_BINARY         _O_BINARY
#endif

#include "../common/c89/pctkPlatformDefs.h"

#ifdef PCTK_LARGEFILE_SUPPORT
#   undef PCTK_FSEEK
#   undef PCTK_FTELL
#   undef PCTK_OFF_T

#   define PCTK_FSEEK                ::fseeko64
#   define PCTK_FTELL                ::ftello64
#   define PCTK_OFF_T                off64_t
#endif

#define PCTK_SIGNAL_ARGS          int

#define PCTK_VSNPRINTF            ::_vsnprintf
#define PCTK_SNPRINTF             ::_snprintf

#define PCTK_CURRENT_PID             GetCurrentProcessId

#define F_OK   0
#define X_OK   1
#define W_OK   2
#define R_OK   4


#endif /* _PCTK_WIN32_GXX_PLATFORM_DEFS_H */
