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

#ifndef _PCTKSYSTEM_H_
#define _PCTKSYSTEM_H_

/*
   The operating system, must be one of: (PCTK_OS_x)

     DARWIN   - Any Darwin system (macOS, iOS, watchOS, tvOS)
     MACOS    - macOS
     IOS      - iOS
     WATCHOS  - watchOS
     TVOS     - tvOS
     WIN32    - Win32 (Windows 2000/XP/Vista/7 and Windows Server 2003/2008)
     CYGWIN   - Cygwin
     SOLARIS  - Sun Solaris
     HPUX     - HP-UX
     LINUX    - Linux [has variants]
     FREEBSD  - FreeBSD [has variants]
     NETBSD   - NetBSD
     OPENBSD  - OpenBSD
     INTERIX  - Interix
     AIX      - AIX
     HURD     - GNU Hurd
     QNX      - QNX [has variants]
     QNX6     - QNX RTP 6.1
     LYNX     - LynxOS
     BSD4     - Any BSD 4.4 system
     UNIX     - Any UNIX BSD/SYSV system
     ANDROID  - Android platform
     HAIKU    - Haiku
     WEBOS    - LG WebOS

   The following operating systems have variants:
     LINUX    - both PCTK_OS_LINUX and PCTK_OS_ANDROID are defined when building for Android
              - only PCTK_OS_LINUX is defined if building for other Linux systems
     MACOS    - both PCTK_OS_BSD4 and PCTK_OS_IOS are defined when building for iOS
              - both PCTK_OS_BSD4 and PCTK_OS_MACOS are defined when building for macOS
     FREEBSD  - PCTK_OS_FREEBSD is defined only when building for FreeBSD with a BSD userland
              - PCTK_OS_FREEBSD_KERNEL is always defined on FreeBSD, even if the userland is from GNU
*/

#if defined(__APPLE__) && (defined(__GNUC__) || defined(__xlC__) || defined(__xlc__))
#   include <TargetConditionals.h>
#   if defined(TARGET_OS_MAC) && TARGET_OS_MAC
#       define PCTK_OS_DARWIN
#       define PCTK_OS_BSD4
#       ifdef __LP64__
#           define PCTK_OS_DARWIN64
#       else
#           define PCTK_OS_DARWIN32
#       endif
#       if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#           define PCTK_PLATFORM_UIKIT
#           if defined(TARGET_OS_WATCH) && TARGET_OS_WATCH
#               define PCTK_OS_WATCHOS
#           elif defined(TARGET_OS_TV) && TARGET_OS_TV
#               define PCTK_OS_TVOS
#           else
#               // TARGET_OS_IOS is only available in newer SDKs,
#               // so assume any other iOS-based platform is iOS for now
#               define PCTK_OS_IOS
#           endif
#       else
#           // TARGET_OS_OSX is only available in newer SDKs,
#           // so assume any non iOS-based platform is macOS for now
#           define PCTK_OS_MACOS
#       endif
#   else
#       error "PCTK has not been ported to this Apple platform"
#   endif
#elif defined(__WEBOS__)
#   define PCTK_OS_WEBOS
#d  efine PCTK_OS_LINUX
#elif defined(__ANDROID__) || defined(ANDROID)
#   define PCTK_OS_ANDROID
#   define PCTK_OS_LINUX
#elif defined(__CYGWIN__)
#   define PCTK_OS_CYGWIN
#elif !defined(SAG_COM) && (!defined(WINAPI_FAMILY) || WINAPI_FAMILY==WINAPI_FAMILY_DESKTOP_APP) && (defined(WIN64) || defined(_WIN64) || defined(__WIN64__))
#   define PCTK_OS_WIN32
#   define PCTK_OS_WIN64
#elif !defined(SAG_COM) && (defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__))
#   if defined(WINCE) || defined(_WIN32_WCE)
#       define PCTK_OS_WINCE
#   elif defined(WINAPI_FAMILY)
#       ifndef WINAPI_FAMILY_PC_APP
#           define WINAPI_FAMILY_PC_APP WINAPI_FAMILY_APP
#       endif
#       if defined(WINAPI_FAMILY_PHONE_APP) && (WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
#           define PCTK_OS_WINPHONE
#           define PCTK_OS_WINRT
#       elif (WINAPI_FAMILY == WINAPI_FAMILY_PC_APP)
#           define PCTK_OS_WINRT
#       else
#           define PCTK_OS_WIN32
#       endif
#   else
#       define PCTK_OS_WIN32
#   endif
#elif defined(__sun) || defined(sun)
#   define PCTK_OS_SOLARIS
#elif defined(hpux) || defined(__hpux)
#   define PCTK_OS_HPUX
#elif defined(__native_client__)
#   define PCTK_OS_NACL
#elif defined(__EMSCRIPTEN__)
#   define PCTK_OS_WASM
#elif defined(__linux__) || defined(__linux)
#   define PCTK_OS_LINUX
#elif defined(__FreeBSD__) || defined(__DragonFly__) || defined(__FreeBSD_kernel__)
#   ifndef __FreeBSD_kernel__
#       define PCTK_OS_FREEBSD
#   endif
#   define PCTK_OS_FREEBSD_KERNEL
#   define PCTK_OS_BSD4
#elif defined(__NetBSD__)
#   define PCTK_OS_NETBSD
#   define PCTK_OS_BSD4
#elif defined(__OpenBSD__)
#   define PCTK_OS_OPENBSD
#   define PCTK_OS_BSD4
#elif defined(__INTERIX)
#   define PCTK_OS_INTERIX
#   define PCTK_OS_BSD4
#elif defined(_AIX)
#   define PCTK_OS_AIX
#elif defined(__Lynx__)
#   define PCTK_OS_LYNX
#elif defined(__GNU__)
#   define PCTK_OS_HURD
#elif defined(__QNXNTO__)
#   define PCTK_OS_QNX
#elif defined(__INTEGRITY)
#   define PCTK_OS_INTEGRITY
#elif defined(__rtems__)
#   define PCTK_OS_RTEMS
#elif defined(VXWORKS) /* there is no "real" VxWorks define - this has to be set in the mkspec! */
#   define PCTK_OS_VXWORKS
#elif defined(__HAIKU__)
#   define PCTK_OS_HAIKU
#elif defined(__MACH__)
#   define PCTK_OS_MACH
#else
#   error "PCTK has not been ported to this OS"
#endif

#if defined(PCTK_OS_WIN32) || defined(PCTK_OS_WIN64)
#   define PCTK_OS_WINDOWS
#   define PCTK_OS_WIN
/*
 *  On Windows, pointers to dllimport'ed variables are not constant expressions,
 *  so to keep to certain initializations constexpr, we need to use functions instead.
 */
#   define PCTK_NO_DATA_RELOCATION
#endif

#if defined(PCTK_OS_WIN)
#   undef PCTK_OS_UNIX
#elif !defined(PCTK_OS_UNIX)
#   define PCTK_OS_UNIX
#endif

/* Compatibility synonyms */
#ifdef PCTK_OS_DARWIN
#   define PCTK_OS_MAC
#endif
#ifdef PCTK_OS_DARWIN32
#   define PCTK_OS_MAC32
#endif
#ifdef PCTK_OS_DARWIN64
#   define PCTK_OS_MAC64
#endif
#ifdef PCTK_OS_MACOS
#   define PCTK_OS_MACX
#   define PCTK_OS_OSX
#endif

#ifdef PCTK_OS_DARWIN
#   include <Availability.h>
#   include <AvailabilityMacros.h>

#   ifdef PCTK_OS_MACOS
#       if !defined(__MAC_OS_X_VERSION_MIN_REQUIRED) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_6
#           undef __MAC_OS_X_VERSION_MIN_REQUIRED
#           define __MAC_OS_X_VERSION_MIN_REQUIRED __MAC_10_6
#       endif
#       if !defined(MAC_OS_X_VERSION_MIN_REQUIRED) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
#           undef MAC_OS_X_VERSION_MIN_REQUIRED
#           define MAC_OS_X_VERSION_MIN_REQUIRED MAC_OS_X_VERSION_10_6
#       endif
#   endif

#   // Numerical checks are preferred to named checks, but to be safe
#   // we define the missing version names in case PCTK uses them.

#   if !defined(__MAC_10_11)
#       define __MAC_10_11 101100
#   endif
#   if !defined(__MAC_10_12)
#       define __MAC_10_12 101200
#   endif
#   if !defined(__MAC_10_13)
#       define __MAC_10_13 101300
#   endif
#   if !defined(__MAC_10_14)
#       define __MAC_10_14 101400
#   endif
#   if !defined(__MAC_10_15)
#       define __MAC_10_15 101500
#   endif
#   if !defined(__MAC_10_16)
#       define __MAC_10_16 101600
#   endif
#   if !defined(MAC_OS_X_VERSION_10_11)
#       define MAC_OS_X_VERSION_10_11 __MAC_10_11
#   endif
#   if !defined(MAC_OS_X_VERSION_10_12)
#       define MAC_OS_X_VERSION_10_12 __MAC_10_12
#   endif
#   if !defined(MAC_OS_X_VERSION_10_13)
#       define MAC_OS_X_VERSION_10_13 __MAC_10_13
#   endif
#   if !defined(MAC_OS_X_VERSION_10_14)
#       define MAC_OS_X_VERSION_10_14 __MAC_10_14
#   endif
#   if !defined(MAC_OS_X_VERSION_10_15)
#       define MAC_OS_X_VERSION_10_15 __MAC_10_15
#   endif
#   if !defined(MAC_OS_X_VERSION_10_16)
#       define MAC_OS_X_VERSION_10_16 __MAC_10_16
#   endif
#

#   if !defined(__IPHONE_10_0)
#       define __IPHONE_10_0 100000
#   endif
#   if !defined(__IPHONE_10_1)
#       define __IPHONE_10_1 100100
#   endif
#   if !defined(__IPHONE_10_2)
#       define __IPHONE_10_2 100200
#   endif
#   if !defined(__IPHONE_10_3)
#       define __IPHONE_10_3 100300
#   endif
#   if !defined(__IPHONE_11_0)
#       define __IPHONE_11_0 110000
#   endif
#   if !defined(__IPHONE_12_0)
#       define __IPHONE_12_0 120000
#   endif
#endif

#ifdef __LSB_VERSION__
#   if __LSB_VERSION__ < 40
#       error "This version of the Linux Standard Base is unsupported"
#   endif
#   ifndef PCTK_LINUXBASE
#       define PCTK_LINUXBASE
#   endif
#endif

#endif //_PCTKSYSTEM_H_
