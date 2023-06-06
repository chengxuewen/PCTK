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

#ifndef _PCTKTYPEINFO_H
#define _PCTKTYPEINFO_H

#include <pctkTypeTraits.h>

PCTK_BEGIN_NAMESPACE

/**
 * @addtogroup core
 * @{
 * @addtogroup TypeInfo
 * @brief type trait functionality
 * @{
 * @details
 *  test ----
 *
 */

/*
  The catch-all template.
*/

template<typename T>
class TypeInfo
{
public:
    enum
    {
        isPointer = false,
        isIntegral = TypeIsIntegral<T>::value,
        isComplex = true,
        isStatic = true,
        isRelocatable = PCTK_IS_ENUM(T),
        isLarge = (sizeof(T) > sizeof(void *)),
        isDummy = false, //###TODO: remove
        sizeOf = sizeof(T)
    };
};

template<>
class TypeInfo<void>
{
public:
    enum
    {
        isPointer = false,
        isIntegral = false,
        isComplex = false,
        isStatic = false,
        isRelocatable = false,
        isLarge = false,
        isDummy = false,
        sizeOf = 0
    };
};

template<typename T>
class TypeInfo<T *>
{
public:
    enum
    {
        isPointer = true,
        isIntegral = false,
        isComplex = false,
        isStatic = false,
        isRelocatable = true,
        isLarge = false,
        isDummy = false,
        sizeOf = sizeof(T *)
    };
};

/**
 * @brief TypeInfoQuery is used to query the values of a given TypeInfo<T>
 * We use it because there may be some TypeInfo<T> specializations in user code that don't provide certain flags They are:
 * @li isRelocatable: defaults to !isStatic
 * @tparam T
 */
// apply defaults for a generic TypeInfo<T> that didn't provide the new values
template<typename T, typename = void>
struct TypeInfoQuery : public TypeInfo<T>
{
    enum { isRelocatable = !TypeInfo<T>::isStatic };
};

// if TypeInfo<T>::isRelocatable exists, use it
template<typename T>
struct TypeInfoQuery<T, typename TypeEnableIf<TypeInfo<T>::isRelocatable || true>::Type> : public TypeInfo<T>
{
};

/**
 * @brief TypeInfoMerger merges the TypeInfo flags of T1, T2... and presents them as a TypeInfo<T> would do.
 * Let's assume that we have a simple set of structs:
 * To create a proper TypeInfo specialization for A struct, we have to check all sub-components; B, C and D, then take
 * the lowest common denominator and call PCTK_DECL_TYPEINFO with the resulting flags. An easier and less fragile approach
 * is to use TypeInfoMerger, which does that automatically. So struct A would have the following TypeInfo definition:
 */
template<class T, class T1, class T2 = T1, class T3 = T1, class T4 = T1>
class TypeInfoMerger
{
public:
    enum
    {
        isComplex = TypeInfoQuery<T1>::isComplex || TypeInfoQuery<T2>::isComplex || TypeInfoQuery<T3>::isComplex ||
                    TypeInfoQuery<T4>::isComplex,
        isStatic = TypeInfoQuery<T1>::isStatic || TypeInfoQuery<T2>::isStatic || TypeInfoQuery<T3>::isStatic ||
                   TypeInfoQuery<T4>::isStatic,
        isRelocatable =
        TypeInfoQuery<T1>::isRelocatable && TypeInfoQuery<T2>::isRelocatable && TypeInfoQuery<T3>::isRelocatable &&
        TypeInfoQuery<T4>::isRelocatable,
        isLarge = sizeof(T) > sizeof(void *),
        isPointer = false,
        isIntegral = false,
        isDummy = false,
        sizeOf = sizeof(T)
    };
};

#define PCTK_DECL_MOVABLE_CONTAINER(CONTAINER) \
template <typename T> class CONTAINER; \
template <typename T> \
class TypeInfo< CONTAINER<T> > \
{ \
public: \
    enum { \
        isPointer = false, \
        isIntegral = false, \
        isComplex = true, \
        isRelocatable = true, \
        isStatic = false, \
        isLarge = (sizeof(CONTAINER<T>) > sizeof(void*)), \
        isDummy = false, \
        sizeOf = sizeof(CONTAINER<T>) \
    }; \
}

PCTK_DECL_MOVABLE_CONTAINER(QList);
PCTK_DECL_MOVABLE_CONTAINER(QVector);
PCTK_DECL_MOVABLE_CONTAINER(QQueue);
PCTK_DECL_MOVABLE_CONTAINER(QStack);
PCTK_DECL_MOVABLE_CONTAINER(QLinkedList);
PCTK_DECL_MOVABLE_CONTAINER(QSet);

#undef PCTK_DECL_MOVABLE_CONTAINER

/**
 * @brief Specialize a specific type with:
 * PCTK_DECL_TYPEINFO(type, flags);
 *
 * where 'type' is the name of the type to specialize and 'flags' is logically-OR'ed combination of the flags below.
 */
enum
{ /* TYPEINFO flags */
    PCTK_TYPEINFO_COMPLEX = 0,
    PCTK_TYPEINFO_PRIMITIVE = 0x1,
    PCTK_TYPEINFO_STATIC = 0,
    PCTK_TYPEINFO_MOVABLE = 0x2, // ### TODO: merge movable and relocatable once QList no longer depends on it
    PCTK_TYPEINFO_DUMMY = 0x4,
    PCTK_TYPEINFO_RELOCATABLE = 0x8
};

#define PCTK_DECL_TYPEINFO_BODY(TYPE, FLAGS) \
class TypeInfo<TYPE > \
{ \
public: \
    enum { \
        isComplex = (((FLAGS) & PCTK_TYPEINFO_PRIMITIVE) == 0), \
        isStatic = (((FLAGS) & (PCTK_TYPEINFO_MOVABLE | PCTK_TYPEINFO_PRIMITIVE)) == 0), \
        isRelocatable = !isStatic || ((FLAGS) & PCTK_TYPEINFO_RELOCATABLE), \
        isLarge = (sizeof(TYPE)>sizeof(void*)), \
        isPointer = false, \
        isIntegral = TypeIsIntegral< TYPE >::value, \
        isDummy = (((FLAGS) & PCTK_TYPEINFO_DUMMY) != 0), \
        sizeOf = sizeof(TYPE) \
    }; \
    static inline const char *name() { return #TYPE; } \
}

#define PCTK_DECL_TYPEINFO(TYPE, FLAGS) \
template<> \
PCTK_DECL_TYPEINFO_BODY(TYPE, FLAGS)

/* Specialize TypeInfo for Flags<T> */
template<typename T>
class Flags;
template<typename T> PCTK_DECL_TYPEINFO_BODY(Flags<T>, PCTK_TYPEINFO_PRIMITIVE);

/*
   Specialize a shared type with:

     PCTK_DECL_SHARED(type)

   where 'type' is the name of the type to specialize.  NOTE: shared
   types must define a member-swap, and be defined in the same
   namespace as Qt for this to work.

   If the type was already released without PCTK_DECL_SHARED applied,
   _and_ without an explicit PCTK_DECL_TYPEINFO(type, PCTK_TYPEINFO_MOVABLE),
   then use PCTK_DECL_SHARED_NOT_MOVABLE_UNTIL_QT6(type) to mark the
   type shared (incl. swap()), without marking it movable (which
   would change the memory layout of QList, a BiC change.
*/
/**
 * @brief Specialize a shared type with: PCTK_DECL_SHARED(type)
 *
 * where 'type' is the name of the type to specialize.  NOTE: shared types must define a member-swap, and be defined in
 * the same namespace as pctk for this to work.
 */
#define PCTK_DECL_SHARED_IMPL(TYPE, FLAGS) \
PCTK_DECL_TYPEINFO(TYPE, FLAGS); \
inline void swap(TYPE &value1, TYPE &value2) PCTK_NOEXCEPT_EXPR(noexcept(value1.swap(value2))) \
{ value1.swap(value2); }
#define PCTK_DECL_SHARED(TYPE) PCTK_DECL_SHARED_IMPL(TYPE, PCTK_TYPEINFO_MOVABLE)

/*
   TypeInfo primitive specializations
*/
PCTK_DECL_TYPEINFO(bool, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(char, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(signed char, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(unsigned char, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(short, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(ushort, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(int, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(uint, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(long, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(unsigned long, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(pctk_int64_t, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(pctk_uint64_t, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(float, PCTK_TYPEINFO_PRIMITIVE);
PCTK_DECL_TYPEINFO(double, PCTK_TYPEINFO_PRIMITIVE);
#ifndef PCTK_OS_DARWIN
PCTK_DECL_TYPEINFO(long double, PCTK_TYPEINFO_PRIMITIVE);
#endif

/**
 * @}
 * @}
 */

PCTK_END_NAMESPACE

#endif //_PCTKTYPEINFO_H
