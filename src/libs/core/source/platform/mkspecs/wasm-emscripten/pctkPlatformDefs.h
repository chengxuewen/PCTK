/*****************************************************************************************************************************
**
** Library: PCTK
**
** Copyright (C) 2022 ChengXueWen. Contact: 1398831004@qq.com
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

#ifndef _PCTK_WASM_EMSCRIPTEN_PLATFORM_DEFS_H
#define _PCTK_WASM_EMSCRIPTEN_PLATFORM_DEFS_H


// Set any POSIX/XOPEN defines at the top of this file to turn on specific APIs

// 1) need to reset default environment if _BSD_SOURCE is defined
// 2) need to specify POSIX thread interfaces explicitly in glibc 2.0
// 3) it seems older glibc need this to include the X/Open stuff

#include <unistd.h>

// We are hot - unistd.h should have turned on the specific APIs we requested

#include <features.h>
#include <pthread.h>
#include <dirent.h>
#include <fcntl.h>
#include <grp.h>
#include <pwd.h>
#include <signal.h>
#include <dlfcn.h>

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/ipc.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>

#ifndef PCTK_NO_IPV6IFNAME
#   include <net/if.h>
#endif

#ifndef _GNU_SOURCE
#   define _GNU_SOURCE
#endif

#ifdef PCTK_LARGEFILE_SUPPORT
#   define PCTK_STATBUF              struct stat64
#   define PCTK_STATBUF4TSTAT        struct stat64
#   define PCTK_STAT                 ::stat64
#   define PCTK_FSTAT                ::fstat64
#   define PCTK_LSTAT                ::lstat64
#   define PCTK_OPEN                 ::open64
#   define PCTK_TRUNCATE             ::truncate64
#   define PCTK_FTRUNCATE            ::ftruncate64
#   define PCTK_LSEEK                ::lseek64
#else
#   define PCTK_STATBUF              struct stat
#   define PCTK_STATBUF4TSTAT        struct stat
#   define PCTK_STAT                 ::stat
#   define PCTK_FSTAT                ::fstat
#   define PCTK_LSTAT                ::lstat
#   define PCTK_OPEN                 ::open
#   define PCTK_TRUNCATE             ::truncate
#   define PCTK_FTRUNCATE            ::ftruncate
#   define PCTK_LSEEK                ::lseek
#endif

#ifdef PCTK_LARGEFILE_SUPPORT
#   define PCTK_FOPEN                ::fopen64
#   define PCTK_FSEEK                ::fseeko64
#   define PCTK_FTELL                ::ftello64
#   define PCTK_FGETPOS              ::fgetpos64
#   define PCTK_FSETPOS              ::fsetpos64
#   define PCTK_MMAP                 ::mmap64
#   define PCTK_FPOS_T               fpos64_t
#   define PCTK_OFF_T                off64_t
#else
#   define PCTK_FOPEN                ::fopen
#   define PCTK_FSEEK                ::fseek
#   define PCTK_FTELL                ::ftell
#   define PCTK_FGETPOS              ::fgetpos
#   define PCTK_FSETPOS              ::fsetpos
#   define PCTK_MMAP                 ::mmap
#   define PCTK_FPOS_T               fpos_t
#   define PCTK_OFF_T                long
#endif

#define PCTK_STAT_REG             S_IFREG
#define PCTK_STAT_DIR             S_IFDIR
#define PCTK_STAT_MASK            S_IFMT
#define PCTK_STAT_LNK             S_IFLNK
#define PCTK_SOCKET_CONNECT       ::connect
#define PCTK_SOCKET_BIND          ::bind
#define PCTK_FILENO               fileno
#define PCTK_CLOSE                ::close
#define PCTK_READ                 ::read
#define PCTK_WRITE                ::write
#define PCTK_ACCESS               ::access
#define PCTK_GETCWD               ::getcwd
#define PCTK_CHDIR                ::chdir
#define PCTK_MKDIR                ::mkdir
#define PCTK_RMDIR                ::rmdir
#define PCTK_OPEN_LARGEFILE       O_LARGEFILE
#define PCTK_OPEN_RDONLY          O_RDONLY
#define PCTK_OPEN_WRONLY          O_WRONLY
#define PCTK_OPEN_RDWR            O_RDWR
#define PCTK_OPEN_CREAT           O_CREAT
#define PCTK_OPEN_TRUNC           O_TRUNC
#define PCTK_OPEN_APPEND          O_APPEND
#define PCTK_OPEN_EXCL            O_EXCL

// Directory iteration
#define PCTK_DIR                  DIR

#define PCTK_OPENDIR              ::opendir
#define PCTK_CLOSEDIR             ::closedir

#if defined(PCTK_LARGEFILE_SUPPORT) \
    && defined(PCTK_USE_XOPEN_LFS_EXTENSIONS) \
    && !defined(PCTK_NO_READDIR64)
#   define PCTK_DIRENT               struct dirent64
#   define PCTK_READDIR              ::readdir64
#   define PCTK_READDIR_R            ::readdir64_r
#else
#   define PCTK_DIRENT               struct dirent
#   define PCTK_READDIR              ::readdir
#   define PCTK_READDIR_R            ::readdir_r
#endif

#define PCTK_SOCKET_CONNECT       ::connect
#define PCTK_SOCKET_BIND          ::bind


#define PCTK_SIGNAL_RETTYPE       void
#define PCTK_SIGNAL_ARGS          int
#define PCTK_SIGNAL_IGNORE        SIG_IGN

#define PCTK_SOCKLEN_T            socklen_t

#if defined(_XOPEN_SOURCE) && (_XOPEN_SOURCE >= 500)
#   define PCTK_SNPRINTF             ::snprintf
#   define PCTK_VSNPRINTF            ::vsnprintf
#endif

#define PCTK_CURRENT_PID             0

#endif /* _PCTK_WASM_EMSCRIPTEN_PLATFORM_DEFS_H */
