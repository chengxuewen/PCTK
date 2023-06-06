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

#include <pctkFlags.h>

#include <CppUTest/TestHarness.h>
#include <CppUTest/CommandLineTestRunner.h>

class MYClass
{
public:
    enum ETypeFlag
    {
        E_1 = (1), E_2 = (1 << 1), E_3 = (1 << 2), E_4 = (1 << 3), E_5 = (1 << 4), E_6 = (1 << 5),
    };
    PCTK_DECL_FLAGS(ETypeFlags, ETypeFlag)

    MYClass() {}
};

TEST_GROUP(pctkFlagsTest) {};

TEST(pctkFlagsTest, testNoFlag)
{
    MYClass::ETypeFlags flags;
    CHECK_FALSE(flags.testFlag(MYClass::E_1));
    CHECK_FALSE(flags.testFlag(MYClass::E_2));
    CHECK_FALSE(flags.testFlag(MYClass::E_3));
    CHECK_FALSE(flags.testFlag(MYClass::E_4));
    CHECK_FALSE(flags.testFlag(MYClass::E_5));
    CHECK_FALSE(flags.testFlag(MYClass::E_6));
}

TEST(pctkFlagsTest, testFlag)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    CHECK(flags.testFlag(MYClass::E_1));
    CHECK(flags.testFlag(MYClass::E_2));
    CHECK_FALSE(flags.testFlag(MYClass::E_3));
    CHECK_FALSE(flags.testFlag(MYClass::E_4));
    CHECK_FALSE(flags.testFlag(MYClass::E_5));
    CHECK_FALSE(flags.testFlag(MYClass::E_6));
}

TEST(pctkFlagsTest, testCopyCtr)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags2(flags);
    CHECK(flags.testFlag(MYClass::E_1));
    CHECK(flags.testFlag(MYClass::E_2));
    CHECK_FALSE(flags.testFlag(MYClass::E_3));
    CHECK_FALSE(flags.testFlag(MYClass::E_4));
    CHECK_FALSE(flags.testFlag(MYClass::E_5));
    CHECK_FALSE(flags.testFlag(MYClass::E_6));
}

TEST(pctkFlagsTest, testCopyOperator)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags2 = flags;
    CHECK(flags2.testFlag(MYClass::E_1));
    CHECK(flags2.testFlag(MYClass::E_2));
    CHECK_FALSE(flags2.testFlag(MYClass::E_3));
    CHECK_FALSE(flags2.testFlag(MYClass::E_4));
    CHECK_FALSE(flags2.testFlag(MYClass::E_5));
    CHECK_FALSE(flags2.testFlag(MYClass::E_6));
}

TEST(pctkFlagsTest, testAnd)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    flags &= 0;
    CHECK_FALSE(flags.testFlag(MYClass::E_1));
    CHECK_FALSE(flags.testFlag(MYClass::E_2));

    MYClass::ETypeFlags flags1(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags2(MYClass::E_1);
    MYClass::ETypeFlags flags3 = flags1 & flags2;
    CHECK(flags3.testFlag(MYClass::E_1));
    CHECK_FALSE(flags3.testFlag(MYClass::E_2));

    MYClass::ETypeFlags flags4(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags5 = flags1 & MYClass::E_1;
    CHECK(flags5.testFlag(MYClass::E_1));
    CHECK_FALSE(flags5.testFlag(MYClass::E_2));
}

TEST(pctkFlagsTest, testOr)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    CHECK(flags.testFlag(MYClass::E_1));
    CHECK(flags.testFlag(MYClass::E_2));
    CHECK_FALSE(flags.testFlag(MYClass::E_3));
    CHECK_FALSE(flags.testFlag(MYClass::E_4));
    CHECK_FALSE(flags.testFlag(MYClass::E_5));
    CHECK_FALSE(flags.testFlag(MYClass::E_6));
    flags |= MYClass::E_3;
    CHECK(flags.testFlag(MYClass::E_3));

    MYClass::ETypeFlags hasFlags(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags noFlags;
    noFlags |= hasFlags;
    CHECK(noFlags.testFlag(MYClass::E_1));
    CHECK(noFlags.testFlag(MYClass::E_2));

    MYClass::ETypeFlags flags1(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags2(MYClass::E_1);
    MYClass::ETypeFlags flags3 = flags1 | flags2;
    CHECK(flags3.testFlag(MYClass::E_1));
    CHECK(flags3.testFlag(MYClass::E_2));

    MYClass::ETypeFlags flags4(MYClass::E_1);
    MYClass::ETypeFlags flags5 = flags1 | MYClass::E_2;
    CHECK(flags5.testFlag(MYClass::E_1));
    CHECK(flags5.testFlag(MYClass::E_2));
}

TEST(pctkFlagsTest, testXor)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    CHECK(flags.testFlag(MYClass::E_1));
    CHECK(flags.testFlag(MYClass::E_2));
    flags ^= MYClass::E_1;
    CHECK_FALSE(flags.testFlag(MYClass::E_1));

    MYClass::ETypeFlags flags2(MYClass::E_2);
    flags ^= flags2;
    CHECK_FALSE(flags.testFlag(MYClass::E_2));

    MYClass::ETypeFlags flags3(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags4(MYClass::E_1);
    MYClass::ETypeFlags flags5 = flags3 ^ flags4;
    CHECK_FALSE(flags5.testFlag(MYClass::E_1));
    CHECK(flags5.testFlag(MYClass::E_2));

    MYClass::ETypeFlags flags6(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags7 = flags6 ^ MYClass::E_1;
    CHECK_FALSE(flags7.testFlag(MYClass::E_1));
    CHECK(flags7.testFlag(MYClass::E_2));
}

TEST(pctkFlagsTest, testNegation)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    MYClass::ETypeFlags flags1 = ~flags;
    CHECK_FALSE(flags1.testFlag(MYClass::E_1));
    CHECK_FALSE(flags1.testFlag(MYClass::E_2));
    CHECK(flags1.testFlag(MYClass::E_3));
    CHECK(flags1.testFlag(MYClass::E_4));
    CHECK(flags1.testFlag(MYClass::E_5));
    CHECK(flags1.testFlag(MYClass::E_6));
}

TEST(pctkFlagsTest, testCheck)
{
    MYClass::ETypeFlags flags(MYClass::E_1 | MYClass::E_2);
    CHECK_FALSE(!flags);

    MYClass::ETypeFlags flags1;
    CHECK(!flags1);
}

int main(int ac, char **av)
{
#ifndef PCTK_TEST_ENABLE_MEMORYLEAK
    MemoryLeakWarningPlugin::turnOffNewDeleteOverloads();
#endif
    return CommandLineTestRunner::RunAllTests(ac, av);
}
