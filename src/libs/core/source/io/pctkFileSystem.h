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

#ifndef _PCTKFILESYSTEM_H
#define _PCTKFILESYSTEM_H

#include <pctkGlobal.h>

#include <string>

PCTK_BEGIN_NAMESPACE

class FileSystemPrivate;

/**
 * @brief
 */
class PCTK_CORE_API FileSystem
{
public:
    FileSystem();
    virtual ~FileSystem();

    /**
     * @brief Get the path of the calling executable.
     * @throw Throws std::runtime_error if the path cannot be determined.
     * @return executable path
     */
    static std::string getExecutablePath();

    /**
     * @brief Platform agnostic way to get the current working directory. Supports Linux, Mac, and Windows.
     * @return
     */
    static std::string getCurrentWorkingDirectory();

    /**
     * @brief
     * @param path
     * @return
     */
    bool exists(const std::string &path);

    /**
     * @brief
     * @param path
     * @return
     */
    bool isDirectory(const std::string &path);

    /**
     * @brief
     * @param path
     * @return
     */
    bool isFile(const std::string &path);

    /**
     * @brief
     * @param path
     * @return
     */
    bool isRelative(const std::string &path);

    /**
     * @brief
     * @param path
     * @param base
     * @return
     */
    std::string getAbsolute(const std::string &path, const std::string &base);

    /**
     * @brief
     * @param path
     */
    void makePath(const std::string &path);

    /**
     * @brief
     * @param path
     */
    void removeDirectoryRecursive(const std::string &path);

private:
    FileSystemPrivate *d_ptr;
    PCTK_DECL_PRIVATE_D(d_ptr, FileSystem)
};

PCTK_END_NAMESPACE

#endif //_PCTKFILESYSTEM_H
