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
**Ï
*************************************************************************************/

#ifndef _PCTK_AIX_PLATFORM_DEFS_H
#define _PCTK_AIX_PLATFORM_DEFS_H



// Set any POSIX/XOPEN defines at the top of this file to turn on specific APIs

#include <unistd.h>


// We are hot - unistd.h should have turned on the specific APIs we requested


// uncomment if you have problems with <sys/proc.h> because your gcc
// hasn't been built on exactly the same OS version your are using now.
// typedef int crid_t;
// typedef unsigned int class_id_t;
#include <pthread.h>
#include <dirent.h>
#include <fcntl.h>
#include <grp.h>
#include <pwd.h>
#include <signal.h>
#include <dlfcn.h>
#include <strings.h> // AIX X11 headers define FD_ZERO using bzero()

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/ipc.h>
#include <sys/time.h>
#include <sys/select.h>
#include <sys/shm.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <netinet/in.h>

// Only AIX 4.3 and better support 64-bit

#define PCTK_USE_XOPEN_LFS_EXTENSIONS
#include "../posix/pctkPlatformDefs.h"

#undef PCTK_SOCKLEN_T

#ifdef _AIX43
// AIX 4.3 and better
#   define PCTK_SOCKLEN_T            socklen_t
#elif _AIX42
// AIX 4.2
#   define PCTK_SOCKLEN_T            size_t
#else
// AIX 4.1
#   define PCTK_SOCKLEN_T            size_t
// override
#   define PCTK_SOCKOPTLEN_T         int
#endif

#ifdef PCTK_LARGEFILE_SUPPORT
#   undef PCTK_DIR
#   undef PCTK_OPENDIR
#   undef PCTK_CLOSEDIR

#   define PCTK_DIR                  DIR64
#   define PCTK_OPENDIR              ::opendir64
#   define PCTK_CLOSEDIR             ::closedir64
#endif

#if defined(_XOPEN_SOURCE) && (_XOPEN_SOURCE-0 >= 500)
// AIX 4.3 and better
#   define PCTK_SNPRINTF             ::snprintf
#   define PCTK_VSNPRINTF            ::vsnprintf
#endif

#endif /* _PCTK_AIX_PLATFORM_DEFS_H */
