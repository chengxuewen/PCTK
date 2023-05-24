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

#include <private/pctkSharedLibrary_p.h>

#if defined(PCTK_OS_UNIX)
#   include <cerrno>
#   include <dlfcn.h>
#elif defined(PCTK_OS_WIN)
//#   include "cppmicroservices/util/Error.h"
//#   include "cppmicroservices/util/String.h"
#   ifndef WIN32_LEAN_AND_MEAN
#       define WIN32_LEAN_AND_MEAN
#   endif
// Do not re-order include directives, it would break MinGW builds.
#   include <windows.h>
#   include <strsafe.h>
#else
#   error Unsupported platform
#endif

#include <stdexcept>
#include <system_error>

PCTK_BEGIN_NAMESPACE

SharedLibraryPrivate::SharedLibraryPrivate(SharedLibrary *q)
    : q_ptr(q),
      m_suffix(US_LIB_EXT),
      m_prefix(US_LIB_PREFIX)
{

}

SharedLibrary::SharedLibrary() : d_ptr(new SharedLibraryPrivate(this))
{

}

SharedLibrary::SharedLibrary(const std::string &libPath, const std::string &name)
    : d_ptr(new SharedLibraryPrivate(this))
{
    PCTK_D(SharedLibrary);
    d->m_name = name;
    d->m_path = libPath;
}

SharedLibrary::SharedLibrary(const std::string &absoluteFilePath) : d_ptr(new SharedLibraryPrivate(this))
{
    PCTK_D(SharedLibrary);
    d->m_filePath = absoluteFilePath;
    this->setFilePath(absoluteFilePath);
}

void SharedLibrary::load(int flags)
{
    PCTK_D(SharedLibrary);
    if (d->m_handle) {
        throw std::logic_error(std::string("Library already loaded: ") + this->getFilePath());
    }
    std::string libPath = this->getFilePath();
#ifdef PCTK_OS_UNIX
    d->m_handle = dlopen(libPath.c_str(), flags);
    if (!d->m_handle) {
        std::error_code err_code(errno, std::generic_category());
        std::string err_msg = "Error loading " + libPath + ".";
        const char *err = dlerror();
        if (err) {
            err_msg += " " + std::string(err);
        }

        d->m_handle = nullptr;

        // Bundle of origin information is not available here. It will be
        // BundlePrivate::Start0() will catch this system_error and create
        // a SharedLibraryException.
        throw std::system_error(err_code, err_msg);
    }
#else
    PCTK_UNUSED(flags);
    std::wstring wpath(cppmicroservices::util::ToWString(libPath));
    d->m_handle = LoadLibraryW(wpath.c_str());

    if (!d->m_handle) {
        std::error_code err_code(GetLastError(), std::generic_category());
        std::string errMsg = "Loading ";
        errMsg.append(libPath).append("failed with error: ").append(util::GetLastWin32ErrorStr());

        d->m_handle = nullptr;

        // Bundle of origin information is not available here. Use try/catch
        // around SharedLibrary::load(), and throw a SharedLibraryException
        // inside the catch statement, with the available bundle of origin.
        throw std::system_error(err_code, errMsg);
    }
#endif
}

void SharedLibrary::load()
{
#ifdef PCTK_OS_UNIX
    this->load(RTLD_LAZY | RTLD_LOCAL);
#else
    this->load(0);
#endif
}

void SharedLibrary::unload()
{
    PCTK_D(SharedLibrary);
    if (d->m_handle) {
#ifdef PCTK_OS_UNIX
        if (dlclose(d->m_handle)) {
            std::string err_msg = "Error unloading " + this->getLibraryPath() + ".";
            const char *err = dlerror();
            if (err) {
                err_msg += " " + std::string(err);
            }

            d->m_handle = nullptr;
            throw std::runtime_error(err_msg);
        }
#else
        if (!FreeLibrary(reinterpret_cast<HMODULE>(d->m_handle))) {
            std::string errMsg = "Unloading ";
            errMsg.append(GetLibraryPath()).append("failed with error: ").append(util::GetLastWin32ErrorStr());

            d->m_handle = nullptr;
            throw std::runtime_error(errMsg);
        }
#endif

        d->m_handle = nullptr;
    }
}

void SharedLibrary::setName(const std::string &name)
{
    PCTK_D(SharedLibrary);
    if (IsLoaded() || !d->m_filePath.empty()) {
        return;
    }

    d->m_name = name;
}

std::string SharedLibrary::getName() const
{
    PCTK_D(const SharedLibrary);
    return d->m_name;
}

std::string SharedLibrary::getFilePath(const std::string &name) const
{
    PCTK_D(const SharedLibrary);
    if (!d->m_filePath.empty()) {
        return d->m_filePath;
    }
    return this->getLibraryPath() + util::DIR_SEP + this->getPrefix() + name + this->getSuffix();
}

void SharedLibrary::setFilePath(const std::string &absoluteFilePath)
{
    PCTK_D(SharedLibrary);
    if (this->isLoaded()) {
        return;
    }

    d->m_filePath = absoluteFilePath;

    std::string name = d->m_filePath;
    std::size_t pos = d->m_filePath.find_last_of(util::DIR_SEP);
    if (pos != std::string::npos) {
        d->m_path = d->m_filePath.substr(0, pos);
        name = d->m_filePath.substr(pos + 1);
    } else {
        d->m_path.clear();
    }

    if (name.size() >= d->m_prefix.size() && name.compare(0, d->m_prefix.size(), d->m_prefix) == 0) {
        name = name.substr(d->m_prefix.size());
    }
    if (name.size() >= d->m_suffix.size() &&
        name.compare(name.size() - d->m_suffix.size(), d->m_suffix.size(), d->m_suffix) == 0) {
        name = name.substr(0, name.size() - d->m_suffix.size());
    }
    d->m_name = name;
}

std::string SharedLibrary::getFilePath() const
{
    PCTK_D(const SharedLibrary);
    return this->getFilePath(d->m_name);
}

void SharedLibrary::setLibraryPath(const std::string &path)
{
    PCTK_D(SharedLibrary);
    if (this->isLoaded() || !d->m_filePath.empty()) {
        return;
    }
    d->m_path = path;
}

std::string SharedLibrary::getLibraryPath() const
{
    PCTK_D(const SharedLibrary);
    return d->m_path;
}

void SharedLibrary::setSuffix(const std::string &suffix)
{
    PCTK_D(SharedLibrary);
    if (this->isLoaded() || !d->m_filePath.empty()) {
        return;
    }
    d->m_suffix = suffix;
}

std::string SharedLibrary::getSuffix() const
{
    PCTK_D(const SharedLibrary);
    return d->m_suffix;
}

void SharedLibrary::setPrefix(const std::string &prefix)
{
    PCTK_D(SharedLibrary);
    if (this->isLoaded() || !d->m_filePath.empty()) {
        return;
    }
    d->m_prefix = prefix;
}

std::string SharedLibrary::getPrefix() const
{
    PCTK_D(const SharedLibrary);
    return d->m_prefix;
}

void *SharedLibrary::getHandle() const
{
    PCTK_D(const SharedLibrary);
    return d->m_handle;
}

bool SharedLibrary::isLoaded() const
{
    PCTK_D(const SharedLibrary);
    return d->m_handle != nullptr;
}

PCTK_END_NAMESPACE
