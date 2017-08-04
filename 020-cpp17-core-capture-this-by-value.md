## ラムダ式で\*thisのコピーキャプチャー

C++17ではラムダ式で\*thisをコピーキャプチャーできるようになった。\*thisをコピーキャプチャーするには、ラムダキャプチャーに\*thisと書く。

~~~cpp
struct X
{
   int data = 42 ;
   auto get()
   {
       return [*this]() { return this->data ; } ;
   }
} ;

int main()
{
    std::function <int () > f ;
    {
        X x ;
        f = x.get() ;
    }// xの寿命はここまで
    
    // コピーされているので問題ない
    int data = f() ;
}
~~~

コピーキャプチャーする\*thisはlambda式が書かれた場所の\*thisだ。

また、以下のようなコードで挙動の違いをみるとわかりやすい。

~~~cpp
struct X
{
   int data = 0 ;
   void f()
   {
        // thisはポインターのキャプチャー
        // dataはthisポインターを辿る。
        [this]{ data = 1 ; }() ;

        // this->dataは1

        // エラー、*thisはコピーされている
        // クロージャーオブジェクトのコピーキャプチャされた変数はデフォルトで変更できない
        [*this]{ data = 2 ; } () ;

        // OK、mutableを使っている

        [*this]() mutable { data = 2 ; } () ;

        // this->dataは1
        // 変更されたのはコピーされたクロージャーオブジェクト内の*this        
   }
} ;
~~~

最初のラムダ式で生成されるクロージャーオブジェクトは以下のようなものだ。
~~~cpp
class closure_object
{
    X * this_ptr ;

public :
    closure_object( X * this_ptr )
        : this_ptr(this_ptr) { }

    void operator () const
    {
        this_ptr->data = 1 ;
    }
} ;
~~~

二番目のラムダ式では以下のようなクロージャーオブジェクトが生成される。



~~~cpp
class closure_object
{
    X this_obj ;
    X const * this_ptr = &this_obj ;

public :
    closure_object( X const & this_obj )
        : this_obj(this_obj) { }

    void operator () const
    {
        this_ptr->data = 1 ;
    }
} ;
~~~

三番目のラムダ式では以下のようなクロージャーオブジェクトが生成される。

これはC++の文法に従っていないのでやや苦しいコード例だが、コピーキャプチャーされた値を変更しようとしているためエラーとなる。

~~~cpp
class closure_object
{
    X this_obj ;
    X * this_ptr = &this_obj ;

public :
    closure_object( X const & this_obj )
        : this_obj(this_obj) { }

    void operator ()
    {
        this_ptr->data = 2 ;
    }
} ;
~~~

ラムダ式にmutableが付いているのでコピーキャプチャーされた値も変更できる。

\*thisをコピーキャプチャーした場合、thisキーワードはコピーされたオブジェクトへのポインターになる。

~~~cpp
struct X
{
   int data = 42 ;
   void f()
   {
        // thisはこのメンバー関数fを呼び出したオブジェクトへのアドレス
        std::printf("%p\n", this ) ;

        // thisはコピーされた別のオブジェクトへのアドレス
        [*this](){  std::printf("%p\n", this) ;  }() ;
   }
} ;

int main()
{
    X x ;
    x.f() ;
}
~~~

この場合、出力される2つのポインターの値は異なる。

ラムダ式での\*thisのコピーキャプチャーは名前通り\*thisのコピーキャプチャーを提供する提案だ。同等の機能は初期化キャプチャーでも可能だが、表記が冗長で間違いの元だ。

~~~cpp
struct X
{
    int data ;

    auto f()
    {
        return [ tmp = *this ] { return tmp.data ; } ;
    }
} ;
~~~

機能テストマクロは__cpp_capture_star_this, 値は201603。
