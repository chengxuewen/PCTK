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

#ifndef _PCTK_QNX_PLATFORM_DEFS_H
#define _PCTK_QNX_PLATFORM_DEFS_H


// Set any POSIX/XOPEN defines at the top of this file to turn on specific APIs

#include <unistd.h>

#define __STDC_CONSTANT_MACROS

// We are hot - unistd.h should have turned on the specific APIs we requested


#include <pthread.h>
#include <dirent.h>
#include <fcntl.h>
#include <grp.h>
#include <pwd.h>
#include <signal.h>

#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/ipc.h>
#include <sys/time.h>
// QNX doesn't have the System V <sys/shm.h> header. This is not a standard
// POSIX header, it's only documented in the Single UNIX Specification.
// The preferred POSIX compliant way to share memory is to use the functions
// in <sys/mman.h> that comply with the POSIX Real Time Interface (1003.1b).
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <netinet/in.h>

// for htonl
#include <arpa/inet.h>

#define PCTK_USE_XOPEN_LFS_EXTENSIONS
#if !defined(__EXT_QNX__READDIR64_R)
#   define PCTK_NO_READDIR64
#endif
#include "../posix/pctkPlatformDefs.h"
#if defined(__EXT_QNX__READDIR64_R)
#   define PCTK_EXT_QNX_READDIR_R    ::_readdir64_r
#elif defined(__EXT_QNX__READDIR_R)
#   define PCTK_EXT_QNX_READDIR_R    ::_readdir_r
#endif

#define PCTK_SNPRINTF ::snprintf
#define PCTK_VSNPRINTF ::vsnprintf

// QNX6 doesn't have getpagesize()
inline int getpagesize()
{
    return ::sysconf(_SC_PAGESIZE);
}

#include <stdlib.h>

#endif /* _PCTK_QNX_PLATFORM_DEFS_H */
