/***********************************************************************************************************************
**
** Library: UTK
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

#include <pctkError.h>
#include <pctkString.h>

PCTK_BEGIN_NAMESPACE

std::string Error::getLastCErrorStr()
{
    char errorString[128];
#if ((_POSIX_C_SOURCE >= 200112L) && !_GNU_SOURCE) || defined(PCTK_OS_APPLE)
    // This is the XSI strerror_r version
    int en = errno;
    int r = strerror_r(errno, errorString, sizeof errorString);
    if (r) {
        std::string errMsg = "Unknown error " + toString(en) + ": strerror_r failed with error code ";
        if (r < 0) {
            errMsg += toString(static_cast<int>(errno));
        } else {
            errMsg += toString(r);
        }
        return errMsg;
    }
    return errorString;
#elif defined(PCTK_OS_WIN)
    if (strerror_s(errorString, sizeof errorString, errno)) {
    return "Unknown error";
  }
  return errorString;
#else
    return strerror_r(errno, errorString, sizeof errorString);
#endif
}

#if defined(PCTK_OS_WIN)
std::string Error::getLastWin32ErrorStr()
{
    // Retrieve the system error message for the last-error code
    LPVOID lpMsgBuf;
    DWORD dw = GetLastError();

    DWORD rc = FormatMessageW(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        reinterpret_cast<LPWSTR>(&lpMsgBuf),
        0,
        NULL);

    // If FormatMessage fails using FORMAT_MESSAGE_ALLOCATE_BUFFER
    // it means that the size of the error message exceeds an internal
    // buffer limit (128 kb according to MSDN) and lpMsgBuf will be
    // uninitialized.
    // Inform the caller that the error message couldn't be retrieved.
    if (rc == 0) {
        return std::string("Failed to retrieve error message.");
    }

    std::string errMsg(ToUTF8String(std::wstring(reinterpret_cast<LPCWSTR>(lpMsgBuf))));

    LocalFree(lpMsgBuf);
    return errMsg;
}
#endif

PCTK_END_NAMESPACE
