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
    virtual ~AtomicInt();

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
     * @param arg
     * @return
     */
    int fetchAndAddRelaxed(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddAcquire
     * @param arg
     * @return
     */
    int fetchAndAddAcquire(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddRelease
     * @param arg
     * @return
     */
    int fetchAndAddRelease(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAddOrdered
     * @param arg
     * @return
     */
    int fetchAndAddOrdered(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubRelaxed
     * @param arg
     * @return
     */
    int fetchAndSubRelaxed(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubAcquire
     * @param arg
     * @return
     */
    int fetchAndSubAcquire(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubRelease
     * @param arg
     * @return
     */
    int fetchAndSubRelease(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndSubOrdered
     * @param arg
     * @return
     */
    int fetchAndSubOrdered(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrRelaxed
     * @param arg
     * @return
     */
    int fetchAndOrRelaxed(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrAcquire
     * @param arg
     * @return
     */
    int fetchAndOrAcquire(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrRelease
     * @param arg
     * @return
     */
    int fetchAndOrRelease(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndOrOrdered
     * @param arg
     * @return
     */
    int fetchAndOrOrdered(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAndRelaxed
     * @param arg
     * @return
     */

    int fetchAndAndRelaxed(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAndAcquire
     * @param arg
     * @return
     */
    int fetchAndAndAcquire(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAndRelease
     * @param arg
     * @return
     */
    int fetchAndAndRelease(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndAndOrdered
     * @param arg
     * @return
     */
    int fetchAndAndOrdered(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndXorRelaxed
     * @param arg
     * @return
     */
    int fetchAndXorRelaxed(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndXorAcquire
     * @param arg
     * @return
     */
    int fetchAndXorAcquire(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndXorRelease
     * @param arg
     * @return
     */
    int fetchAndXorRelease(int arg) PCTK_NOEXCEPT;

    /**
     * @brief fetchAndXorOrdered
     * @param arg
     * @return
     */
    int fetchAndXorOrdered(int arg) PCTK_NOEXCEPT;

protected:
    AtomicIntPrivate *dd_ptr;

private:
    PCTK_DECL_PRIVATE_D(dd_ptr, AtomicInt)
};

PCTK_END_NAMESPACE

#endif //_PCTKATOMICINT_H
