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

#ifndef _PCTK_DARWIN_GXX_PLATFORM_DEFS_H
#define _PCTK_DARWIN_GXX_PLATFORM_DEFS_H


// Set any POSIX/XOPEN defines at the top of this file to turn on specific APIs

#include <unistd.h>

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
#include <sys/shm.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <netinet/in.h>

#include "../common/posix/pctkPlatformDefs.h"

#undef PCTK_OPEN_LARGEFILE
#define PCTK_OPEN_LARGEFILE       0

#define PCTK_SNPRINTF             ::snprintf
#define PCTK_VSNPRINTF            ::vsnprintf


struct CFArrayCallBacks;
struct CFRunLoopSourceContext;
struct FSEventStreamContext;
struct CFRange;

typedef double CFAbsoluteTime;
typedef double CFTimeInterval;
typedef int FSEventStreamEventFlags;
typedef int OSStatus;
typedef long CFIndex;
typedef struct CFArrayCallBacks CFArrayCallBacks;
typedef struct CFRunLoopSourceContext CFRunLoopSourceContext;
typedef struct FSEventStreamContext FSEventStreamContext;
typedef uint32_t FSEventStreamCreateFlags;
typedef uint64_t FSEventStreamEventId;
typedef unsigned CFStringEncoding;
typedef void* CFAllocatorRef;
typedef void* CFArrayRef;
typedef void* CFBundleRef;
typedef void* CFDataRef;
typedef void* CFDictionaryRef;
typedef void* CFMutableDictionaryRef;
typedef struct CFRange CFRange;
typedef void* CFRunLoopRef;
typedef void* CFRunLoopSourceRef;
typedef void* CFStringRef;
typedef void* CFTypeRef;
typedef void* FSEventStreamRef;

typedef uint32_t IOOptionBits;
typedef unsigned int io_iterator_t;
typedef unsigned int io_object_t;
typedef unsigned int io_service_t;
typedef unsigned int io_registry_entry_t;


typedef void (*FSEventStreamCallback)(const FSEventStreamRef,
                                      void*,
                                      size_t,
                                      void*,
                                      const FSEventStreamEventFlags*,
                                      const FSEventStreamEventId*);

struct CFRunLoopSourceContext {
    CFIndex version;
    void* info;
    void* pad[7];
    void (*perform)(void*);
};

struct FSEventStreamContext {
    CFIndex version;
    void* info;
    void* pad[3];
};

struct CFRange {
    CFIndex location;
    CFIndex length;
};

static const CFStringEncoding kCFStringEncodingUTF8 = 0x8000100;
static const OSStatus noErr = 0;

static const FSEventStreamEventId kFSEventStreamEventIdSinceNow = -1;

static const int kFSEventStreamCreateFlagNoDefer = 2;
static const int kFSEventStreamCreateFlagFileEvents = 16;

static const int kFSEventStreamEventFlagEventIdsWrapped = 8;
static const int kFSEventStreamEventFlagHistoryDone = 16;
static const int kFSEventStreamEventFlagItemChangeOwner = 0x4000;
static const int kFSEventStreamEventFlagItemCreated = 0x100;
static const int kFSEventStreamEventFlagItemFinderInfoMod = 0x2000;
static const int kFSEventStreamEventFlagItemInodeMetaMod = 0x400;
static const int kFSEventStreamEventFlagItemIsDir = 0x20000;
static const int kFSEventStreamEventFlagItemModified = 0x1000;
static const int kFSEventStreamEventFlagItemRemoved = 0x200;
static const int kFSEventStreamEventFlagItemRenamed = 0x800;
static const int kFSEventStreamEventFlagItemXattrMod = 0x8000;
static const int kFSEventStreamEventFlagKernelDropped = 4;
static const int kFSEventStreamEventFlagMount = 64;
static const int kFSEventStreamEventFlagRootChanged = 32;
static const int kFSEventStreamEventFlagUnmount = 128;
static const int kFSEventStreamEventFlagUserDropped = 2;


#endif /* _PCTK_DARWIN_GXX_PLATFORM_DEFS_H */
