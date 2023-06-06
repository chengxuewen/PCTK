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

#ifndef _PCTKTYPETRAITS_H
#define _PCTKTYPETRAITS_H

#include <pctkGlobal.h>

#include <utility>

PCTK_BEGIN_NAMESPACE

#if PCTK_CC_STDCXX_11
#   include <type_traits>
#endif

template<typename T_type, typename U>
struct TypeIsSame;
template<typename T_type>
struct TypeIsIntegral;
template<typename T_type>
struct TypeIsFloating;
template<typename T_type>
struct TypeIsPointer;
template<typename T_type>
struct TypeIsFloatingPoint;
// MSVC can't compile this correctly, and neither can gcc 3.3.5 (at least)
#if !defined(_MSC_VER) && !(defined(__GNUC__) && __GNUC__ <= 3)
// is_enum uses is_convertible, which is not available on MSVC.
template<typename T_type>
struct TypeIsEnum;
#endif
template<typename T_type>
struct TypeIsPod;
template<typename T_type>
struct TypeIsReference;
template<typename T_type>
struct TypeHasTrivialConstructor;
template<typename T_type>
struct TypeHasTrivialCopy;
template<typename T_type>
struct TypeHasTrivialAssign;
template<typename T_type>
struct TypeHasTrivialDestructor;
template<typename T_type>
struct TypeRemoveConst;
template<typename T_type>
struct TypeRemoveVolatile;
template<typename T_type>
struct TypeRemoveConstVolatile;
template<typename T_type>
struct TypeRemoveReference;
template<typename T_type>
struct TypeAddReference;
template<typename T_type>
struct TypeRemovePointer;
#if !defined(_MSC_VER) && !(defined(__GNUC__) && __GNUC__ <= 3)
template<typename From, typename To>
struct TypeIsConvertible;
#endif

namespace detail
{

// Types small_ and big_ are guaranteed such that sizeof(Small) <
// sizeof(Big)
typedef char Small;

struct Big
{
    char dummy[2];
};

// Identity metafunction.
template<typename T_type>
struct Identity
{
    typedef T_type Type;
};

}

template<typename T_type>
struct TypeTrait
{
    typedef T_type Type;
    typedef T_type &Pass;
    typedef const T_type &Take;
    typedef T_type *Pointer;
};

template<typename T_type, int N>
struct TypeTrait<T_type[N]>
{
    typedef T_type *Type;
    typedef T_type *&Pass;
    typedef const T_type *&Take;
    typedef T_type **Pointer;
};

template<typename T_type>
struct TypeTrait<T_type &>
{
    typedef T_type Type;
    typedef T_type &Pass;
    typedef T_type &Take;
    typedef T_type *Pointer;
};

template<typename T_type>
struct TypeTrait<const T_type &>
{
    typedef const T_type Type;
    typedef const T_type &Pass;
    typedef const T_type &Take;
    typedef const T_type *Pointer;
};

template<>
struct TypeTrait<void>
{
    typedef void Type;
    typedef void Pass;
    typedef void Take;
    typedef void *Pointer;
};

// TypeIntegralConstant, defined in tr1, is a wrapper for an integer
// value. We don't really need this generality; we could get away
// with hardcoding the integer type to bool. We use the fully
// general CFIntegralConstant for compatibility with tr1.
template<typename T_type, T_type v>
struct TypeIntegralConstant
{
    static const T_type value = v;
    typedef T_type Value;
    typedef TypeIntegralConstant<T_type, v> Type;
};

template<typename T_type, T_type v> const T_type TypeIntegralConstant<T_type, v>::value;

// Abbreviations: true_type and false_type are structs that represent boolean
// true and false values. Also define the boost::mpl versions of those names,
// true_ and false_.
typedef TypeIntegralConstant<bool, true> TypeTrue;
typedef TypeIntegralConstant<bool, false> TypeFalse;

template<bool, typename T_type = void>
struct TypeEnableIf {};
template<typename T_type>
struct TypeEnableIf<true, T_type>
{
    typedef T_type Type;
};

// TypeIf is a templatized conditional statement.
// TypeIf<cond, T_A, T_B> is a compile time evaluation of cond.
// TypeIf<>::Type contains T_A if cond is true, T_B otherwise.
template<bool cond, typename T_A, typename T_B>
struct TypeIf
{
    typedef T_A Type;
};

template<typename T_A, typename T_B>
struct TypeIf<false, T_A, T_B>
{
    typedef T_B Type;
};

// TypeAnd is a template && operator.
// TypeAnd<T_A, T_B>::value evaluates "T_A::value && T_B::value".
template<typename T_A, typename T_B>
struct TypeAnd : public TypeIntegralConstant<bool, (T_A::value && T_B::value)> {};

// TypeOr is a template || operator.
// TypeOr<T_A, T_B>::value evaluates "T_A::value || T_B::value".
template<typename T_A, typename T_B>
struct TypeOr : public TypeIntegralConstant<bool, (T_A::value || T_B::value)> {};

// a metafunction to invert an TypeIntegralConstant:
template<typename T_type>
struct TypeNot : TypeIntegralConstant<bool, !T_type::value> {};

// TypeEquals is a template type comparator, similar to Loki IsSameType.
// TypeEquals<T_A, T_B>::value is true iff "T_A" is the same type as "T_B".
//
// New code should prefer base::is_same, defined in base/type_traits.h.
// It is functionally identical, but is_same is the standard spelling.
template<typename T_type, typename T_unknown>
struct TypeEquals : public TypeFalse {};
template<typename T_type>
struct TypeEquals<T_type, T_type> : public TypeTrue {};

// TypeIsSame
template<typename T_type, typename T_unknown>
struct TypeIsSame : TypeFalse {};
template<typename T_type>
struct TypeIsSame<T_type, T_type> : TypeTrue {};

// TypeIsVoid
template<typename T_type>
struct TypeIsVoid : TypeFalse {};
template<>
struct TypeIsVoid<void> : TypeTrue {};

// TypeIsIntegral
template<typename T_type>
struct TypeIsIntegral : TypeFalse {};
template<>
struct TypeIsIntegral<bool> : TypeTrue {};
template<>
struct TypeIsIntegral<char> : TypeTrue {};
template<>
struct TypeIsIntegral<unsigned char> : TypeTrue {};
template<>
struct TypeIsIntegral<signed char> : TypeTrue {};
#if defined(_MSC_VER)
// wchar_t is not by default a distinct type from unsigned short in
// Microsoft C.
// See http://msdn2.microsoft.com/en-us/library/dh8che7s(VS.80).aspx
template<> struct TypeIsIntegral<__wchar_t> : TypeTrue { };
#else
template<>
struct TypeIsIntegral<wchar_t> : TypeTrue {};
#endif
template<>
struct TypeIsIntegral<short> : TypeTrue {};
template<>
struct TypeIsIntegral<unsigned short> : TypeTrue {};
template<>
struct TypeIsIntegral<int> : TypeTrue {};
template<>
struct TypeIsIntegral<unsigned int> : TypeTrue {};
template<>
struct TypeIsIntegral<long> : TypeTrue {};
template<>
struct TypeIsIntegral<unsigned long> : TypeTrue {};
#if defined(PCTK_OS_WIN) && !defined(PCTK_CC_GNU)
template<> struct TypeIsIntegral<__int64> : TypeTrue { };
template<> struct TypeIsIntegral<unsigned __int64> : TypeTrue { };
#else
template<>
struct TypeIsIntegral<long long> : TypeTrue {};
template<>
struct TypeIsIntegral<unsigned long long> : TypeTrue {};
#endif

template<typename T_type>
struct TypeIsIntegral<const T_type> : TypeIsIntegral<T_type> {};
template<typename T_type>
struct TypeIsIntegral<volatile T_type> : TypeIsIntegral<T_type> {};
template<typename T_type>
struct TypeIsIntegral<const volatile T_type> : TypeIsIntegral<T_type> {};
#if PCTK_CC_FEATURE_UNICODE_STRINGS
template<> struct TypeIsIntegral<char16_t> : TypeTrue { };
template<> struct TypeIsIntegral<char32_t> : TypeTrue { };
#endif

// TypeIsFloating
template<typename T_type>
struct TypeIsFloating : TypeFalse {};
template<>
struct TypeIsFloating<float> : TypeTrue {};
template<>
struct TypeIsFloating<double> : TypeTrue {};
template<>
struct TypeIsFloating<long double> : TypeTrue {};

template<typename T_type>
struct TypeIsFloating<const T_type> : TypeIsFloating<T_type> {};
template<typename T_type>
struct TypeIsFloating<volatile T_type> : TypeIsFloating<T_type> {};
template<typename T_type>
struct TypeIsFloating<const volatile T_type> : TypeIsFloating<T_type> {};

// TypeIsFloatingPoint is false except for the built-in floating-point types.
// T_A cv-qualified type is integral if and only if the underlying type is.
template<typename T_type>
struct TypeIsFloatingPoint : TypeFalse {};
template<>
struct TypeIsFloatingPoint<float> : TypeTrue {};
template<>
struct TypeIsFloatingPoint<double> : TypeTrue {};
template<>
struct TypeIsFloatingPoint<long double> : TypeTrue {};
template<typename T_type>
struct TypeIsFloatingPoint<const T_type> : TypeIsFloatingPoint<T_type> {};
template<typename T_type>
struct TypeIsFloatingPoint<volatile T_type> : TypeIsFloatingPoint<T_type> {};
template<typename T_type>
struct TypeIsFloatingPoint<const volatile T_type> : TypeIsFloatingPoint<T_type> {};

// TypeIsPointer is false except for pointer types. T_A cv-qualified type (e.g.
// "int* const", as opposed to "int const*") is cv-qualified if and only if
// the underlying type is.
// TypeIsPointer
template<typename T_type>
struct TypeIsPointer : TypeFalse {};
template<typename T_type>
struct TypeIsPointer<T_type *> : TypeTrue {};
template<typename T_type>
struct TypeIsPointer<const T_type> : TypeIsPointer<T_type> {};
template<typename T_type>
struct TypeIsPointer<volatile T_type> : TypeIsPointer<T_type> {};
template<typename T_type>
struct TypeIsPointer<const volatile T_type> : TypeIsPointer<T_type> {};

// is_reference is false except for reference types.
template<typename T_type>
struct TypeIsReference : TypeFalse {};
template<typename T_type>
struct TypeIsReference<T_type &> : TypeTrue {};

// Specified by TR1 [4.5.3] Type Properties
template<typename T_type>
struct TypeIsConst : TypeFalse {};
template<typename T_type>
struct TypeIsConst<const T_type> : TypeTrue {};
template<typename T_type>
struct TypeIsVolatile : TypeFalse {};
template<typename T_type>
struct TypeIsVolatile<volatile T_type> : TypeTrue {};

#if !defined(_MSC_VER) && !(defined(__GNUC__) && __GNUC__ <= 3)

template<typename T_type>
struct TypeIsClassOrUnion
{
    template<typename U>
    static detail::Small tester(void (U::*)());
    template<typename U>
    static detail::Big tester(...);
    static const bool value = sizeof(tester<T_type>(0)) == sizeof(detail::Small);
};

// TypeIsConvertible chokes if the first argument is an array. That's why
// we use TypeAddReference here.
template<bool NotUnum, typename T_type>
struct TypeIsEnumImpl : TypeIsConvertible<typename TypeAddReference<T_type>::Type, int>
{
};
template<typename T_type>
struct TypeIsEnumImpl<true, T_type> : TypeFalse {};


// Specified by TR1 [4.5.1] primary type categories.

// Implementation note:
//
// Each type is either void, integral, floating point, array, pointer,
// reference, member object pointer, member function pointer, enum,
// union or class. Out of these, only integral, floating point, reference,
// class and enum types are potentially convertible to int. Therefore,
// if a type is not a reference, integral, floating point or class and
// is convertible to int, it's a enum. Adding cv-qualification to a type
// does not change whether it's an enum.
//
// Is-convertible-to-int check is done only if all other checks pass,
// because it can't be used with some types (e.g. void or classes with
// inaccessible conversion operators).
template<typename T_type>
struct TypeIsEnum : TypeIsEnumImpl<
    TypeIsSame<T_type, void>::value || TypeIsIntegral<T_type>::value || TypeIsFloatingPoint<T_type>::value ||
    TypeIsReference<T_type>::value || TypeIsClassOrUnion<T_type>::value, T_type>
{
};

template<typename T_type>
struct TypeIsEnum<const T_type> : TypeIsEnum<T_type> {};
template<typename T_type>
struct TypeIsEnum<volatile T_type> : TypeIsEnum<T_type> {};
template<typename T_type>
struct TypeIsEnum<const volatile T_type> : TypeIsEnum<T_type> {};

#endif

#ifndef PCTK_IS_ENUM
#   if defined(PCTK_CC_GNU) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 3))
#       define PCTK_IS_ENUM(x) __is_enum(x)
#   elif defined(PCTK_CC_MSVC) && defined(_MSC_FULL_VER) && (_MSC_FULL_VER >= 140050215)
#       define PCTK_IS_ENUM(x) __is_enum(x)
#   elif defined(PCTK_CC_CLANG)
#       if __has_extension(is_enum)
#           define PCTK_IS_ENUM(x) __is_enum(x)
#       endif
#   endif
#endif

#ifndef PCTK_IS_ENUM
#   define PCTK_IS_ENUM(x) TypeIsEnum<x>::value
#endif

// We can't get TypeIsPod right without compiler help, so fail conservatively.
// We will assume it's false except for arithmetic types, enumerations,
// pointers and cv-qualified versions thereof. Note that std::pair<T_type,U>
// is not a POD even if T_type and U are PODs.
template<typename T_type>
struct TypeIsPod : TypeIntegralConstant<bool, (TypeIsIntegral<T_type>::value || TypeIsFloatingPoint<T_type>::value ||
                                               #if !defined(_MSC_VER) && !(defined(__GNUC__) && __GNUC__ <= 3)
                                               // TypeIsEnum is not available on MSVC.
                                               TypeIsEnum<T_type>::value ||
                                               #endif
                                               TypeIsPointer<T_type>::value)>
{
};
template<typename T_type>
struct TypeIsPod<const T_type> : TypeIsPod<T_type> {};
template<typename T_type>
struct TypeIsPod<volatile T_type> : TypeIsPod<T_type> {};
template<typename T_type>
struct TypeIsPod<const volatile T_type> : TypeIsPod<T_type> {};

// We can't get TypeHasTrivialConstructor right without compiler help, so
// fail conservatively. We will assume it's false except for: (1) types
// for which TypeIsPod is true. (2) std::pair of types with trivial
// constructors. (3) array of a type with a trivial constructor.
// (4) const versions thereof.
template<typename T_type>
struct TypeHasTrivialConstructor : TypeIsPod<T_type> {};
template<typename T_type, typename U>
struct TypeHasTrivialConstructor<std::pair<T_type, U> > : TypeIntegralConstant<bool,
                                                                               (TypeHasTrivialConstructor<T_type>::value &&
                                                                                TypeHasTrivialConstructor<U>::value)>
{
};
template<typename T_A, int N>
struct TypeHasTrivialConstructor<T_A[N]> : TypeHasTrivialConstructor<T_A> {};
template<typename T_type>
struct TypeHasTrivialConstructor<const T_type> : TypeHasTrivialConstructor<T_type> {};

// We can't get TypeHasTrivialCopy right without compiler help, so fail
// conservatively. We will assume it's false except for: (1) types
// for which TypeIsPod is true. (2) std::pair of types with trivial copy
// constructors. (3) array of a type with a trivial copy constructor.
// (4) const versions thereof.
template<typename T_type>
struct TypeHasTrivialCopy : TypeIsPod<T_type> {};
template<typename T_type, typename U>
struct TypeHasTrivialCopy<std::pair<T_type, U> > : TypeIntegralConstant<bool,
                                                                        (TypeHasTrivialCopy<T_type>::value &&
                                                                         TypeHasTrivialCopy<U>::value)>
{
};
template<typename T_A, int N>
struct TypeHasTrivialCopy<T_A[N]> : TypeHasTrivialCopy<T_A> {};
template<typename T_type>
struct TypeHasTrivialCopy<const T_type> : TypeHasTrivialCopy<T_type> {};

// We can't get TypeHasTrivialAssign right without compiler help, so fail
// conservatively. We will assume it's false except for: (1) types
// for which TypeIsPod is true. (2) std::pair of types with trivial copy
// constructors. (3) array of a type with a trivial assign constructor.
template<typename T_type>
struct TypeHasTrivialAssign : TypeIsPod<T_type> {};
template<typename T_type, typename U>
struct TypeHasTrivialAssign<std::pair<T_type, U> > : TypeIntegralConstant<bool,
                                                                          (TypeHasTrivialAssign<T_type>::value &&
                                                                           TypeHasTrivialAssign<U>::value)>
{
};
template<typename T_A, int N>
struct TypeHasTrivialAssign<T_A[N]> : TypeHasTrivialAssign<T_A> {};

// We can't get TypeHasTrivialDestructor right without compiler help, so
// fail conservatively. We will assume it's false except for: (1) types
// for which TypeIsPod is true. (2) std::pair of types with trivial
// destructors. (3) array of a type with a trivial destructor.
// (4) const versions thereof.
template<typename T_type>
struct TypeHasTrivialDestructor : TypeIsPod<T_type> {};
template<typename T_type, typename U>
struct TypeHasTrivialDestructor<std::pair<T_type, U> > : TypeIntegralConstant<bool,
                                                                              (TypeHasTrivialDestructor<T_type>::value &&
                                                                               TypeHasTrivialDestructor<U>::value)>
{
};
template<typename T_A, int N>
struct TypeHasTrivialDestructor<T_A[N]> : TypeHasTrivialDestructor<T_A> {};
template<typename T_type>
struct TypeHasTrivialDestructor<const T_type> : TypeHasTrivialDestructor<T_type> {};


// Specified by TR1 [4.6] Relationships between types
#if !defined(_MSC_VER) && !(defined(__GNUC__) && __GNUC__ <= 3)
namespace detail
{

// This class is an implementation detail for TypeIsConvertible, and you
// don't need to know how it works to use TypeIsConvertible. For those
// who care: we declare two different functions, one whose argument is
// of type To and one with a variadic argument list. We give them
// return types of different size, so we can use sizeof to trick the
// compiler into telling us which function it would have chosen if we
// had called it with an argument of type From.  See Alexandrescu's
// _Modern C++ Design_ for more details on this sort of trick.
template<typename From, typename To>
struct ConvertHelper
{
    static Small Test(To);
    static Big Test(...);
    static From Create();
};

}

// Inherits from true_type if From is convertible to To, false_type otherwise.
template<typename From, typename To>
struct TypeIsConvertible : TypeIntegralConstant<bool,
                                                sizeof(detail::ConvertHelper<From, To>::Test(detail::ConvertHelper<From,
                                                                                                                   To>::Create())) ==
                                                sizeof(detail::Small)>
{
};

#endif

// Checks whether a type is unsigned (T_type must be convertible to unsigned int):
template<typename T_type>
struct TypeIsUnsigned : TypeIntegralConstant<bool, (T_type(0) < T_type(-1))> {};

// Checks whether a type is signed (T_type must be convertible to int):
template<typename T_type>
struct TypeIsSigned : TypeNot<TypeIsUnsigned<T_type> > {};

PCTK_STATIC_ASSERT((TypeIsUnsigned<unsigned char>::value));
PCTK_STATIC_ASSERT((!TypeIsUnsigned<char>::value));
PCTK_STATIC_ASSERT((!TypeIsSigned<unsigned char>::value));
PCTK_STATIC_ASSERT((TypeIsSigned<char>::value));
PCTK_STATIC_ASSERT((TypeIsUnsigned<unsigned short>::value));
PCTK_STATIC_ASSERT((!TypeIsUnsigned<short>::value));
PCTK_STATIC_ASSERT((!TypeIsSigned<unsigned short>::value));
PCTK_STATIC_ASSERT((TypeIsSigned<short>::value));
PCTK_STATIC_ASSERT((TypeIsUnsigned<unsigned int>::value));
PCTK_STATIC_ASSERT((!TypeIsUnsigned<int>::value));
PCTK_STATIC_ASSERT((!TypeIsSigned<unsigned int>::value));
PCTK_STATIC_ASSERT((TypeIsSigned<int>::value));
PCTK_STATIC_ASSERT((TypeIsUnsigned<unsigned long>::value));
PCTK_STATIC_ASSERT((!TypeIsUnsigned<long>::value));
PCTK_STATIC_ASSERT((!TypeIsSigned<unsigned long>::value));
PCTK_STATIC_ASSERT((TypeIsSigned<long>::value));

template<typename T_type = void>
struct TypeIsDefaultConstructible;

template<>
struct TypeIsDefaultConstructible<void>
{
protected:
    template<bool>
    struct Test
    {
        typedef char Type;
    };
public:
    static bool const value = false;
};

template<>
struct TypeIsDefaultConstructible<>::Test<true>
{
    typedef double Type;
};

template<typename T_type>
struct TypeIsDefaultConstructible : TypeIsDefaultConstructible<>
{
private:
    template<typename U>
    static typename Test<!!sizeof(::new U())>::Type sfinae(U *);
    template<typename U>
    static char sfinae(...);
public:
    static bool const value = sizeof(sfinae<T_type>(0)) > 1;
};

#if PCTK_CC_STDCXX_11
//std::is_base_of

template <typename T_base, typename T_derived>
struct TypeIsBaseOf : public std::is_base_of<T_base, T_derived> { };

#else

/**
 * Compile-time determination of base-class relationship in C++.
 *
 * Use this to provide a template specialization for a set of types.
 * For instance,
 *
 * @code
 * template < class T_thing, bool Tval_derives_from_something = TypeIsBaseOf<Something, T_thing>::value >
 * class TheTemplate
 * {
 *   //Standard implementation.
 * }
 *
 * //Specialization for T_things that derive from Something (Tval_derives_from_something is true)
 * template <typename T_thing>
 * class TheTemplate<T_thing, true>
 * {
 *   T_thing thing;
 *   thing.method_that_is_in_something();
 * }
 * @endcode
 *
 * If you need such a template class elsewhere, and you have a C++11 compiler, std::is_base_of<>
 * is recommended.
 */
template<typename T_base, typename T_derived>
struct TypeIsBaseOf
{
private:
    struct Big
    {
        char memory[64];
    };

    //#ifndef PCTK_SELF_REFERENCE_IN_MEMBER_INITIALIZATION
#if 0

    //Allow the detail inner class to access the other (Big) inner class.
    //The Tru64 compiler needs this.
    friend struct InternalClass;

    //Certain compilers, notably GCC 3.2, require these functions to be inside an inner class.
    struct InternalClass
    {
        static Big  isBaseClass(...);
        static char isBaseClass(typename TypeTrait<T_base>::Pointer);
    };

public:
    static const bool value =
        sizeof(InternalClass::isBaseClass(reinterpret_cast<typename TypeTrait<T_derived>::Pointer>(0))) ==
        sizeof(char);

#else //SELF_REFERENCE_IN_MEMBER_INITIALIZATION

    //The AIX xlC compiler does not like these 2 functions being in the inner class.
    //It says "The incomplete type "test" must not be used as a qualifier.
    //It does not seem necessary anyway.
    static Big isBaseClass(...);
    static char isBaseClass(typename TypeTrait<T_base>::Pointer);

public:
    static const bool value =
        sizeof(isBaseClass(reinterpret_cast<typename TypeTrait<T_derived>::Pointer>(0))) == sizeof(char);

#endif //SELF_REFERENCE_IN_MEMBER_INITIALIZATION
};

template<typename T_base>
struct TypeIsBaseOf<T_base, T_base>
{
    static const bool value = true;
};

#endif

// Specified by TR1 [4.7.1]
template<typename T_type>
struct TypeRemoveConst
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemoveConst<T_type const>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemoveVolatile
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemoveVolatile<T_type volatile>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemoveConstVolatile
{
    typedef typename TypeRemoveConst<typename TypeRemoveVolatile<T_type>::Type>::Type Type;
};

// Specified by TR1 [4.7.2] Reference modifications.
template<typename T_type>
struct TypeRemoveReference
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemoveReference<T_type &>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeAddReference
{
    typedef T_type &Type;
};

template<typename T_type>
struct TypeAddReference<T_type &>
{
    typedef T_type &Type;
};

// Specified by TR1 [4.7.4] Pointer modifications.
template<typename T_type>
struct TypeRemovePointer
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemovePointer<T_type *>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemovePointer<T_type *const>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemovePointer<T_type *volatile>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeRemovePointer<T_type *const volatile>
{
    typedef T_type Type;
};

template<typename T_type>
struct TypeAddConst
{
    typedef T_type const Type;
};

template<typename T_type>
struct TypeAddVolatile
{
    typedef T_type volatile Type;
};

template<typename T_type>
struct TypeAddConstVolatile
{
    typedef typename TypeAddConst<typename TypeAddVolatile<T_type>::Type>::Type Type;
};

template<typename T_type>
struct TypeAddPointer
{
    typedef typename TypeRemoveReference<T_type>::Type *Type;
};


PCTK_END_NAMESPACE

#endif //_PCTKTYPETRAITS_H
