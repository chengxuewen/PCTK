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

#include <private/pctkFileSystem_p.h>
#include <pctkPlatformDefs.h>
#include <pctkError.h>

#ifdef PCTK_OS_UNIX
#   include <dirent.h>
#   include <dlfcn.h>
#   include <cerrno>
#   include <cstring>
#   include <unistd.h> // getcwd

//#   define PCTK_STAT struct stat
//#   define pctk_stat stat
//#   define pctk_mkdir mkdir
//#   define pctk_rmdir rmdir
//#   define pctk_unlink unlink
#else
#   ifndef WIN32_LEAN_AND_MEAN
#       define WIN32_LEAN_AND_MEAN
#   endif
#   include <Shlwapi.h>
#   include <crtdbg.h>
#   include <direct.h>
#   include <stdint.h>
#   include <windows.h>
#   ifdef __MINGW32__
#       include <dirent.h>
#   else
#       include "dirent_win32.h"
#   endif

//#   define PCTK_STAT struct _stat
//#   define pctk_stat _stat
//#   define pctk_mkdir _mkdir
//#   define pctk_rmdir _rmdir
//#   define pctk_unlink _unlink
#endif

#ifdef PCTK_OS_APPLE
#   include <mach-o/dyld.h>
#endif

#include <sys/stat.h>
#include <sys/types.h>

PCTK_BEGIN_NAMESPACE

FileSystemPrivate::FileSystemPrivate(FileSystem *q) : q_ptr(q)
{

}

FileSystemPrivate::~FileSystemPrivate()
{

}

FileSystem::FileSystem() : d_ptr(new FileSystemPrivate(this))
{

}

namespace detail
{
#if defined(PCTK_OS_WIN)
bool notFoundWin32Error(int errval)
{
    return (errval == ERROR_FILE_NOT_FOUND || errval == ERROR_PATH_NOT_FOUND ||
            errval == ERROR_INVALID_NAME      // "//foo"
            || errval == ERROR_INVALID_DRIVE     // USB card reader with no card inserted
            || errval == ERROR_NOT_READY         // CD/DVD drive with no disc inserted
            || errval == ERROR_INVALID_PARAMETER // ":sys:stat.h"
            || errval == ERROR_BAD_PATHNAME      // "//nosuch" on Win64
            || errval == ERROR_BAD_NETPATH);     // "//nosuch" on Win32
}
#endif

bool notFoundCError(int errval)
{
    return errval == ENOENT || errval == ENOTDIR;
}

std::vector<std::string> splitString(const std::string &str, const std::string &delim)
{
    std::vector<std::string> token;
    std::size_t b = str.find_first_not_of(delim);
    std::size_t e = str.find_first_of(delim, b);
    while (e > b) {
        token.emplace_back(str.substr(b, e - b));
        b = str.find_first_not_of(delim, e);
        e = str.find_first_of(delim, b);
    }
    return token;
}

};

FileSystem::~FileSystem()
{
    delete d_ptr;
}

std::string FileSystem::getExecutablePath()
{
    uint32_t bufSize = PCTK_PATH_MAX;
#if defined(PCTK_OS_WIN)
    std::vector<wchar_t> wbuf(bufSize + 1, '\0');
    if (GetModuleFileNameW(nullptr, wbuf.data(), bufSize) == 0 || GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
        throw std::runtime_error("GetModuleFileName failed" + GetLastWin32ErrorStr());
    }
    return ToUTF8String(wbuf.data());
#elif defined(PCTK_OS_APPLE)
    std::vector<char> buf(bufSize + 1, '\0');
    int status = _NSGetExecutablePath(buf.data(), &bufSize);
    if (status == -1) {
        buf.assign(bufSize + 1, '\0');
        status = _NSGetExecutablePath(buf.data(), &bufSize);
    }
    if (status != 0) {
        throw std::runtime_error("_NSGetExecutablePath() failed");
    }
    // the returned path may not be an absolute path
    return buf.data();
#elif defined(PCTK_OS_LINUX)
    std::vector<char> buf(bufSize + 1, '\0');
    ssize_t len = ::readlink("/proc/self/exe", buf.data(), bufSize);
    if (len == -1 || len == static_cast<ssize_t>(bufSize)) {
        throw std::runtime_error("Could not read /proc/self/exe into buffer");
    }
    return buf.data();
#else
    // 'dlsym' does not work with symbol name 'main'
    throw std::runtime_error("FileSystem::getExecutablePath() failed");
    return "";
#endif
}

std::string FileSystem::getCurrentWorkingDirectory()
{
#if defined(PCTK_OS_WIN)
    DWORD bufSize = ::GetCurrentDirectoryW(0, NULL);
    if (bufSize == 0) {
        bufSize = 1;
    }
    std::vector<wchar_t> buf(bufSize, L'\0');
    if (::GetCurrentDirectoryW(bufSize, buf.data()) != 0) {
        return util::ToUTF8String(buf.data());
    }
#else
    errno = 0; // reset errno to zero in case it was set to some other
    /**
     * value before this call.
     * break out of the loop if any error other than. ERANGE occurs. In the case of ERANGE,
     * we double the bufSize and try again.
     */
    for (std::size_t bufSize = PATH_MAX; (0 == errno) || (ERANGE == errno); bufSize *= 2) {
        std::vector<char> buf(bufSize, '\0');
        const char *rval = getcwd(buf.data(), bufSize);
        if (rval != nullptr) {
            // if we get here, getcwd returned non-null and therefore rval points to the correct
            // results. Return those results.
            return std::string(rval);
        }
    }
#endif
    return std::string();
}

bool FileSystem::exists(const std::string &path)
{
#if defined(PCTK_OS_UNIX)
    PCTK_STATBUF s;
    errno = 0;
    if (PCTK_STAT(path.c_str(), &s)) {
        if (detail::notFoundCError(errno)) {
            return false;
        } else {
            throw std::invalid_argument(Error::getLastCErrorStr());
        }
    }
#else
    std::wstring wpath(ToWString(path));
    DWORD attr(::GetFileAttributesW(wpath.c_str()));
    if (attr == INVALID_FILE_ATTRIBUTES) {
        if (not_found_win32_error(::GetLastError())) {
            return false;
        } else {
            throw std::invalid_argument(GetLastWin32ErrorStr());
        }
    }
#endif
    return true;
}

bool FileSystem::isDirectory(const std::string &path)
{
    PCTK_STATBUF s;
    errno = 0;
    if (PCTK_STAT(path.c_str(), &s)) {
        if (detail::notFoundCError(errno)) {
            return false;
        } else {
            throw std::invalid_argument(Error::getLastCErrorStr());
        }
    }
    return S_ISDIR(s.st_mode);
}

bool FileSystem::isFile(const std::string &path)
{
    PCTK_STATBUF s;
    errno = 0;
    if (PCTK_STAT(path.c_str(), &s)) {
        if (detail::notFoundCError(errno)) {
            return false;
        } else {
            throw std::invalid_argument(Error::getLastCErrorStr());
        }
    }
    return S_ISREG(s.st_mode);
}

bool FileSystem::isRelative(const std::string &path)
{
#if defined(PCTK_OS_WIN)
    if (path.size() > PCTK_PATH_MAX) {
        return false;
    }
    std::wstring wpath(toWString(path));
    return (TRUE == ::PathIsRelativeW(wpath.c_str())) ? true : false;
#else
    return path.empty() || path[0] != PCTK_DIR_SEPARATOR;
#endif
}

std::string FileSystem::getAbsolute(const std::string &path, const std::string &base)
{
    if (FileSystem::isRelative(path)) {
        return base + PCTK_DIR_SEPARATOR + path;
    }
    return path;
}

void FileSystem::makePath(const std::string &path)
{
    std::string subPath;
    std::vector<std::string> dirs = detail::splitString(path, std::string() + "\\" + "/");
    if (dirs.empty()) {
        return;
    }

    std::vector<std::string>::iterator iter = dirs.begin();
#if defined(PCTK_OS_UNIX)
    // Start with the root '/' directory
    subPath = PCTK_DIR_SEPARATOR;
#else
    // Start with the drive letter`
    subPath = *iter + PCTK_DIR_SEPARATOR;
    ++iter;
#endif
    for (; iter != dirs.end(); ++iter) {
        subPath += *iter;
        errno = 0;
#ifdef US_PLATFORM_WINDOWS
        if (PCTK_MKDIR(subPath.c_str()))
#else
        if (PCTK_MKDIR(subPath.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH))
#endif
        {
            if (errno != EEXIST) {
                throw std::invalid_argument(Error::getLastCErrorStr());
            }
        }
        subPath += PCTK_DIR_SEPARATOR;
    }
}

void FileSystem::removeDirectoryRecursive(const std::string &path)
{
    int res = -1;
    errno = 0;
    DIR *dir = PCTK_OPENDIR(path.c_str());
    if (dir != PCTK_NULLPTR) {
        res = 0;

        struct dirent *ent = PCTK_NULLPTR;
        while (!res && (ent = readdir(dir)) != PCTK_NULLPTR) {
            // Skip the names "." and ".." as we don't want to recurse on them.
            if (!strcmp(ent->d_name, ".") || !strcmp(ent->d_name, "..")) {
                continue;
            }

            std::string child = path + PCTK_DIR_SEPARATOR + ent->d_name;
            if
#ifdef _DIRENT_HAVE_D_TYPE
                (ent->d_type == DT_DIR)
#else
                (FileSystem::isDirectory(child))
#endif
            {
                FileSystem::removeDirectoryRecursive(child);
            } else {
                res = PCTK_UNLINK(child.c_str());
            }
        }
        int old_err = errno;
        errno = 0;
        PCTK_CLOSEDIR(dir); // error ignored
        if (old_err) {
            errno = old_err;
        }
    }

    if (!res) {
        errno = 0;
        res = PCTK_RMDIR(path.c_str());
    }

    if (res) {
        throw std::invalid_argument(Error::getLastCErrorStr());
    }
}

PCTK_END_NAMESPACE