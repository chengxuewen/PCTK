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

#include <pctkTag.h>

#include <string>
#include <cstring>
#include <sstream>
#include <memory>
#include <map>

PCTK_BEGIN_NAMESPACE

class TagStringHolder
{
public:
    TagStringHolder() : n(0), str(NULL) {}

    TagStringHolder(const char *s, int length) : n(length), str(s)
    {
        if (!n)
        {
            length = n = static_cast<int>(strlen(s));
        }
        h = 0;
        while (length--)
        {
            h = (h << 4) + *s++;
            h ^= (h & 0xf0000000) >> 23;
            h &= 0x0fffffff;
        }
    }

    int n;
    const char *str;
    unsigned int h;
};

struct TagStringHolderCompare
{
    bool operator()(const TagStringHolder &lhs, const TagStringHolder &rhs) const
    {
        return std::string(lhs.str) > std::string(rhs.str);
    }
};

static bool operator==(const TagStringHolder &sh1, const TagStringHolder &sh2)
{
    return sh1.h == sh2.h && sh1.str && sh2.str && strcmp(sh1.str, sh2.str) == 0;
}

struct TagCache : public std::map<TagStringHolder, int, TagStringHolderCompare>
{
    // dont allow static leaks
    ~TagCache()
    {
        for (TagCache::iterator iter = this->begin(); iter != this->end(); ++iter)
        {
            delete[](const_cast<char *>(iter->first.str));
        }
    }
};

typedef std::map<int, TagStringHolder> TagMap;;

static int sg_firstUnusedId = 0;
static TagMap sg_stringFromId;
static TagCache sg_idFromString;

static int theId(const char *str, int n = 0)
{
    if (PCTK_NULLPTR == str || !*str)
    {
        //        qCritical() << "theId():parameter str error!";
        return 0;
    }
    TagStringHolder sh(str, n);
    TagCache::iterator iter = sg_idFromString.find(sh);
    int id = 0;
    if (sg_idFromString.end() == iter)
    {
        id = sg_firstUnusedId++;
        sh.str = strdup(sh.str);
        sg_idFromString[sh] = id;
        sg_stringFromId[id] = sh;
    }
    return id;
}

Tag::Tag()
{
    m_id = 0;
}

Tag::Tag(int id)
{
    m_id = id;
}

Tag::Tag(const char *name)
{
    m_id = theId(name, 0);
}

Tag::Tag(const std::string &name)
{
    m_id = theId(name.data(), name.length());
}

const char *Tag::name() const
{
    return sg_stringFromId.find(m_id)->second.str;
}

std::string Tag::toString() const
{
    return std::string(sg_stringFromId.find(m_id)->second.str);
}

Tag Tag::fromString(const std::string &string)
{
    return Tag(theId(string.data(), string.length()));
}

Tag Tag::withSuffix(int suffix) const
{
    std::stringstream sstream;
    sstream << this->name() << suffix;
    return Tag(sstream.str());
}

Tag Tag::withSuffix(const char *suffix) const
{
    std::stringstream sstream;
    sstream << this->name() << suffix;
    return Tag(sstream.str());
}

Tag Tag::withSuffix(const std::string &suffix) const
{
    std::stringstream sstream;
    sstream << this->name() << suffix;
    return Tag(sstream.str());
}

Tag Tag::withPrefix(const char *prefix) const
{
    std::stringstream sstream;
    sstream << prefix << this->name();
    return Tag(sstream.str());
}

void Tag::registerId(int id, const char *name)
{
    TagStringHolder sh(name, 0);
    sg_idFromString[sh] = id;
    sg_stringFromId[id] = sh;
}

bool Tag::operator==(const char *name) const
{
    const char *string = sg_stringFromId.find(m_id)->second.str;
    if (string && name)
    {
        return strcmp(string, name) == 0;
    }
    else
    {
        return false;
    }
}

const char *nameForId(int id)
{
    TagMap::iterator iter = sg_stringFromId.find(id);
    return sg_stringFromId.end() == iter ? PCTK_NULLPTR : iter->second.str;
}

std::string Tag::suffixAfter(Tag baseId) const
{
    const std::string b = baseId.name();
    const std::string n = this->name();
    return 0 == n.compare(0, b.length(), b) ? n.substr(b.length() - 1, n.length() - b.length()) : std::string();
}

std::stringstream &operator<<(std::stringstream &stream, const Tag &id)
{
    //TODO
//    stream << id.toString();
    return stream;
}

std::stringstream &operator>>(std::stringstream &stream, Tag &id)
{
    id = Tag(stream.str());
    return stream;
}

PCTK_END_NAMESPACE