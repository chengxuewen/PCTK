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

#ifndef _PCTKSHAREDLIBRARY_H
#define _PCTKSHAREDLIBRARY_H

#include <pctkGlobal.h>

#include <string>

PCTK_WARNING_PUSH
PCTK_WARNING_DISABLE_MSVC(4251)

PCTK_BEGIN_NAMESPACE

class SharedLibraryPrivate;

/**
 * @ingroup SharedLibrary
 *
 * The SharedLibrary class loads shared libraries at runtime.
 */
class PCTK_CORE_API SharedLibrary
{
public:
    SharedLibrary();
    SharedLibrary(const SharedLibrary &other);

    /**
     * Construct a SharedLibrary object using a library search path and a library base name.
     *
     * @param libPath An absolute path containing the shared library
     * @param name The base name of the shared library, without prefix and suffix.
     */
    SharedLibrary(const std::string &libPath, const std::string &name);

    /**
     * Construct a SharedLibrary object using an absolute file path to the shared library. Using this constructor
     * effectively disables all setters except SetFilePath().
     *
     * @param absoluteFilePath The absolute path to the shared library.
     */
    SharedLibrary(const std::string &absoluteFilePath);

    /**
     * Destroys this object but does not unload the shared library.
     */
    ~SharedLibrary() { delete d_ptr; }

    SharedLibrary &operator=(const SharedLibrary &other);

    /**
     * Loads the shared library pointed to by this SharedLibrary object.
     * On POSIX systems dlopen() is called with the RTLD_LAZY and
     * RTLD_LOCAL flags unless the compiler is gcc 4.4.x or older. Then
     * the RTLD_LAZY and RTLD_GLOBAL flags are used to load the shared library
     * to work around RTTI problems across shared library boundaries.
     *
     * @throws std::logic_error If the library is already loaded.
     * @throws std::system_error If loading the library failed.
     */
    void load();

    /**
     * Loads the shared library pointed to by this SharedLibrary object,
     * using the specified flags on POSIX systems.
     *
     * @throws std::logic_error If the library is already loaded.
     * @throws std::system_error If loading the library failed.
     */
    void load(int flags);

    /**
     * Un-loads the shared library pointed to by this SharedLibrary object.
     *
     * @throws std::runtime_error If an error occurred while un-loading the shared library.
     */
    void unload();

    /**
     * Sets the base name of the shared library. Does nothing if the shared
     * library is already loaded or the SharedLibrary(const std::string&)
     * constructor was used.
     *
     * @param name The base name of the shared library, without prefix and suffix.
     */
    void setName(const std::string &name);

    /**
     * Gets the base name of the shared library.
     * @return The shared libraries base name.
     */
    std::string getName() const;

    /**
     * Gets the absolute file path for the shared library with base name
     * @c name, using the search path returned by GetLibraryPath().
     *
     * @param name The shared library base name.
     * @return The absolute file path of the shared library.
     */
    std::string getFilePath(const std::string &name) const;

    /**
     * Sets the absolute file path of this SharedLibrary object.
     * Using this methods with a non-empty \c absoluteFilePath argument
     * effectively disables all other setters.
     *
     * @param absoluteFilePath The new absolute file path of this SharedLibrary object.
     */
    void setFilePath(const std::string &absoluteFilePath);

    /**
     * Gets the absolute file path of this SharedLibrary object.
     *
     * @return The absolute file path of the shared library.
     */
    std::string getFilePath() const;

    /**
     * Sets a new library search path. Does nothing if the shared
     * library is already loaded or the SharedLibrary(const std::string&)
     * constructor was used.
     *
     * @param path The new shared library search path.
     */
    void setLibraryPath(const std::string &path);

    /**
     * Gets the library search path of this SharedLibrary object.
     *
     * @return The library search path.
     */
    std::string getLibraryPath() const;

    /**
     * Sets the suffix for shared library names (e.g. lib). Does nothing if the shared
     * library is already loaded or the SharedLibrary(const std::string&)
     * constructor was used.
     *
     * @param suffix The shared library name suffix.
     */
    void setSuffix(const std::string &suffix);

    /**
     * Gets the file name suffix of this SharedLibrary object.
     *
     * @return The file name suffix of the shared library.
     */
    std::string getSuffix() const;

    /**
     * Sets the file name prefix for shared library names (e.g. .dll or .so).
     * Does nothing if the shared library is already loaded or the
     * SharedLibrary(const std::string&) constructor was used.
     *
     * @param prefix The shared library name prefix.
     */
    void setPrefix(const std::string &prefix);

    /**
     * Gets the file name prefix of this SharedLibrary object.
     *
     * @return The file name prefix of the shared library.
     */
    std::string getPrefix() const;

    /**
     * Gets the internal handle of this SharedLibrary object.
     *
     * @return \c nullptr if the shared library is not loaded, the operating
     * system specific handle otherwise.
     */
    void *getHandle() const;

    /**
     * Gets the loaded/unloaded stated of this SharedLibrary object.
     *
     * @return \c true if the shared library is loaded, \c false otherwise.
     */
    bool isLoaded() const;

private:
    SharedLibraryPrivate *d_ptr;
    PCTK_DECL_PRIVATE_D(d_ptr, SharedLibrary)
};

PCTK_END_NAMESPACE

PCTK_WARNING_POP

#endif //_PCTKSHAREDLIBRARY_H
