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

#ifndef _PCTKATOMICINT_H
#define _PCTKATOMICINT_H

#include <pctkGlobal.h>

PCTK_BEGIN_NAMESPACE

class AtomicIntPrivate;
class PCTK_CORE_API AtomicInt
{
public:
    AtomicInt() PCTK_NOEXCEPT;
    explicit AtomicInt(int val) PCTK_NOEXCEPT;
    AtomicInt(const AtomicInt &other) PCTK_NOEXCEPT;
    virtual ~AtomicInt() { delete dd_ptr; }

    /**
     * @brief operator int
     */
    operator int() const PCTK_NOEXCEPT { return this->load(); }

    /**
     * @brief operator =
     * @param val
     * @return
     */
    AtomicInt &operator=(int val) PCTK_NOEXCEPT
    {
        this->store(val);
        return *this;
    }

    /**
     * @brief operator =
     * @param other
     * @return
     */
    inline AtomicInt &operator=(const AtomicInt &other) PCTK_NOEXCEPT
    {
        if (other != *this) {
            this->storeRelease(other.loadAcquire());
        }
        return *this;
    }

    /**
     * @brief operator ==
     * @param other
     * @return
     */
    bool operator==(const AtomicInt &other) const PCTK_NOEXCEPT { return this->loadAcquire() == other.loadAcquire(); }

    /**
     * @brief operator !=
     * @param other
     * @return
     */
    bool operator!=(const AtomicInt &other) const PCTK_NOEXCEPT { return this->loadAcquire() != other.loadAcquire(); }

    int operator++() PCTK_NOEXCEPT { return this->fetchAndAddOrdered(1) + 1; }

    int operator++(int) PCTK_NOEXCEPT { return this->fetchAndAddOrdered(1); }

    int operator--() PCTK_NOEXCEPT { return this->fetchAndSubOrdered(1) - 1; }

    int operator--(int) PCTK_NOEXCEPT { return this->fetchAndSubOrdered(1); }

    int operator+=(int value) PCTK_NOEXCEPT { return this->fetchAndAddOrdered(value) + value; }

    int operator-=(int value) PCTK_NOEXCEPT { return this->fetchAndSubOrdered(value) - value; }

    int operator|=(int value) PCTK_NOEXCEPT { return this->fetchAndOrOrdered(value) | value; }

    int operator&=(int value) PCTK_NOEXCEPT { return this->fetchAndAndOrdered(value) & value; }

    int operator^=(int value) PCTK_NOEXCEPT { return this->fetchAndXorOrdered(value) ^ value; }

    /**
     * @brief ref
     * @return
     */
    bool ref() PCTK_NOEXCEPT;

    /**
     * @brief deref
     * @return
     */
    bool deref() PCTK_NOEXCEPT;

    /**
     * @brief load
     * @return
     */
    int load() const PCTK_NOEXCEPT;

    /**
     * @brief loadAcquire
     * @return
     */
    int loadAcquire() const PCTK_NOEXCEPT;

    /**
     * @brief store
     * @param desired
     */
    void store(int desired) PCTK_NOEXCEPT;

    /**
     * @brief storeRelease
     * @param desired
     */
    void storeRelease(int desired) PCTK_NOEXCEPT;

    /**
     * @brief testAndSetRelaxed
     * @param expected
     * @param desired
     * @return
     */
    bool testAndSetRelaxed(int expected, int desired) PCTK_NOEXCEPT;

    /**
     * @brief testAndSetAcquire
     * @param expected
     * @param desired
     * @return
     */
    bool testAndSetAcquire(int expected, int desired) PCTK_NOEXCEPT;

    /**
     * @brief testAndSetRelease
     * @param expected
     * @param desired
     * @return
     */
    bool testAndSetRelease(int expected, int desired) PCTK_NOEXCEPT;

    /**
     * @brief testAndSetOrdered
     * @param expected
     * @param desired
     * @return
     */
    bool testAndSetOrdered(int expected, int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndStoreRelaxed
     * @param desired
     * @return
     */
    int fetchAndStoreRelaxed(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndStoreAcquire
     * @param desired
     * @return
     */
    int fetchAndStoreAcquire(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndStoreRelease
     * @param desired
     * @return
     */
    int fetchAndStoreRelease(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndStoreOrdered
     * @param desired
     * @return
     */
    int fetchAndStoreOrdered(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddRelaxed
     * @param desired
     * @return
     */
    int fetchAndAddRelaxed(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddAcquire
     * @param desired
     * @return
     */
    int fetchAndAddAcquire(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddRelease
     * @param desired
     * @return
     */
    int fetchAndAddRelease(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddOrdered
     * @param desired
     * @return
     */
    int fetchAndAddOrdered(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubRelaxed
     * @param desired
     * @return
     */
    int fetchAndSubRelaxed(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubAcquire
     * @param desired
     * @return
     */
    int fetchAndSubAcquire(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubRelease
     * @param desired
     * @return
     */
    int fetchAndSubRelease(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubOrdered
     * @param desired
     * @return
     */
    int fetchAndSubOrdered(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrRelaxed
     * @param desired
     * @return
     */
    int fetchAndOrRelaxed(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrAcquire
     * @param desired
     * @return
     */
    int fetchAndOrAcquire(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrRelease
     * @param desired
     * @return
     */
    int fetchAndOrRelease(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrOrdered
     * @param desired
     * @return
     */
    int fetchAndOrOrdered(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetch_and_and_relaxed
     * @param desired
     * @return
     */

    int fetch_and_and_relaxed(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetch_and_and_acquire
     * @param desired
     * @return
     */
    int fetch_and_and_acquire(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetch_and_and_release
     * @param desired
     * @return
     */
    int fetch_and_and_release(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAndOrdered
     * @param desired
     * @return
     */
    int fetchAndAndOrdered(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetch_and_xor_relaxed
     * @param desired
     * @return
     */
    int fetch_and_xor_relaxed(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetch_and_xor_acquire
     * @param desired
     * @return
     */
    int fetch_and_xor_acquire(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetch_and_xor_release
     * @param desired
     * @return
     */
    int fetch_and_xor_release(int desired) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndXorOrdered
     * @param desired
     * @return
     */
    int fetchAndXorOrdered(int desired) PCTK_NOEXCEPT;

protected:
    AtomicIntPrivate *dd_ptr;

private:
    PCTK_DECL_PRIVATE_D(dd_ptr, AtomicInt)
};

PCTK_END_NAMESPACE

#endif //_PCTKATOMICINT_H
