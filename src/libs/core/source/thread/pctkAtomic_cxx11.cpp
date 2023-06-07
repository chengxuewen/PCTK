/***********************************************************************************************************************
**
** Library: PCTK
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

#include <pctkAtomic.h>

#include <atomic>

PCTK_BEGIN_NAMESPACE

class AtomicIntPrivate
{
public:
    explicit AtomicIntPrivate(AtomicInt *q);
    virtual ~AtomicIntPrivate();

    AtomicInt *const q_ptr;
    std::atomic_int m_value;

private:
    PCTK_DECL_PUBLIC(AtomicInt)
    PCTK_DISABLE_COPY_MOVE(AtomicIntPrivate)
};

AtomicIntPrivate::AtomicIntPrivate(AtomicInt *q) : q_ptr(q), m_value(0)
{
}

AtomicIntPrivate::~AtomicIntPrivate()
{
}

AtomicInt::AtomicInt() PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntPrivate(this))
{
}

AtomicInt::AtomicInt(int val) PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntPrivate(this))
{
    dd_ptr->m_value.store(val, std::memory_order_release);
}

AtomicInt::AtomicInt(const AtomicInt &other) PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntPrivate(this))
{
    dd_ptr->m_value.store(other.dd_ptr->m_value.load(std::memory_order_acquire), std::memory_order_release);
}
AtomicInt::~AtomicInt()
{
    delete dd_ptr;
}

bool AtomicInt::ref() PCTK_NOEXCEPT
{
    return dd_ptr->m_value.fetch_add(1, std::memory_order_acq_rel) != -1;
}

bool AtomicInt::deref() PCTK_NOEXCEPT
{
    return dd_ptr->m_value.fetch_sub(1, std::memory_order_acq_rel) != 1;
}

int AtomicInt::load() const PCTK_NOEXCEPT
{
    return dd_ptr->m_value.load(std::memory_order_relaxed);
}

int AtomicInt::loadAcquire() const PCTK_NOEXCEPT
{
    return dd_ptr->m_value.load(std::memory_order_acquire);
}

void AtomicInt::store(int desired) PCTK_NOEXCEPT
{
    dd_ptr->m_value.store(desired, std::memory_order_relaxed);
}

void AtomicInt::storeRelease(int desired) PCTK_NOEXCEPT
{
    dd_ptr->m_value.store(desired, std::memory_order_release);
}

bool AtomicInt::testAndSetRelaxed(int expected, int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_relaxed,
                                                   std::memory_order_relaxed);
}

bool AtomicInt::testAndSetAcquire(int expected, int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_acquire,
                                                   std::memory_order_acquire);
}

bool AtomicInt::testAndSetRelease(int expected, int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_release,
                                                   std::memory_order_relaxed);
}

bool AtomicInt::testAndSetOrdered(int expected, int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_acq_rel,
                                                   std::memory_order_acquire);
}

int AtomicInt::fetchAndStoreRelaxed(int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_relaxed);
}

int AtomicInt::fetchAndStoreAcquire(int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_acquire);
}

int AtomicInt::fetchAndStoreRelease(int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_release);
}

int AtomicInt::fetchAndStoreOrdered(int desired) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_acq_rel);
}

int AtomicInt::fetchAndAddRelaxed(int arg) PCTK_NOEXCEPT
{
    return dd_ptr->m_value.fetch_add(arg, std::memory_order_relaxed);
}

int AtomicInt::fetchAndAddAcquire(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_add(arg, std::memory_order_acquire);
}

int AtomicInt::fetchAndAddRelease(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_add(arg, std::memory_order_release);
}

int AtomicInt::fetchAndAddOrdered(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_add(arg, std::memory_order_acq_rel);
}

int AtomicInt::fetchAndSubRelaxed(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_sub(arg, std::memory_order_relaxed);
}

int AtomicInt::fetchAndSubAcquire(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_sub(arg, std::memory_order_acquire);
}

int AtomicInt::fetchAndSubRelease(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_sub(arg, std::memory_order_release);
}

int AtomicInt::fetchAndSubOrdered(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_sub(arg, std::memory_order_acq_rel);
}

int AtomicInt::fetchAndOrRelaxed(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_or(arg, std::memory_order_relaxed);
}

int AtomicInt::fetchAndOrAcquire(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_or(arg, std::memory_order_acquire);
}

int AtomicInt::fetchAndOrRelease(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_or(arg, std::memory_order_release);
}

int AtomicInt::fetchAndOrOrdered(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_or(arg, std::memory_order_acq_rel);
}

int AtomicInt::fetchAndAndRelaxed(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_and(arg, std::memory_order_relaxed);
}

int AtomicInt::fetchAndAndAcquire(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_and(arg, std::memory_order_acquire);
}

int AtomicInt::fetchAndAndRelease(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_and(arg, std::memory_order_release);
}

int AtomicInt::fetchAndAndOrdered(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_and(arg, std::memory_order_acq_rel);
}

int AtomicInt::fetchAndXorRelaxed(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_xor(arg, std::memory_order_relaxed);
}

int AtomicInt::fetchAndXorAcquire(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_xor(arg, std::memory_order_acquire);
}

int AtomicInt::fetchAndXorRelease(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_xor(arg, std::memory_order_release);
}

int AtomicInt::fetchAndXorOrdered(int arg) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
    return d->m_value.fetch_xor(arg, std::memory_order_acq_rel);
}

class AtomicPointerBasePrivate
{
public:
    explicit AtomicPointerBasePrivate(AtomicPointerBase *q);
    virtual ~AtomicPointerBasePrivate();

    AtomicPointerBase *const q_ptr;

    std::atomic<AtomicPointerBase::Pointer> m_value;

private:
    PCTK_DECL_PUBLIC(AtomicPointerBase)
    PCTK_DISABLE_COPY_MOVE(AtomicPointerBasePrivate)
};

AtomicPointerBasePrivate::AtomicPointerBasePrivate(AtomicPointerBase *q) : q_ptr(q), m_value(PCTK_NULLPTR)
{
}

AtomicPointerBasePrivate::~AtomicPointerBasePrivate()
{
}

AtomicPointerBase::AtomicPointerBase() : dd_ptr(new AtomicPointerBasePrivate(this))
{
}

AtomicPointerBase::AtomicPointerBase(AtomicPointerBase::Pointer val) : dd_ptr(new AtomicPointerBasePrivate(this))
{
    dd_ptr->m_value.store(val, std::memory_order_release);
}

AtomicPointerBase::AtomicPointerBase(const AtomicPointerBase &other) : dd_ptr(new AtomicPointerBasePrivate(this))
{
    dd_ptr->m_value.store(other.dd_ptr->m_value.load(std::memory_order_acquire), std::memory_order_release);
}

AtomicPointerBase::~AtomicPointerBase()
{
    delete dd_ptr;
}

AtomicPointerBase::Pointer AtomicPointerBase::load() const
{
    return dd_ptr->m_value.load(std::memory_order_relaxed);
}

AtomicPointerBase::Pointer AtomicPointerBase::loadAcquire() const
{
    return dd_ptr->m_value.load(std::memory_order_acquire);
}

void AtomicPointerBase::store(AtomicPointerBase::Pointer desired)
{
    dd_ptr->m_value.store(desired, std::memory_order_relaxed);
}

void AtomicPointerBase::storeRelease(AtomicPointerBase::Pointer desired)
{
    dd_ptr->m_value.store(desired, std::memory_order_release);
}

bool AtomicPointerBase::testAndSetRelaxed(AtomicPointerBase::Pointer expected, AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_relaxed,
                                                   std::memory_order_relaxed);
}

bool AtomicPointerBase::testAndSetAcquire(AtomicPointerBase::Pointer expected, AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_acquire,
                                                   std::memory_order_acquire);
}

bool AtomicPointerBase::testAndSetRelease(AtomicPointerBase::Pointer expected, AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_release,
                                                   std::memory_order_relaxed);
}

bool AtomicPointerBase::testAndSetOrdered(AtomicPointerBase::Pointer expected, AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.compare_exchange_strong(expected,
                                                   desired,
                                                   std::memory_order_acq_rel,
                                                   std::memory_order_acquire);
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndStoreRelaxed(AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_relaxed);
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndStoreAcquire(AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_acquire);
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndStoreRelease(AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_release);
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndStoreOrdered(AtomicPointerBase::Pointer desired)
{
    return dd_ptr->m_value.exchange(desired, std::memory_order_acq_rel);
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndAddRelaxed(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_relaxed);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected + arg), std::memory_order_relaxed);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndAddAcquire(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_acquire);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected + arg), std::memory_order_relaxed);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndAddRelease(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_relaxed);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected + arg), std::memory_order_release);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndAddOrdered(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_acquire);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected + arg), std::memory_order_release);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndSubRelaxed(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_relaxed);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected - arg), std::memory_order_relaxed);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndSubAcquire(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_acquire);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected - arg), std::memory_order_relaxed);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndSubRelease(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_relaxed);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected - arg), std::memory_order_release);
    return expected;
}

AtomicPointerBase::Pointer AtomicPointerBase::fetchAndSubOrdered(AtomicPointerBase::Ptrdiff arg)
{
    Pointer expected = dd_ptr->m_value.load(std::memory_order_acquire);
    dd_ptr->m_value.store((Pointer) ((Ptrdiff) expected - arg), std::memory_order_release);
    return expected;
}

PCTK_END_NAMESPACE