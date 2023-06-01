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

#include <pctkAtomicInt.h>

#include <atomic>

PCTK_BEGIN_NAMESPACE

class AtomicIntPrivate
{
public:
    explicit AtomicIntPrivate(AtomicInt *q);
    virtual ~AtomicIntPrivate();

    AtomicInt *const q_ptr;


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

}

AtomicInt::AtomicInt(const AtomicInt &other) PCTK_NOEXCEPT
    : dd_ptr(new AtomicIntPrivate(this))
{

}
AtomicInt::~AtomicInt()
{
    delete dd_ptr;
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

int AtomicInt::loadAcquire() const PCTK_NOEXCEPT
{
    PCTK_D(const AtomicInt);

}

void AtomicInt::store(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);

}

void AtomicInt::storeRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);

}

bool AtomicInt::testAndSetRelaxed(int expected, int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::testAndSetAcquire(int expected, int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::testAndSetRelease(int expected, int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

bool AtomicInt::testAndSetOrdered(int expected, int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndStoreRelaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndStoreAcquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndStoreRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndStoreOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAddRelaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAddAcquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAddRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAddOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndSubRelaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndSubAcquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndSubRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndSubOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndOrRelaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndOrAcquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndOrRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndOrOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAndRelaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAndAcquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAndRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndAndOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndXorRelaxed(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndXorAcquire(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndXorRelease(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

int AtomicInt::fetchAndXorOrdered(int desired) PCTK_NOEXCEPT
{
    PCTK_D(AtomicInt);
}

PCTK_END_NAMESPACE