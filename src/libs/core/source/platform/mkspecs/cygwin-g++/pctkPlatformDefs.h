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

#ifndef _PCTK_CYGWIN_GXX_PLATFORM_DEFS_H
#define _PCTK_CYGWIN_GXX_PLATFORM_DEFS_H


// Set any POSIX/XOPEN defines at the top of this file to turn on specific APIs

// 1) need to reset default environment if _BSD_SOURCE is defined
// 2) need to specify POSIX thread interfaces explicitly in glibc 2.0
// 3) it seems older glibc need this to include the X/Open stuff
#ifndef _GNU_SOURCE
#  define _GNU_SOURCE
#endif

#include <unistd.h>

// We are hot - unistd.h should have turned on the specific APIs we requested


#include <pthread.h>
#include <dirent.h>
#include <fcntl.h>
#include <grp.h>
#include <pwd.h>
#include <signal.h>
#include <dlfcn.h>

#include <sys/types.h>
#include <sys/ioctl.h>
// Cygwin does not provide <sys/ipc.h> and <sys/shm.h> because it
// doesn't support SysV IPC or shared memory. See for example:
//      http://afni.nimh.nih.gov/afni/afniboard/messages/1725.html
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
//#include <windows.h>
#include <netinet/in.h>

#define PCTK_NO_USE_FSEEKO
#include "../common/posix/pctkPlatformDefs.h"

#undef PCTK_OPEN_LARGEFILE
#define PCTK_OPEN_LARGEFILE 0

#if defined(_XOPEN_SOURCE) && (_XOPEN_SOURCE >= 500)
#   define PCTK_SNPRINTF             ::snprintf
#   define PCTK_VSNPRINTF            ::vsnprintf
#endif

#endif /* _PCTK_CYGWIN_GXX_PLATFORM_DEFS_H */
