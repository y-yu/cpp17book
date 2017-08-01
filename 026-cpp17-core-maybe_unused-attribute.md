## [[maybe_unused]]属性

[[maybe_unused]]属性は名前やエンティティが意図的に使われないことを示すのに使える。

現実のC++のコードでは、宣言されているのにソースコードだけを考慮するとどこからも使われていないように見える名前やエンティティが存在する。

~~~cpp
void do_something( int *, int * ) ;

void f()
{
    int x[5] ;
    char reserved[1024] = { } ;
    int y[5] ;

    do_something( x, y ) ;
}
~~~

ここではreservedという名前はどこからも使われていない。一見すると不必要な名前に見える。優秀なC++コンパイラーはこのようなどこからも使われていない名前に対して「どこからも使われていない」という警告メッセージを出す。

しかし、コンパイラーから見えているソースコードがプログラムの全てではない。様々な理由でreservedのような一見使われていない変数が必要になる。


例えば、reservedはスタック破壊を検出するための領域かもしれない。プログラムはC++以外の言語で書かれたコードとリンクしていて、そこで使われるのかもしれない。あるいはOSや外部デバイスが読み書きするメモリとして確保しているのかもしれない。

どのような理由にせよ、名前やエンティティが一見使われていないように見えるが存在が必要であるという意味を表すのに、[[maybe_unused]]属性を使うことができる。これにより、C++コンパイラーの「未使用の名前」という警告メッセージを抑制できる。


~~~cpp
[[maybe_unused]] char reserved[1024] ;
~~~

[[maybe_unused]]属性を適用できる名前とエンティティの宣言は、クラス、typedef名、変数、非staticデータメンバー、関数、enum、enumeratorだ。


~~~cpp
// クラス
class [[maybe_unused]] class_name
{
// 非staticデータメンバー
    [[maybe_unused]] int non_static_data_member ;

} ;

// typedef名
// どちらでもよい
[[maybe_unused]] typedef int typedef_name1 ;
typedef int typedef_name2 [[maybe_unused]] ;

// エイリアス宣言によるtypedef名
using typedef_name3 [[maybe_unused]] = int ;

// 変数
// どちらでもよい
[[maybe_unused]] int variable_name1{};
int variable_name2 [[maybe_unused]] { } ;

// 関数
// メンバー関数も同じ文法
// どちらでもよい
[[maybe_unused]] void function_name1() { }
void function_name2 [[maybe_unused]] () { }

enum [[maybe_unused]] enum_name
{
// enumerator
    enumerator_name [[maybe_unused]] = 0
} ;
~~~

機能テストマクロは__has_cpp_attribute(maybe_unused), 値は201603
