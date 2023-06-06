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

#ifndef _PCTKANY_H
#define _PCTKANY_H

#include <pctkGlobal.h>
#include <pctkTypeTraits.h>

#include <utility>
#include <typeinfo>

PCTK_BEGIN_NAMESPACE

class BadAnyCast : public std::bad_cast
{
public:
    virtual const char *what() const throw()
    {
        return "Any: bad any_cast";
    }
};

class Any
{
public:
    PCTK_CONSTEXPR Any() PCTK_NOEXCEPT: m_content(PCTK_NULLPTR) {}
    Any(const Any &other) : m_content(other.m_content ? other.m_content->clone() : PCTK_NULLPTR) {}

    template<typename T>
    Any(const T &value) : m_content(new Holder<T>(value)) {}

    virtual ~Any() { this->reset(); }

    Any &operator=(const Any &other)
    {
        Any(other).swap(*this);
        return *this;
    }

    template<typename T>
    Any &operator=(const T &value)
    {
        Any(value).swap(*this);
        return *this;
    }

    bool operator==(const Any &other) const
    {
        if (this->type() == other.type())
        {
            if (m_content && other.m_content)
            {
                return m_content->compare(other.m_content);
            }
            else
            {
                return m_content == other.m_content;
            }
        }
        return false;
    }

    bool operator!=(const Any &other) const
    {
        return !(*this == other);
    }

    void reset() PCTK_NOEXCEPT
    {
        if (PCTK_NULLPTR != m_content)
        {
            delete m_content;
            m_content = PCTK_NULLPTR;
        }
    }

    void swap(Any &other) PCTK_NOEXCEPT { std::swap(m_content, other.m_content); }

    bool hasValue() const PCTK_NOEXCEPT { return m_content != PCTK_NULLPTR; }

    const std::type_info &type() const PCTK_NOEXCEPT { return this->hasValue() ? m_content->type() : typeid(void); }

    template<typename T>
    const T *toPtr() const
    {
        return &(static_cast<Holder<T> *>(m_content)->m_hold);
    }

    template<typename T>
    T *toPtr()
    {
        return &(static_cast<Holder<T> *>(m_content)->m_hold);
    }

    template<typename T>
    bool canConvert() const
    {
        return this->hasValue() ? typeid(T) == m_content->type() : false;
    }

private:
    class PlaceHolder
    {
    public:
        virtual ~PlaceHolder() {}

        virtual std::type_info const &type() const = 0;
        virtual PlaceHolder *clone() const = 0;
        virtual bool compare(PlaceHolder *other) const = 0;
    };

    template<typename T>
    class Holder : public PlaceHolder
    {
    public:
        typedef T Type;

        Holder(T const &value) : m_hold(value) {}

        virtual std::type_info const &type() const { return typeid(T); }

        virtual PlaceHolder *clone() const { return new Holder(m_hold); }

        bool compare(PlaceHolder *other) const
        {
            Holder *holder = dynamic_cast<Holder *>(other);
            if (holder)
            {
                return this->m_hold == holder->m_hold;
            }
            return false;
        }

        T m_hold;
    };

    PlaceHolder *m_content;
};

inline void swap(Any &x, Any &y) PCTK_NOEXCEPT
{
    x.swap(y);
}

template<typename T>
inline T any_cast(Any const &operand)
{
    const T *result = any_cast<typename TypeAddConst<typename TypeRemoveReference<T>::Type>::Type>(&operand);
    if (!result)
    {
        throw BadAnyCast();
    }
    return *result;
}

template<typename T>
inline T any_cast(Any &operand)
{
    const T *result = any_cast<typename TypeRemoveReference<T>::Type>(&operand);

    if (!result)
    {
        throw BadAnyCast();
    }
    return *result;
}

template<typename T>
inline T const *any_cast(Any const *operand) PCTK_NOEXCEPT
{
    return operand != PCTK_NULLPTR && operand->type() == typeid(T) ? operand->toPtr<T>() : PCTK_NULLPTR;
}

template<typename T>
inline T *any_cast(Any *operand) PCTK_NOEXCEPT
{
    return operand != PCTK_NULLPTR && operand->type() == typeid(T) ? operand->toPtr<T>() : PCTK_NULLPTR;
}

PCTK_END_NAMESPACE

#endif //_PCTKANY_H
