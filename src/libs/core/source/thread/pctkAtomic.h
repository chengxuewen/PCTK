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

#ifndef _PCTKATOMIC_H
#define _PCTKATOMIC_H

#include <pctkGlobal.h>

PCTK_BEGIN_NAMESPACE

class AtomicIntPrivate;
class PCTK_CORE_API AtomicInt
{
public:
    AtomicInt() PCTK_NOEXCEPT;
    explicit AtomicInt(int val) PCTK_NOEXCEPT;
    AtomicInt(const AtomicInt &other) PCTK_NOEXCEPT;
    virtual ~AtomicInt();

    operator int() const PCTK_NOEXCEPT { return this->load(); }

    AtomicInt &operator=(int val) PCTK_NOEXCEPT
    {
        this->storeRelease(val);
        return *this;
    }

    inline AtomicInt &operator=(const AtomicInt &other) PCTK_NOEXCEPT
    {
        this->storeRelease(other.loadAcquire());
        return *this;
    }

    bool operator==(const AtomicInt &other) const PCTK_NOEXCEPT { return this->loadAcquire() == other.loadAcquire(); }

    bool operator!=(const AtomicInt &other) const PCTK_NOEXCEPT { return this->loadAcquire() != other.loadAcquire(); }

    int operator++() PCTK_NOEXCEPT { return this->fetchAndAddOrdered(1) + 1; }

    int operator++(int) PCTK_NOEXCEPT { return this->fetchAndAddOrdered(1); }

    int operator--() PCTK_NOEXCEPT { return this->fetchAndSubOrdered(1) - 1; }

    int operator--(int) PCTK_NOEXCEPT { return this->fetchAndSubOrdered(1); }

    int operator+=(int arg) PCTK_NOEXCEPT { return this->fetchAndAddOrdered(arg) + arg; }

    int operator-=(int arg) PCTK_NOEXCEPT { return this->fetchAndSubOrdered(arg) - arg; }

    int operator|=(int arg) PCTK_NOEXCEPT { return this->fetchAndOrOrdered(arg) | arg; }

    int operator&=(int arg) PCTK_NOEXCEPT { return this->fetchAndAndOrdered(arg) & arg; }

    int operator^=(int arg) PCTK_NOEXCEPT { return this->fetchAndXorOrdered(arg) ^ arg; }

    bool ref() PCTK_NOEXCEPT;

    bool deref() PCTK_NOEXCEPT;

    int load() const PCTK_NOEXCEPT;

    int loadAcquire() const PCTK_NOEXCEPT;

    void store(int desired) PCTK_NOEXCEPT;

    void storeRelease(int desired) PCTK_NOEXCEPT;

    bool testAndSetRelaxed(int expected, int desired) PCTK_NOEXCEPT;

    bool testAndSetAcquire(int expected, int desired) PCTK_NOEXCEPT;

    bool testAndSetRelease(int expected, int desired) PCTK_NOEXCEPT;

    bool testAndSetOrdered(int expected, int desired) PCTK_NOEXCEPT;

    int fetchAndStoreRelaxed(int desired) PCTK_NOEXCEPT;

    int fetchAndStoreAcquire(int desired) PCTK_NOEXCEPT;

    int fetchAndStoreRelease(int desired) PCTK_NOEXCEPT;

    int fetchAndStoreOrdered(int desired) PCTK_NOEXCEPT;

    int fetchAndAddRelaxed(int arg) PCTK_NOEXCEPT;

    int fetchAndAddAcquire(int arg) PCTK_NOEXCEPT;

    int fetchAndAddRelease(int arg) PCTK_NOEXCEPT;

    int fetchAndAddOrdered(int arg) PCTK_NOEXCEPT;

    int fetchAndSubRelaxed(int arg) PCTK_NOEXCEPT;

    int fetchAndSubAcquire(int arg) PCTK_NOEXCEPT;

    int fetchAndSubRelease(int arg) PCTK_NOEXCEPT;

    int fetchAndSubOrdered(int arg) PCTK_NOEXCEPT;

    int fetchAndOrRelaxed(int arg) PCTK_NOEXCEPT;

    int fetchAndOrAcquire(int arg) PCTK_NOEXCEPT;

    int fetchAndOrRelease(int arg) PCTK_NOEXCEPT;

    int fetchAndOrOrdered(int arg) PCTK_NOEXCEPT;

    int fetchAndAndRelaxed(int arg) PCTK_NOEXCEPT;

    int fetchAndAndAcquire(int arg) PCTK_NOEXCEPT;

    int fetchAndAndRelease(int arg) PCTK_NOEXCEPT;

    int fetchAndAndOrdered(int arg) PCTK_NOEXCEPT;

    int fetchAndXorRelaxed(int arg) PCTK_NOEXCEPT;

    int fetchAndXorAcquire(int arg) PCTK_NOEXCEPT;

    int fetchAndXorRelease(int arg) PCTK_NOEXCEPT;

    int fetchAndXorOrdered(int arg) PCTK_NOEXCEPT;

protected:
    AtomicIntPrivate *dd_ptr;

private:
    PCTK_DECL_PRIVATE_D(dd_ptr, AtomicInt)
};

class AtomicPointerBasePrivate;
class PCTK_CORE_API AtomicPointerBase
{
public:
    typedef pctk_pointer_t Pointer;
    typedef pctk_ptrdiff_t Ptrdiff;

protected:
    AtomicPointerBase() PCTK_NOEXCEPT;
    explicit AtomicPointerBase(Pointer val) PCTK_NOEXCEPT;
    AtomicPointerBase(const AtomicPointerBase &other) PCTK_NOEXCEPT;
    virtual ~AtomicPointerBase();

    Pointer load() const PCTK_NOEXCEPT;

    Pointer loadAcquire() const PCTK_NOEXCEPT;

    void store(Pointer desired) PCTK_NOEXCEPT;

    void storeRelease(Pointer desired) PCTK_NOEXCEPT;

    bool testAndSetRelaxed(Pointer expected, Pointer desired) PCTK_NOEXCEPT;

    bool testAndSetAcquire(Pointer expected, Pointer desired) PCTK_NOEXCEPT;

    bool testAndSetRelease(Pointer expected, Pointer desired) PCTK_NOEXCEPT;

    bool testAndSetOrdered(Pointer expected, Pointer desired) PCTK_NOEXCEPT;

    Pointer fetchAndStoreRelaxed(Pointer desired) PCTK_NOEXCEPT;

    Pointer fetchAndStoreAcquire(Pointer desired) PCTK_NOEXCEPT;

    Pointer fetchAndStoreRelease(Pointer desired) PCTK_NOEXCEPT;

    Pointer fetchAndStoreOrdered(Pointer desired) PCTK_NOEXCEPT;

    Pointer fetchAndAddRelaxed(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndAddAcquire(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndAddRelease(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndAddOrdered(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndSubRelaxed(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndSubAcquire(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndSubRelease(Ptrdiff arg) PCTK_NOEXCEPT;

    Pointer fetchAndSubOrdered(Ptrdiff arg) PCTK_NOEXCEPT;

    AtomicPointerBasePrivate *dd_ptr;

private:
    PCTK_DECL_PRIVATE_D(dd_ptr, AtomicPointerBase)
};

template<typename T>
class PCTK_CORE_API AtomicPointer : public AtomicPointerBase
{
public:
    typedef AtomicPointerBase::Ptrdiff Ptrdiff;

    AtomicPointer() PCTK_NOEXCEPT {}
    explicit AtomicPointer(T *val) PCTK_NOEXCEPT: AtomicPointerBase(val) {}
    AtomicPointer(const AtomicPointer &other) PCTK_NOEXCEPT: AtomicPointerBase(other.loadAcquire()) {}
    ~AtomicPointer() PCTK_OVERRIDE {}

    AtomicPointer &operator=(T *val) PCTK_NOEXCEPT
    {
        this->storeRelease(val);
        return *this;
    }

    inline AtomicPointer &operator=(const AtomicPointer &other) PCTK_NOEXCEPT
    {
        this->storeRelease(other.loadAcquire());
        return *this;
    }

    T *load() const PCTK_NOEXCEPT { return (T *) AtomicPointerBase::load(); }

    T *loadAcquire() const PCTK_NOEXCEPT { return (T *) AtomicPointerBase::loadAcquire(); }

    void store(T *desired) PCTK_NOEXCEPT { AtomicPointerBase::store(desired); }

    void storeRelease(T *desired) PCTK_NOEXCEPT { AtomicPointerBase::storeRelease(desired); }

    bool testAndSetRelaxed(T *expected, T *desired) PCTK_NOEXCEPT
    {
        return AtomicPointerBase::testAndSetRelaxed(expected, desired);
    }

    bool testAndSetAcquire(T *expected, T *desired) PCTK_NOEXCEPT
    {
        return AtomicPointerBase::testAndSetAcquire(expected, desired);
    }

    bool testAndSetRelease(T *expected, T *desired) PCTK_NOEXCEPT
    {
        return AtomicPointerBase::testAndSetRelease(expected, desired);
    }

    bool testAndSetOrdered(T *expected, T *desired) PCTK_NOEXCEPT
    {
        return AtomicPointerBase::testAndSetOrdered(expected, desired);
    }

    T *fetchAndStoreRelaxed(T *desired) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndStoreRelaxed(desired); }

    T *fetchAndStoreAcquire(T *desired) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndStoreAcquire(desired); }

    T *fetchAndStoreRelease(T *desired) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndStoreRelease(desired); }

    T *fetchAndStoreOrdered(T *desired) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndStoreOrdered(desired); }

    T *fetchAndAddRelaxed(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndAddRelaxed(arg); }

    T *fetchAndAddAcquire(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndAddAcquire(arg); }

    T *fetchAndAddRelease(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndAddRelease(arg); }

    T *fetchAndAddOrdered(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndAddOrdered(arg); }

    T *fetchAndSubRelaxed(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndSubRelaxed(arg); }

    T *fetchAndSubAcquire(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndSubAcquire(arg); }

    T *fetchAndSubRelease(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndSubRelease(arg); }

    T *fetchAndSubOrdered(Ptrdiff arg) PCTK_NOEXCEPT { return (T *) AtomicPointerBase::fetchAndSubOrdered(arg); }

};

PCTK_END_NAMESPACE

#endif //_PCTKATOMIC_H
