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

#include <pctkAny.h>

#include <CppUTest/TestHarness.h>
#include <CppUTest/CommandLineTestRunner.h>

#include <iostream>
#include <string>
#include <sstream>
#include <vector>

enum State
{
    /* 0 */ default_constructed,
    /* 1 */ value_copy_constructed,
    /* 2 */ value_move_constructed,
    /* 3 */ copy_constructed,
    /* 4 */ move_constructed,
    /* 5 */ move_assigned,
    /* 6 */ copy_assigned,
    /* 7 */ value_copy_assigned,
    /* 8 */ value_move_assigned,
    /* 9 */ moved_from,
    /*10 */ value_constructed
};

struct V
{
    State state;
    int value;

    V() : state(default_constructed), value(deflt()) {}
    V(int v) : state(value_constructed), value(v) {}
    V(V const &v) : state(copy_constructed), value(v.value) {}

    V &operator=(int v)
    {
        state = value_copy_assigned;
        value = v;
        return *this;
    }
    V &operator=(V const &v)
    {
        state = copy_assigned;
        value = v.value;
        return *this;
    }

#if PCTK_CC_STDCXX_11
    V(             V &&v ) : state( move_constructed   ), value(  std::move( v.value ) )
    {
        v.state = moved_from;
    }
    V &operator=( V &&v )
    {
        state = move_assigned      ;
        value = std::move( v.value );
        v.state = moved_from;
        return *this;
    }
#endif

    static int deflt()
    {
        return 42;
    }

    bool operator==(V const &other) const
    {
        return state == other.state && value == other.value;
    }
};

struct S
{
    State state;
    V value;

    S() : state(default_constructed) {}
    S(V const &v) : state(value_copy_constructed), value(v) {}
    S(S const &s) : state(copy_constructed), value(s.value) {}

    S &operator=(V const &v)
    {
        state = value_copy_assigned;
        value = v;
        return *this;
    }
    S &operator=(const S &s)
    {
        state = copy_assigned;
        value = s.value;
        return *this;
    }

#if PCTK_CC_STDCXX_11
    S(             V &&v ) : state(  value_move_constructed ), value(  std::move( v )     )
    {
        v.state = moved_from;
    }
    S(             S &&s ) : state(  move_constructed       ), value(  std::move( s.value ) )
    {
        s.state = moved_from;
    }

    S &operator=( V &&v )
    {
        state = value_move_assigned     ;
        value = std::move( v       );
        v.state = moved_from;
        return *this;
    }
    S &operator=( S &&s )
    {
        state = move_assigned           ;
        value = std::move( s.value );
        s.state = moved_from;
        return *this;
    }
#endif

    bool operator==(S const &rhs) const
    {
        return state == rhs.state && value == rhs.value;
    }
};

inline std::ostream &operator<<(std::ostream &os, V const &v)
{
    std::stringstream sstream;
    sstream << "[V:" << v.value << "]";
    return os << sstream.str();
}

inline std::ostream &operator<<(std::ostream &os, S const &s)
{
    std::stringstream sstream;
    sstream << "[S:" << s.value << "]";
    return os << sstream.str();
}

#if PCTK_CC_STDCXX_11
struct InitList
{
    std::vector<int> vec;
    char c;
    S s;

    InitList( std::initializer_list<int> il, char k, S const &t)
        : vec( il ), c( k ), s( t ) {}

    InitList( std::initializer_list<int> il, char k, S &&t)
        : vec( il ), c( k ), s( std::move(t) ) {}
};
#endif

TEST_GROUP(pctkAnyTest) {};

TEST(pctkAnyTest, defaultConstruct)
{
    pctk::Any a;

    CHECK_FALSE(a.hasValue());
}

TEST(pctkAnyTest, copyConstruct)
{
    pctk::Any a(7);

    pctk::Any b(a);

    CHECK(a.hasValue());
    CHECK(b.hasValue());
    CHECK(pctk::any_cast<int>(b) == 7);
}

TEST(pctkAnyTest, moveConstruct)
{
#if PCTK_CC_STDCXX_11
    pctk::Any b( pctk::Any( 7 ) );

    CHECK( pctk::any_cast<int>( b ) == 7 );
#else
    CHECK(!!"pctk::Any: move-construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, copyConstructFromLiteralValue)
{
    pctk::Any a(7);

    CHECK(pctk::any_cast<int>(a) == 7);
}

TEST(pctkAnyTest, copyConstructFromConstValue)
{
    const int i = 7;
    pctk::Any a(i);

    CHECK(pctk::any_cast<int>(a) == i);
}

TEST(pctkAnyTest, copyConstructFromLvalueReferences)
{
    std::string i = "Test";
    pctk::Any a(i);

    CHECK(pctk::any_cast<std::string>(a) == i);
}

TEST(pctkAnyTest, moveConstructFromValue)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
    pctk::Any a( std::move( s ) );

    CHECK( pctk::any_cast<S>( &a )->value.value == 7          );
    CHECK( pctk::any_cast<S>( &a )->state == move_constructed );
    CHECK(                  s.state == moved_from       );
#else
    CHECK(!!"pctk::Any: move-construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceConstructFromLiteralValue)
{
#if PCTK_CC_STDCXX_11
    using pair_t = std::pair<char, int>;

#if CF_USES_STD_ANY
    pctk::Any a( in_place_type<pair_t>, 'a', 7 );
#else
    pctk::Any a( CF_IN_PLACE_TYPE_T( pair_t ), 'a', 7 );
//  pctk::Any a( in_place<     pair_t>, 'a', 7 );
#endif
    CHECK( pctk::any_cast<pair_t>( a ).first  == 'a' );
    CHECK( pctk::any_cast<pair_t>( a ).second ==  7  );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceCopyConstructFromLiteralValue)
{
#if PCTK_CC_STDCXX_11
    char c = 'a';
    V v( 7 );
    using pair_t = std::pair<char, V>;

#if CF_USES_STD_ANY
    pctk::Any a( in_place_type<pair_t>, c, v );
#else
    pctk::Any a( in_place_type<pair_t>, c, v );
//  pctk::Any a( in_place<     pair_t>, c, v );
#endif

    CHECK( pctk::any_cast<pair_t>( &a )->first        == 'a' );
    CHECK( pctk::any_cast<pair_t>( &a )->second.value ==  7  );
#if CF_USES_STD_ANY
    CHECK( pctk::any_cast<pair_t>( &a )->second.state == copy_constructed );
#else
    CHECK( pctk::any_cast<pair_t>( &a )->second.state == move_constructed );
#endif
    CHECK(                              v.state != moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceMoveConstructFromValue)
{
#if PCTK_CC_STDCXX_11
    char c = 'a';
    V v( 7 );
    using pair_t = std::pair<char, V>;

#if CF_USES_STD_ANY
    pctk::Any a( in_place_type<pair_t>, c, std::move(v) );
#else
    pctk::Any a( in_place_type<pair_t>, c, std::move(v) );
//  pctk::Any a( in_place<     pair_t>, c, std::move(v) );
#endif
    CHECK( pctk::any_cast<pair_t>( &a )->first        == 'a' );
    CHECK( pctk::any_cast<pair_t>( &a )->second.value ==  7  );
    CHECK( pctk::any_cast<pair_t>( &a )->second.state == move_constructed );
    CHECK(                              v.state == moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceCopyConstructFromInitializerList)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
#if CF_USES_STD_ANY
    pctk::Any a( in_place_type<InitList>, { 7, 8, 9, }, 'a', s );
#else
    pctk::Any a( in_place_type<InitList>, { 7, 8, 9, }, 'a', s );
//  pctk::Any a( in_place<     InitList>, { 7, 8, 9, }, 'a', s );
#endif

    CHECK( pctk::any_cast<InitList>( &a )->vec[0]  ==  7  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[1]  ==  8  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[2]  ==  9  );
    CHECK( pctk::any_cast<InitList>( &a )->c       == 'a' );
    CHECK( pctk::any_cast<InitList>( &a )->s.value.value ==  7               );
#if CF_USES_STD_ANY
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == copy_constructed );
#else
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == move_constructed );
#endif
    CHECK(                           s.state       != moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceMoveConstructFromInitializerList)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
#if CF_USES_STD_ANY
    pctk::Any a( in_place_type<InitList>, { 7, 8, 9, }, 'a', std::move(s) );
#else
    pctk::Any a( in_place_type<InitList>, { 7, 8, 9, }, 'a', std::move(s) );
//  pctk::Any a( in_place<     InitList>, { 7, 8, 9, }, 'a', std::move(s) );
#endif

    CHECK( pctk::any_cast<InitList>( &a )->vec[0]  ==  7  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[1]  ==  8  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[2]  ==  9  );
    CHECK( pctk::any_cast<InitList>( &a )->c       == 'a' );
    CHECK( pctk::any_cast<InitList>( &a )->s.value.value == 7                );
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == move_constructed );
    CHECK(                           s.state       == moved_from       );
    CHECK(                           s.value.state == moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, copyAssignFromCFAny)
{
    pctk::Any a = 7;
    pctk::Any b;

    b = a;

    CHECK(pctk::any_cast<int>(b) == 7);
}

TEST(pctkAnyTest, moveAssignFromCFAny)
{
#if PCTK_CC_STDCXX_11
    pctk::Any a;

    a = pctk::Any( 7 );

    CHECK( pctk::any_cast<int>( a ) == 7 );
#else
    CHECK(!!"pctk::Any: move semantics are not available (no C++11)");
#endif
}

TEST(pctkAnyTest, copyAssignFromLiteralValue)
{
    pctk::Any a;

    a = 7;

    CHECK(pctk::any_cast<int>(a) == 7);
}

TEST(pctkAnyTest, copyAssignFromValue)
{
    const int i = 7;
    std::string s = "42";

    pctk::Any a;

    a = i;

    CHECK(pctk::any_cast<int>(a) == i);

    a = s;

    CHECK(pctk::any_cast<std::string>(a) == s);
}

TEST(pctkAnyTest, moveAssignFromValue)
{
#if PCTK_CC_STDCXX_11
    V v( 7 );
    pctk::Any a;

    a = std::move( v );

    CHECK( pctk::any_cast<V>( &a )->value == 7                );
    CHECK( pctk::any_cast<V>( &a )->state == move_constructed );
    CHECK(                  v.state == moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, copyEmplaceContent)
{
#if PCTK_CC_STDCXX_11
    using pair_t = std::pair<char, V>;
    V v( 7 );
    pctk::Any a;

    a.emplace<pair_t>( 'a', v );

    CHECK( pctk::any_cast<pair_t>( &a )->first        == 'a'              );
    CHECK( pctk::any_cast<pair_t>( &a )->second.value ==  7               );
#if CF_USES_STD_ANY
    CHECK( pctk::any_cast<pair_t>( &a )->second.state == copy_constructed );
#else
    CHECK( pctk::any_cast<pair_t>( &a )->second.state == move_constructed );
#endif
    CHECK(                              v.state != moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, moveEmplaceContent)
{
#if PCTK_CC_STDCXX_11
    using pair_t = std::pair<char, V>;
    V v( 7 );
    pctk::Any a;

    a.emplace<pair_t>( 'a', std::move( v ) );

    CHECK( pctk::any_cast<pair_t>( &a )->first        == 'a'              );
    CHECK( pctk::any_cast<pair_t>( &a )->second.value ==  7               );
    CHECK( pctk::any_cast<pair_t>( &a )->second.state == move_constructed );
    CHECK(                              v.state == moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, copyEmplaceContentFromIntializerList)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
    pctk::Any a;

    a.emplace<InitList>( { 7, 8, 9, }, 'a', s );

    CHECK( pctk::any_cast<InitList>( &a )->vec[0]  ==  7  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[1]  ==  8  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[2]  ==  9  );
    CHECK( pctk::any_cast<InitList>( &a )->c       == 'a' );
    CHECK( pctk::any_cast<InitList>( &a )->s.value.value ==  7               );
#if CF_USES_STD_ANY
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == copy_constructed );
#else
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == move_constructed );
#endif
    CHECK(                           s.state       != moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, moveEmplaceContentFromIntializerList)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
    pctk::Any a;

    a.emplace<InitList>( { 7, 8, 9, }, 'a', std::move( s ) );

    CHECK( pctk::any_cast<InitList>( &a )->vec[0]  ==  7  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[1]  ==  8  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[2]  ==  9  );
    CHECK( pctk::any_cast<InitList>( &a )->c       == 'a' );
    CHECK( pctk::any_cast<InitList>( &a )->s.value.value ==  7               );
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == move_constructed );
    CHECK(                           s.state       == moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, resetContent)
{
    pctk::Any a = 7;

    a.reset();

    CHECK_FALSE(a.hasValue());
}

TEST(pctkAnyTest, swapWithOtherCFAny)
{
    pctk::Any a = 1;
    pctk::Any b = 2;

    a.swap(b);

    CHECK(pctk::any_cast<int>(a) == 2);
    CHECK(pctk::any_cast<int>(b) == 1);
}

TEST(pctkAnyTest, inspectIfCFAnyContainsAValue)
{
    pctk::Any a = 7;

    CHECK(a.hasValue());
}

TEST(pctkAnyTest, obtainTypeInfoOfCFAnysContent)
{
    pctk::Any a = 7;
    pctk::Any b = 3.14;

    CHECK((a.type() == typeid(int)));
    CHECK((b.type() == typeid(double)));
}

//
// pctk::Any non-member functions:
//

TEST(pctkAnyTest, swapWithOtherCFAnyWithNonMemberFunctions)
{
    pctk::Any a = 1;
    pctk::Any b = 2;

    swap(a, b);

    CHECK(pctk::any_cast<int>(a) == 2);
    CHECK(pctk::any_cast<int>(b) == 1);
}

TEST(pctkAnyTest, inplaceCopyConstructCFAnyFromArguments)
{
#if PCTK_CC_STDCXX_11
    using pair_t = std::pair<char, S>;

    S s( 7 );
    pctk::Any a = make_any<pair_t>( 'a', s );

    CHECK( pctk::any_cast<pair_t>( &a )->first              == 'a' );
    CHECK( pctk::any_cast<pair_t>( &a )->second.value.value ==  7  );
#if CF_USES_STD_ANY
    CHECK( pctk::any_cast<pair_t>( &a )->second.state       == copy_constructed );
#else
    CHECK( pctk::any_cast<pair_t>( &a )->second.state       == move_constructed );
#endif
    CHECK(                              s.state       != moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceMoveConstructCFAnyFromArguments)
{
#if PCTK_CC_STDCXX_11
    using pair_t = std::pair<char, S>;
    S s( 7 );

    pctk::Any a = make_any<pair_t>( 'a', std::move( s ) );

    CHECK( pctk::any_cast<pair_t>( &a )->first              == 'a' );
    CHECK( pctk::any_cast<pair_t>( &a )->second.value.value ==  7  );
    CHECK( pctk::any_cast<pair_t>( &a )->second.state       ==  move_constructed );
    CHECK(                              s.state       ==  moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceCopyConstructCFAnyFromInitializerListAndArguments)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
    pctk::Any a = make_any<InitList>( { 7, 8, 9, }, 'a', s );

    CHECK( pctk::any_cast<InitList>( &a )->vec[0]  ==  7  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[1]  ==  8  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[2]  ==  9  );
    CHECK( pctk::any_cast<InitList>( &a )->c       == 'a' );
    CHECK( pctk::any_cast<InitList>( &a )->s.value.value ==  7               );
#if CF_USES_STD_ANY
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == copy_constructed );
#else
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == move_constructed );
#endif
    CHECK(                           s.state       != moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, inplaceMoveConstructCFAnyFromInitializerListAndArguments)
{
#if PCTK_CC_STDCXX_11
    S s( 7 );
    pctk::Any a = make_any<InitList>( { 7, 8, 9, }, 'a', std::move( s ) );

    CHECK( pctk::any_cast<InitList>( &a )->vec[0]  ==  7  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[1]  ==  8  );
    CHECK( pctk::any_cast<InitList>( &a )->vec[2]  ==  9  );
    CHECK( pctk::any_cast<InitList>( &a )->c       == 'a' );
    CHECK( pctk::any_cast<InitList>( &a )->s.value.value ==  7               );
    CHECK( pctk::any_cast<InitList>( &a )->s.state       == move_constructed );
    CHECK(                           s.state       == moved_from       );
#else
    CHECK(!!"pctk::Any: in-place construction is not available (no C++11)");
#endif
}

TEST(pctkAnyTest, obtainCFAnysContentByValueCR)
{
    struct F
    {
        static pctk::Any const &ident(pctk::Any const &a)
        {
            return a;
        }
    };
    pctk::Any a = 7;

    CHECK(pctk::any_cast<int>(F::ident(a)) == 7);
}

TEST(pctkAnyTest, obtainCFAnysContentByValueR)
{
    struct F
    {
        static pctk::Any &ident(pctk::Any &a)
        {
            return a;
        }
    };
    pctk::Any a = 7;

    CHECK(pctk::any_cast<int>(F::ident(a)) == 7);
}

TEST(pctkAnyTest, obtainCFAnysContentByValueRR)
{
#if PCTK_CC_STDCXX_11
    struct F
    {
        static pctk::Any &&ident( pctk::Any &&a )
        {
            return std::move(a);
        }
    };

    CHECK( pctk::any_cast<int>( F::ident( pctk::Any(7) ) ) == 7 );
#else
    CHECK(!!"pctk::Any: move semantics not available (no C++11)");
#endif
}

TEST(pctkAnyTest, obtainCFAnysContentByPointer)
{
    struct F
    {
        static pctk::Any const *ident(pctk::Any const *a)
        {
            return a;
        }
    };
    pctk::Any a = 7;

    CHECK(*pctk::any_cast<int>(F::ident(&a)) == 7);
}

TEST(pctkAnyTest, obtainCFAnysContentByPointe)
{
    struct F
    {
        static pctk::Any *ident(pctk::Any *a)
        {
            return a;
        }
    };
    pctk::Any a = 7;

    CHECK(*pctk::any_cast<int>(F::ident(&a)) == 7);
}

TEST(pctkAnyTest, throwsBadAnyCastIfRequestedTypeDiffersFromContentType)
{
    struct F
    {
        static pctk::Any const &ident(pctk::Any const &a)
        {
            return a;
        }
    };
    pctk::Any a = 7;

//    CHECK_THROWS(pctk::any_cast<double>(F::ident(a)), pctk::bad_any_cast);
    //  EXPECT_THROWS_WITH( pctk::any_cast<double>( F::ident(a) ), "..." )

}
//
//TEST(pctkAnyTest, throwsBadAnyCastIfRequestedTypeDiffersFromContentType)
//CASE( "pctk::any_cast: Throws bad_any_cast if requested type differs from content type (pctk::Any &)" )
//{
//    struct F
//    {
//        static pctk::Any &ident( pctk::Any &a )
//        {
//            return a;
//        }
//    };
//    pctk::Any a = 7;
//
//    EXPECT_THROWS_AS( pctk::any_cast<double>( F::ident(a) ), bad_any_cast );
//}

//TEST(pctkAnyTest, throwsBadAnyCastIfRequestedTypeDiffersFromContentType)
//CASE( "pctk::any_cast: Throws bad_any_cast if requested type differs from content type (pctk::Any &&)" )
//{
//#if PCTK_CC_STDCXX_11
//    struct F
//    {
//        static pctk::Any &&ident( pctk::Any &&a )
//        {
//            return std::move(a);
//        }
//    };

//    EXPECT_THROWS_AS( pctk::any_cast<double>( F::ident( pctk::Any(7) ) ), bad_any_cast );
//#else
//    CHECK( !!"pctk::Any: move semantics not available (no C++11)" );
//#endif
//}

TEST(pctkAnyTest, throwsBadAnyCastWithNonEmptyWhat)
{
    struct F
    {
        static pctk::Any const &ident(pctk::Any const &a)
        {
            return a;
        }
    };
    pctk::Any a = 7;

    try
    {
        (void) pctk::any_cast<double>(F::ident(a));
    }
    catch (pctk::BadAnyCast const &e)
    {
        CHECK(!std::string(e.what()).empty());
    }
}

TEST(pctkAnyTest, readsTweakHeaderIfSupported)
{
#if any_HAVE_TWEAK_HEADER
    CHECK( ANY_TWEAK_VALUE == 42 );
#else
    CHECK(!!"Tweak header is not available (any_HAVE_TWEAK_HEADER: 0).");
#endif
}

int main(int ac, char **av)
{
#ifndef PCTK_TEST_ENABLE_MEMORYLEAK
    MemoryLeakWarningPlugin::turnOffNewDeleteOverloads();
#endif
    return CommandLineTestRunner::RunAllTests(ac, av);
}
