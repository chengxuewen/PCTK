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

#include <private/pctkAtomicInt_p.h>

PCTK_BEGIN_NAMESPACE

class AtomicIntCxx11 : public AtomicIntPrivate
{
public:
    explicit AtomicIntCxx11(AtomicInt *q);
    ~AtomicIntCxx11();

private:
    PCTK_DECL_PUBLIC(AtomicInt)
    PCTK_DISABLE_COPY_MOVE(AtomicIntCxx11)
};

AtomicIntCxx11::AtomicIntCxx11(AtomicInt *q) : AtomicIntPrivate(q)
{

}

AtomicIntCxx11::~AtomicIntCxx11()
{

}

AtomicInt::AtomicInt() PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntCxx11(this))
{
}

AtomicInt::AtomicInt(int val) PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntCxx11(this))
{
    this->storeRelease(val);
}

AtomicInt::AtomicInt(const AtomicInt &other) PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntCxx11(this))
{
    this->storeRelease(other.loadAcquire());
}

bool AtomicInt::ref() PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::deref() PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::load() const PCTK_NOEXCEPT
{
    PCTK_D(const AtomicInt);
}

int AtomicInt::load_acquire() const PCTK_NOEXCEPT
{
    PCTK_D(const AtomicInt);
}

void AtomicInt::store(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

void AtomicInt::store_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::test_and_set_relaxed(int expected,
                                     int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::test_and_set_acquire(int expected,
                                     int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::test_and_set_release(int expected,
                                     int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::test_and_set_ordered(int expected,
                                     int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_store_relaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_store_acquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_store_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_store_ordered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_add_relaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_add_acquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_add_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAddOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_sub_relaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_sub_acquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_sub_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndSubOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_or_relaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_or_acquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_or_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndOrOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_and_relaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_and_acquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_and_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAndOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_xor_relaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_xor_acquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetch_and_xor_release(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndXorOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

PCTK_END_NAMESPACE