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

#ifndef _PCTKTAG_H
#define _PCTKTAG_H

#include <pctkGlobal.h>

#include <string>

PCTK_BEGIN_NAMESPACE

class PCTK_CORE_API Tag
{
public:
    Tag();
    Tag(int id);
    Tag(const char *name);
    Tag(const std::string &name);

    Tag withSuffix(int suffix) const;
    Tag withSuffix(const char *suffix) const;
    Tag withSuffix(const std::string &suffix) const;
    Tag withPrefix(const char *prefix) const;

    const char *name() const;
    std::string toString() const;
    std::string suffixAfter(Tag baseId) const;
    bool isValid() const
    {
        return m_id;
    }
    bool operator==(Tag id) const
    {
        return m_id == id.m_id;
    }
    bool operator==(const char *name) const;
    bool operator!=(Tag id) const
    {
        return m_id != id.m_id;
    }
    bool operator!=(const char *name) const
    {
        return !operator==(name);
    }
    bool operator<(Tag id) const
    {
        return m_id < id.m_id;
    }
    bool operator>(Tag id) const
    {
        return m_id > id.m_id;
    }

    int uniqueIdentifier() const
    {
        return m_id;
    }
    static Tag fromUniqueIdentifier(int id)
    {
        return Tag(id);
    }
    static Tag fromString(const std::string &string);
    static void registerId(int id, const char *name);

private:
    int m_id;
};

PCTK_END_NAMESPACE

#endif //_PCTKTAG_H
