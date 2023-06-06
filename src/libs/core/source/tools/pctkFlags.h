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

#ifndef _PCTKFLAGS_H
#define _PCTKFLAGS_H

#include <pctkTypeInfo.h>

PCTK_BEGIN_NAMESPACE

/**
 * @brief The Flag class is a helper data type for Flags.
 * It is equivalent to a plain @c int, except with respect to function overloading and type conversions. You should
 * never need to use this class in your applications.
 */
class PCTK_CORE_API Flag
{
    int i;
public:
    inline Flag(int i) : i(i) {}
    inline operator int() const { return i; }

#if !defined(PCTK_CC_MSVC)
    // Microsoft Visual Studio has buggy behavior when it comes to unsigned enums: even if the enum is unsigned, the
    // enum tags are always signed
#  if !defined(__LP64__)
    PCTK_CONSTEXPR inline Flag(long ai) PCTK_NOTHROW : i(int(ai)) {}
    PCTK_CONSTEXPR inline Flag(ulong ai) PCTK_NOTHROW : i(int(long(ai))) {}
#  endif
    PCTK_CONSTEXPR inline Flag(uint ai) PCTK_NOTHROW: i(int(ai)) {}
    PCTK_CONSTEXPR inline Flag(short ai) PCTK_NOTHROW: i(int(ai)) {}
    PCTK_CONSTEXPR inline Flag(ushort ai) PCTK_NOTHROW: i(int(uint(ai))) {}
    PCTK_CONSTEXPR inline operator uint() const PCTK_NOTHROW { return uint(i); }
#endif
};
PCTK_DECL_TYPEINFO(Flag, PCTK_TYPEINFO_PRIMITIVE);

class IncompatibleFlag
{
    int i;
public:
    PCTK_CONSTEXPR inline explicit IncompatibleFlag(int ai) PCTK_NOTHROW: i(ai) {}
    PCTK_CONSTEXPR inline operator int() const PCTK_NOTHROW { return i; }
};
PCTK_DECL_TYPEINFO(IncompatibleFlag, PCTK_TYPEINFO_PRIMITIVE);

/**
 * @brief The pctk::Flags class provides a type-safe way of storing OR-combinations of enum values.
 * The pctk::Flags<Enum> class is a template class, where Enum is an enum type. pctk::Flags is used throughout pctk for
 * storing combinations of enum values.
 *
 * The traditional C++ approach for storing OR-combinations of enum values is to use an @c int or @c cfuint variable.
 * The inconvenience with this approach is that there's no type checking at all; any enum value can be OR'd with any
 * other enum value and passed on to a function that takes an @c int or @c uint.
 *
 * If you try to pass a value from another enum or just a plain integer other than 0, the compiler will report an error.
 * If you need to cast integer values to flags in a untyped fashion, you can use the explicit pctk::Flags constructor as
 * cast operator.
 *
 * If you want to use pctk::Flags for your own enum types, use the PCTK_DECL_FLAGS() and PCTK_DECL_OPERATORS_FOR_FLAGS().
 * @tparam Enum
 */
template<typename Enum>
class Flags
{
    PCTK_STATIC_ASSERT_X((sizeof(Enum) <= sizeof(int)),
                         "Flags uses an int as storage, so an enum with underlying long long will overflow.");
    struct Private;
    typedef int (Private::*Zero);
public:
#if defined(PCTK_CC_MSVC)
    // see above for MSVC the definition below is too complex for qdoc
    typedef int Int;
#else
    typedef typename TypeIf<TypeIsUnsigned<Enum>::value, unsigned int, signed int>::Type Int;
#endif
    typedef Enum EnumType;
    // compiler-generated copy/move ctor/assignment operators are fine!

    //    inline Flags(const Flags &other);
    //    inline Flags &operator=(const Flags &other);
    PCTK_CONSTEXPR inline Flags(Enum f)
    PCTK_NOTHROW: i(Int(f)) {}
    PCTK_CONSTEXPR inline Flags(Zero = PCTK_NULLPTR)
    PCTK_NOTHROW: i(0) {}
    PCTK_CONSTEXPR inline Flags(Flag f)
    PCTK_NOTHROW: i(f) {}

#if PCTK_CC_FEATURE_INITIALIZER_LISTS
    PCTK_CONSTEXPR inline Flags(std::initializer_list<Enum> flags) PCTK_NOTHROW
        : i(initializer_list_helper(flags.begin(), flags.end())) {}
#endif

    PCTK_RELAXED_CONSTEXPR inline Flags &operator&=(int mask) PCTK_NOTHROW
    {
        i &= mask;
        return *this;
    }
    PCTK_RELAXED_CONSTEXPR inline Flags &operator&=(uint mask) PCTK_NOTHROW
    {
        i &= mask;
        return *this;
    }
    PCTK_RELAXED_CONSTEXPR inline Flags &operator&=(Enum mask) PCTK_NOTHROW
    {
        i &= Int(mask);
        return *this;
    }
    PCTK_RELAXED_CONSTEXPR inline Flags &operator|=(Flags f) PCTK_NOTHROW
    {
        i |= f.i;
        return *this;
    }
    PCTK_RELAXED_CONSTEXPR inline Flags &operator|=(Enum f) PCTK_NOTHROW
    {
        i |= Int(f);
        return *this;
    }
    PCTK_RELAXED_CONSTEXPR inline Flags &operator^=(Flags f) PCTK_NOTHROW
    {
        i ^= f.i;
        return *this;
    }
    PCTK_RELAXED_CONSTEXPR inline Flags &operator^=(Enum f) PCTK_NOTHROW
    {
        i ^= Int(f);
        return *this;
    }

    PCTK_CONSTEXPR inline operator Int() const PCTK_NOTHROW { return i; }

    PCTK_CONSTEXPR inline Flags operator|(Flags f) const PCTK_NOTHROW { return Flags(Flag(i | f.i)); }
    PCTK_CONSTEXPR inline Flags operator|(Enum f) const PCTK_NOTHROW { return Flags(Flag(i | Int(f))); }
    PCTK_CONSTEXPR inline Flags operator^(Flags f) const PCTK_NOTHROW { return Flags(Flag(i ^ f.i)); }
    PCTK_CONSTEXPR inline Flags operator^(Enum f) const PCTK_NOTHROW { return Flags(Flag(i ^ Int(f))); }
    PCTK_CONSTEXPR inline Flags operator&(int mask) const PCTK_NOTHROW { return Flags(Flag(i & mask)); }
    PCTK_CONSTEXPR inline Flags operator&(uint mask) const PCTK_NOTHROW { return Flags(Flag(i & mask)); }
    PCTK_CONSTEXPR inline Flags operator&(Enum f) const PCTK_NOTHROW { return Flags(Flag(i & Int(f))); }
    PCTK_CONSTEXPR inline Flags operator~() const PCTK_NOTHROW { return Flags(Flag(~i)); }

    PCTK_CONSTEXPR inline bool operator!() const PCTK_NOTHROW { return !i; }

    PCTK_CONSTEXPR inline bool testFlag(Enum f) const PCTK_NOTHROW {
        return (i & Int(f)) == Int(f) && (Int(f) != 0 || i == Int(f));
    }
private:
#if PCTK_CC_FEATURE_INITIALIZER_LISTS
    PCTK_CONSTEXPR static inline Int initializer_list_helper(typename std::initializer_list<Enum>::const_iterator it,
                                                             typename std::initializer_list<Enum>::const_iterator end)
    PCTK_NOTHROW
    {
        return (it == end ? Int(0) : (Int(*it) | initializer_list_helper(it + 1, end)));
    }
#endif

    Int i;
};

#define PCTK_DECL_FLAGS(FLAGS, Enum)\
typedef PCTK_PREPEND_NAMESPACE(Flags<Enum>) FLAGS;

#define PCTK_DECL_INCOMPATIBLE_FLAGS(Flags) \
PCTK_CONSTEXPR inline PCTK_PREPEND_NAMESPACE(IncompatibleFlag) operator|(Flags::EnumType f1, int f2) PCTK_NOTHROW \
{ return PCTK_PREPEND_NAMESPACE(IncompatibleFlag)(int(f1) | f2); }

#define PCTK_DECL_OPERATORS_FOR_FLAGS(FLAGS) \
PCTK_CONSTEXPR inline PCTK_PREPEND_NAMESPACE(Flags)<FLAGS::EnumType> operator|(FLAGS::EnumType f1, \
                                                                               FLAGS::EnumType f2) PCTK_NOTHROW \
{ return PCTK_PREPEND_NAMESPACE(Flags)<FLAGS::EnumType>(f1) | f2; } \
PCTK_CONSTEXPR inline PCTK_PREPEND_NAMESPACE(Flags)<FLAGS::EnumType> operator|(FLAGS::EnumType f1, \
                                                                               PCTK_PREPEND_NAMESPACE(Flags)<FLAGS::EnumType> f2) PCTK_NOTHROW \
{ return f2 | f1; } PCTK_DECL_INCOMPATIBLE_FLAGS(FLAGS)

PCTK_END_NAMESPACE

#endif //_PCTKFLAGS_H
