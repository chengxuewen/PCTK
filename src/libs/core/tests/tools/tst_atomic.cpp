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

#include <CppUTest/TestHarness.h>
#include <CppUTest/CommandLineTestRunner.h>

#include <iostream>
#include <string>
#include <sstream>
#include <vector>

TEST_GROUP(pctkAtomicTest) {};

TEST(pctkAtomicTest, AtomicIntConstruct)
{
    int values[] = {31337, 0, 1, -1, 2, -2, 3, -3, PCTK_INT_MAX, PCTK_INT_MIN + 1};
    pctk_size_t size = PCTK_ELEMENTS_NUM(values);
    for (pctk_size_t index = 0; index < size; ++index)
    {
        pctk::AtomicInt atomic(values[index]);
        CHECK_EQUAL(values[index], atomic.loadAcquire());
    }
}

TEST(pctkAtomicTest, AtomicIntCopy)
{
    int values[] = {31337, 0, 1, -1, 2, -2, 3, -3, PCTK_INT_MAX, PCTK_INT_MIN + 1};
    pctk_size_t size = PCTK_ELEMENTS_NUM(values);
    for (pctk_size_t index = 0; index < size; ++index)
    {
        pctk::AtomicInt atomic(values[index]);
        CHECK_EQUAL(values[index], atomic.loadAcquire());
        {
            pctk::AtomicInt copy = atomic;
            CHECK_EQUAL(values[index], copy.loadAcquire());
        }
    }
}

TEST(pctkAtomicTest, AtomicIntRef)
{
    typedef struct
    {
        int value;
        int result;
        int expected;
    } TestData;
    TestData values[] = {{0,  1, 1},
                         {-1, 0, 0},
                         {1,  1, 2}};
    pctk_size_t size = PCTK_ELEMENTS_NUM(values);
    for (pctk_size_t index = 0; index < size; ++index)
    {
        pctk::AtomicInt atomic(values[index].value);
        CHECK_EQUAL(values[index].result, atomic.ref());
        CHECK_EQUAL(values[index].expected, atomic.loadAcquire());
    }
}

TEST(pctkAtomicTest, AtomicIntDeref)
{
    typedef struct
    {
        int value;
        int result;
        int expected;
    } TestData;
    TestData values[] = {{0, 1, -1},
                         {1, 0, 0},
                         {2, 1, 1}};
    pctk_size_t size = PCTK_ELEMENTS_NUM(values);

    for (pctk_size_t index = 0; index < size; ++index)
    {
        pctk::AtomicInt atomic(values[index].value);
        CHECK_EQUAL(values[index].result, atomic.deref());
        CHECK_EQUAL(values[index].expected, atomic.load());
    }
}

TEST(pctkAtomicTest, AtomicIntTestSet)
{
    typedef struct
    {
        int value;
        int expected;
        int newval;
        bool result;
    } TestData;
    TestData values[] = {
        // these should succeed
        {0,  0,            0,                true},
        {0,  0,            1,                true},
        {0,  0,            -1,               true},
        {1,  1,            0,                true},
        {1,  1,            1,                true},
        {1,  1,            -1,               true},
        {-1, -1,           0,                true},
        {-1, -1,           1,                true},
        {-1, -1,           -1,               true},
        {INT_MIN + 1,      INT_MIN + 1, INT_MIN + 1, true},
        {INT_MIN + 1,      INT_MIN + 1,      1,  true},
        {INT_MIN + 1,      INT_MIN + 1,      -1, true},
        {INT_MAX, INT_MAX,          INT_MAX, true},
        {INT_MAX, INT_MAX, 1,                true},
        {INT_MAX, INT_MAX, -1,               true},

        // these should fail
        {0,  1,            ~1,               false},
        {0,  -1,           ~1,               false},
        {1,  0,            ~1,               false},
        {-1, 0,            ~1,               false},
        {1,  -1,           ~1,               false},
        {-1, 1,            ~1,               false},
        {INT_MIN + 1,      INT_MAX, ~1, false},
        {INT_MAX, INT_MIN + 1,      ~1, false},};
    pctk_size_t size = PCTK_ELEMENTS_NUM(values);
    for (pctk_size_t index = 0; index < size; ++index)
    {
        pctk::AtomicInt atomic(values[index].value);
        CHECK_EQUAL(values[index].result, atomic.testAndSetRelaxed(values[index].expected, values[index].newval));
        atomic = values[index].value;
        CHECK_EQUAL(values[index].result, atomic.testAndSetAcquire(values[index].expected, values[index].newval));
        atomic = values[index].value;
        CHECK_EQUAL(values[index].result, atomic.testAndSetRelease(values[index].expected, values[index].newval));
        atomic = values[index].value;
        CHECK_EQUAL(values[index].result, atomic.testAndSetOrdered(values[index].expected, values[index].newval));
    }
}

TEST(pctkAtomicTest, AtomicIntFetchOperators)
{
    typedef struct
    {
        int value1;
        int value2;
    } TestData;
    TestData values[] = {{0,     1},
                         {1,     0},
                         {1,     2},
                         {2,     1},
                         {10,    21},
                         {31,    40},
                         {51,    62},
                         {72,    81},
                         {72,    81},
                         {810,   721},
                         {631,   540},
                         {451,   362},
                         {272,   181},
                         {1810,  8721},
                         {3631,  6540},
                         {5451,  4362},
                         {7272,  2181},
                         {0,     -1},
                         {1,     0},
                         {1,     -2},
                         {2,     -1},
                         {10,    -21},
                         {31,    -40},
                         {51,    -62},
                         {72,    -81},
                         {810,   -721},
                         {631,   -540},
                         {451,   -362},
                         {272,   -181},
                         {1810,  -8721},
                         {3631,  -6540},
                         {5451,  -4362},
                         {7272,  -2181},
                         {272,   -181},
                         {0,     1},
                         {-1,    0},
                         {-1,    2},
                         {-2,    1},
                         {-10,   21},
                         {-31,   40},
                         {-51,   62},
                         {-72,   81},
                         {-810,  721},
                         {-631,  540},
                         {-451,  362},
                         {-272,  181},
                         {-1810, 8721},
                         {-3631, 6540},
                         {-5451, 4362},
                         {-7272, 2181},};
    pctk_size_t size = PCTK_ELEMENTS_NUM(values);
    for (pctk_size_t index = 0; index < size; ++index)
    {
        /* fetch_and_store */
        pctk::AtomicInt atomic(values[index].value1);
        CHECK_EQUAL(values[index].value1, atomic.fetchAndStoreRelaxed(values[index].value2));
        CHECK_EQUAL(values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndStoreAcquire(values[index].value2));
        CHECK_EQUAL(values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndStoreRelease(values[index].value2));
        CHECK_EQUAL(values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndStoreOrdered(values[index].value2));
        CHECK_EQUAL(values[index].value2, atomic.loadAcquire());

        /* fetch_and_add */
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAddRelaxed(values[index].value2));
        CHECK_EQUAL(values[index].value1 + values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAddAcquire(values[index].value2));
        CHECK_EQUAL(values[index].value1 + values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAddRelease(values[index].value2));
        CHECK_EQUAL(values[index].value1 + values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAddOrdered(values[index].value2));
        CHECK_EQUAL(values[index].value1 + values[index].value2, atomic.loadAcquire());

        /* fetch_and_sub */
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndSubRelaxed(values[index].value2));
        CHECK_EQUAL(values[index].value1 - values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndSubAcquire(values[index].value2));
        CHECK_EQUAL(values[index].value1 - values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndSubRelease(values[index].value2));
        CHECK_EQUAL(values[index].value1 - values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndSubOrdered(values[index].value2));
        CHECK_EQUAL(values[index].value1 - values[index].value2, atomic.loadAcquire());

        /* fetch_and_and */
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAndRelaxed(values[index].value2));
        CHECK_EQUAL(values[index].value1 & values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAndAcquire(values[index].value2));
        CHECK_EQUAL(values[index].value1 & values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAndRelease(values[index].value2));
        CHECK_EQUAL(values[index].value1 & values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndAndOrdered(values[index].value2));
        CHECK_EQUAL(values[index].value1 & values[index].value2, atomic.loadAcquire());

        /* fetch_and_or */
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndOrRelaxed(values[index].value2));
        CHECK_EQUAL(values[index].value1 | values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndOrAcquire(values[index].value2));
        CHECK_EQUAL(values[index].value1 | values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndOrRelease(values[index].value2));
        CHECK_EQUAL(values[index].value1 | values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndOrOrdered(values[index].value2));
        CHECK_EQUAL(values[index].value1 | values[index].value2, atomic.loadAcquire());

        /* fetch_and_xor */
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndXorRelaxed(values[index].value2));
        CHECK_EQUAL(values[index].value1 ^ values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndXorAcquire(values[index].value2));
        CHECK_EQUAL(values[index].value1 ^ values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndXorRelease(values[index].value2));
        CHECK_EQUAL(values[index].value1 ^ values[index].value2, atomic.loadAcquire());
        atomic = values[index].value1;
        CHECK_EQUAL(values[index].value1, atomic.fetchAndXorOrdered(values[index].value2));
        CHECK_EQUAL(values[index].value1 ^ values[index].value2, atomic.loadAcquire());
    }
}

TEST(pctkAtomicTest, AtomicIntThreadLoop)
{

}

TEST(pctkAtomicTest, AtomicPointerConstruct)
{
    int val = 0;
    int *one = &val;
    int **two = &one;
    int ***three = &two;

    pctk::AtomicPointer<int> atomicOne(one);
    CHECK_EQUAL(one, atomicOne.loadAcquire());
    pctk::AtomicPointer<int *> atomicTwo(two);
    CHECK_EQUAL(two, atomicTwo.loadAcquire());
    pctk::AtomicPointer<int **> atomicThree(three);
    CHECK_EQUAL(three, atomicThree.loadAcquire());
}

TEST(pctkAtomicTest, AtomicPointerCopy)
{
    int val = 0;
    int *one = &val;
    int **two = &one;
    int ***three = &two;

    pctk::AtomicPointer<int> atomicOne(one);
    pctk::AtomicPointer<int> copyOne = atomicOne;
    CHECK_EQUAL(one, atomicOne.loadAcquire());
    CHECK_EQUAL(copyOne.loadAcquire(), atomicOne.loadAcquire());

    pctk::AtomicPointer<int *> atomicTwo(two);
    pctk::AtomicPointer<int *> copyTwo(atomicTwo);
    CHECK_EQUAL(two, atomicTwo.loadAcquire());
    CHECK_EQUAL(copyTwo.loadAcquire(), atomicTwo.loadAcquire());

    pctk::AtomicPointer<int **> atomicThree(three);
    pctk::AtomicPointer<int **> copyThree = atomicThree;
    CHECK_EQUAL(three, atomicThree.loadAcquire());
    CHECK_EQUAL(copyThree.loadAcquire(), atomicThree.loadAcquire());
}

TEST(pctkAtomicTest, AtomicPointerTestSet)
{
    int val = 0;
    int *one = &val;
    int **two = &one;
    int ***three = &two;

    pctk::AtomicPointer<int> atomic1(one);
    pctk::AtomicPointer<int *> atomic2(two);
    pctk::AtomicPointer<int **> atomic3(three);

    CHECK_EQUAL(one, atomic1.loadAcquire());
    CHECK_EQUAL(two, atomic2.loadAcquire());
    CHECK_EQUAL(three, atomic3.loadAcquire());

    CHECK(atomic1.testAndSetRelaxed(one, one));
    CHECK(atomic2.testAndSetRelaxed(two, two));
    CHECK(atomic3.testAndSetRelaxed(three, three));

    CHECK_EQUAL(one, atomic1.loadAcquire());
    CHECK_EQUAL(two, atomic2.loadAcquire());
    CHECK_EQUAL(three, atomic3.loadAcquire());

    CHECK(atomic1.testAndSetAcquire(one, one));
    CHECK(atomic2.testAndSetAcquire(two, two));
    CHECK(atomic3.testAndSetAcquire(three, three));

    CHECK_EQUAL(one, atomic1.loadAcquire());
    CHECK_EQUAL(two, atomic2.loadAcquire());
    CHECK_EQUAL(three, atomic3.loadAcquire());

    CHECK(atomic1.testAndSetRelease(one, one));
    CHECK(atomic2.testAndSetRelease(two, two));
    CHECK(atomic3.testAndSetRelease(three, three));

    CHECK_EQUAL(one, atomic1.loadAcquire());
    CHECK_EQUAL(two, atomic2.loadAcquire());
    CHECK_EQUAL(three, atomic3.loadAcquire());

    CHECK(atomic1.testAndSetOrdered(one, one));
    CHECK(atomic2.testAndSetOrdered(two, two));
    CHECK(atomic3.testAndSetOrdered(three, three));
}

TEST(pctkAtomicTest, AtomicPointerFetchStore)
{
    int val = 0;
    int *one = &val;
    int **two = &one;
    int ***three = &two;

    pctk::AtomicPointer<int> atomic1(one);
    pctk::AtomicPointer<int *> atomic2(two);
    pctk::AtomicPointer<int **> atomic3(three);

    CHECK_EQUAL(one, atomic1.fetchAndStoreRelaxed(one));
    CHECK_EQUAL(two, atomic2.fetchAndStoreRelaxed(two));
    CHECK_EQUAL(three, atomic3.fetchAndStoreRelaxed(three));

    CHECK_EQUAL(one, atomic1.fetchAndStoreAcquire(one));
    CHECK_EQUAL(two, atomic2.fetchAndStoreAcquire(two));
    CHECK_EQUAL(three, atomic3.fetchAndStoreAcquire(three));

    CHECK_EQUAL(one, atomic1.fetchAndStoreRelease(one));
    CHECK_EQUAL(two, atomic2.fetchAndStoreRelease(two));
    CHECK_EQUAL(three, atomic3.fetchAndStoreRelease(three));

    CHECK_EQUAL(one, atomic1.fetchAndStoreOrdered(one));
    CHECK_EQUAL(two, atomic2.fetchAndStoreOrdered(two));
    CHECK_EQUAL(three, atomic3.fetchAndStoreOrdered(three));
}

TEST(pctkAtomicTest, AtomicPointerFetchSubAdd)
{
    int values[] = {0, 1, 2, 10, 31, 51, 72, 810, 631, 451, 272, 1810, 3631, 5451, 7272, -1, -2, -10, -31, -51, -72,
                    -810, -631, -451, -272, -1810, -3631, -5451, -7272,};
    int size = PCTK_ELEMENTS_NUM(values);

    char c;
    char *pc = &c;
    short s;
    short *ps = &s;
    int in;
    int *pi = &in;

    for (int i = 0; i < size; ++i)
    {
        pctk::AtomicPointer<char> atomic1c;
        pctk::AtomicPointer<short> atomic1s;
        pctk::AtomicPointer<int> atomic1i;

        /* test fetch_and_add_relaxed */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndAddRelaxed(values[i]));
        CHECK_EQUAL(pc + values[i], atomic1c.fetchAndAddRelaxed(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndAddRelaxed(values[i]));
        CHECK_EQUAL((short *)((char *)ps + values[i]), atomic1s.fetchAndAddRelaxed(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndAddRelaxed(values[i]));
        CHECK_EQUAL((int *)((char *)pi + values[i]), atomic1i.fetchAndAddRelaxed(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_add_acquire */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndAddAcquire(values[i]));
        CHECK_EQUAL(pc + values[i], atomic1c.fetchAndAddAcquire(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndAddAcquire(values[i]));
        CHECK_EQUAL((short *)((char *)ps + values[i]), atomic1s.fetchAndAddAcquire(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndAddAcquire(values[i]));
        CHECK_EQUAL((int *)((char *)pi + values[i]), atomic1i.fetchAndAddAcquire(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_add_release */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndAddRelease(values[i]));
        CHECK_EQUAL(pc + values[i], atomic1c.fetchAndAddRelease(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndAddRelease(values[i]));
        CHECK_EQUAL((short *)((char *)ps + values[i]), atomic1s.fetchAndAddRelease(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndAddRelease(values[i]));
        CHECK_EQUAL((int *)((char *)pi + values[i]), atomic1i.fetchAndAddRelease(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_add_ordered */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndAddOrdered(values[i]));
        CHECK_EQUAL(pc + values[i], atomic1c.fetchAndAddOrdered(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndAddOrdered(values[i]));
        CHECK_EQUAL((short *)((char *)ps + values[i]), atomic1s.fetchAndAddOrdered(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndAddOrdered(values[i]));
        CHECK_EQUAL((int *)((char *)pi + values[i]), atomic1i.fetchAndAddOrdered(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_sub_relaxed */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndSubRelaxed(values[i]));
        CHECK_EQUAL(pc - values[i], atomic1c.fetchAndSubRelaxed(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndSubRelaxed(values[i]));
        CHECK_EQUAL((short *)((char *)ps - values[i]), atomic1s.fetchAndSubRelaxed(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndSubRelaxed(values[i]));
        CHECK_EQUAL((int *)((char *)pi - values[i]), atomic1i.fetchAndSubRelaxed(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_sub_acquire */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndSubAcquire(values[i]));
        CHECK_EQUAL(pc - values[i], atomic1c.fetchAndSubAcquire(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndSubAcquire(values[i]));
        CHECK_EQUAL((short *)((char *)ps - values[i]), atomic1s.fetchAndSubAcquire(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndSubAcquire(values[i]));
        CHECK_EQUAL((int *)((char *)pi - values[i]), atomic1i.fetchAndSubAcquire(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_sub_release */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndSubRelease(values[i]));
        CHECK_EQUAL(pc - values[i], atomic1c.fetchAndSubRelease(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndSubRelease(values[i]));
        CHECK_EQUAL((short *)((char *)ps - values[i]), atomic1s.fetchAndSubRelease(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndSubRelease(values[i]));
        CHECK_EQUAL((int *)((char *)pi - values[i]), atomic1i.fetchAndSubRelease(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());

        /* test fetch_and_sub_ordered */
        atomic1c = pc;
        CHECK_EQUAL(pc, atomic1c.fetchAndSubOrdered(values[i]));
        CHECK_EQUAL(pc - values[i], atomic1c.fetchAndSubOrdered(-values[i]));
        CHECK_EQUAL(pc, atomic1c.loadAcquire());

        atomic1s = ps;
        CHECK_EQUAL(ps, atomic1s.fetchAndSubOrdered(values[i]));
        CHECK_EQUAL((short *)((char *)ps - values[i]), atomic1s.fetchAndSubOrdered(-values[i]));
        CHECK_EQUAL(ps, atomic1s.loadAcquire());

        atomic1i = pi;
        CHECK_EQUAL(pi, atomic1i.fetchAndSubOrdered(values[i]));
        CHECK_EQUAL((int *)((char *)pi - values[i]), atomic1i.fetchAndSubOrdered(-values[i]));
        CHECK_EQUAL(pi, atomic1i.loadAcquire());
    }
}

int main(int ac, char **av)
{
#ifndef PCTK_TEST_ENABLE_MEMORYLEAK
    MemoryLeakWarningPlugin::turnOffNewDeleteOverloads();
#endif
    return CommandLineTestRunner::RunAllTests(ac, av);
}
