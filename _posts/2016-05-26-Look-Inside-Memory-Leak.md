---
title: 由一道题引起的对内存泄露的思考
date: 2016-05-26
categories: C/C++
tags: [C/C++, OS, Code]
summary:
cover-image: 9.jpg
---

最近遇到了这么一道题：

{% highlight bash %}
使用 char * p = new char[100] 申请一段内存， 然后使用delete p 释放， 有什么问题？

A. 会有内存泄露
B. 不会有内存泄露，但不建议使用
C. 编译就会报错，必须使用delete [] p
D. 编译没问题，运行会直接崩溃

{% endhighlight %}

看了这题目，首先第一感觉不由自主的就选了A。我们通常知道`new/delete` 与`new[]/delete[]`当然需要配对使用，
否则的就会导致内存泄露。这是直观的感觉。

然而第一感觉却往往是不正确的。正确答案是B。瞬间模糊了自己对`new/delete`的概念。虽说最近也在断断续续地看着
《深度探索C++对象模型》以及《Effective C++》，对`new/delete`多少也有些了解。但这道题却让我对`new/delete`的认知
一夜回到了解放前。于是决定透彻的了解下`new/delete`的细节。

首先需要明确的概念是内存泄露(Memory Leak)的概念。

> 在计算机科学中，内存泄漏指由于疏忽或错误造成程序未能释放已经不再使用的内存。内存泄漏并非指内存在物理上的消失，而是应用程序分配某段内存后，由于设计错误，导致在释放该段内存之前就失去了对该段内存的控制，从而造成了内存的浪费。

可以这么说，假设我申请了一块1MB大小的地址，用一个ptr来指向该内存的首地址，但是在程序运行的时候不小心把ptr的值给覆盖掉了，所以现在这块内存的地址我无法获取，所以这块内存就相当于消失了。因为对于OS
的内存管理程序来讲，这块内存是有用的，但是对于程序而言，却缺乏该内存的首地址导致无法使用。

这么看来，我之前理解的`new[]`来分配n块地址然后由`delete[]`来回收n块地址，而`delete`只能回收一块地址，所以导致内存泄露是完全不对的了。
内存泄露是指没有回收但指针却没了。如果`delete`只是回收了第一块地址的话那么后续的地址没被回收，而且指针`p[1],p[2]`仍然存在，这样的话也算不上是内存泄露啊。

那这样的话，为什么很多书上会讲`new/delete`与`new[]/delete[]`不匹配使用的话会导致内存泄露呢？
如果真的导致了内存泄露，那究竟是什么时候会泄露，什么时候不会泄露呢？

看来如果真想了解本质，必须知道`new/delete`究竟干了什么事。

参考来自[@Kelvin](http://kelvinh.github.io/blog/2014/04/19/research-on-operator-new-and-delete/)
大神的博文，我们来看看C++标准库的实现之一Clang的libcxx如何实现`operator new/delete`

{% highlight cpp %}

void * operator new(std::size_t size) throw(std::bad_alloc) {
    if (size == 0)
        size = 1;
    void* p;
    while ((p = ::malloc(size)) == 0) {
        std::new_handler nh = std::get_new_handler();
        if (nh)
            nh();
        else
            throw std::bad_alloc();
    }
    return p;
}

void operator delete(void * ptr) {
    if (ptr)
        ::free(ptr);
}
{% endhighlight %}

由此看来，`new/delete`不过是调用c函数库中系统函数`malloc/free`而已。而对于`new[]/delete[]`也类似

{% highlight cpp %}
void * operator new[](size_t size)
    throw(std::bad_alloc)
{
    return ::operator new(size);
}

void operator delete[] (void * ptr)
{
    ::operator delete(ptr);
}

{% endhighlight %}

因此，`new[]/delete[]`只不过是对`new/delete`的一个调用而已。(Ps: 还是有区别的，其中编译器做了一些工作，下文会详细介绍)。

现在我们再看 char * p = new char[100]; delete p; 整个过程。
其本质是类似这样一种形式。

{% highlight cpp %}
//new
char * p = (char * ) malloc(100 * sizeof(char));

//delete
if(p)
    free(p);
{% endhighlight %}

这样将的话也不会出现内存泄露的问题，那究竟什么时候能出现内存泄露呢？

另一个对`new/delete`的class认知：
对于用户定义class类型，我们对`new`的认知是分三步：

1. 通过malloc来申请一块内存;
2. 在内存上调用构造函数;
3. 返回该class类型的指针。

相对的`delete`是两部：

1. 调用对应的析构函数;
2. 将内存free掉。

那我们提出这样的假设，是不是用户定义的class类型的与内置基本类型的`new[]/delete[]`不一致？
既然有疑问，就需要实验来验证下结果。
我们三组不同类型进行`new[]/delete[]`来查看其内存模型。
这三组类型按照一下标准分类：

1. 内置类型数组(int);
2. POD类型数组;
3. 成员函数包含指向堆的指针class数组,带有构造函数以及析构函数,我们称之为用户定义类型;

代码如下：


{% highlight cpp %}
#include <iostream>
#include <malloc.h>
class POD{
    private:
        int _val[100];
};

class complexStruct{
    public:
        complexStruct():_ptr_val(new int(0xCDCDCDCD)){ }
        ~complexStruct(){
            delete _ptr_val;
        }
    private:
        int * _ptr_val;
};

int main(int argc, char * argv[])
{

    //内置类型数组
    cout<<"\nBEFORE NEW"<<endl;
    malloc_stats();
    int * ptrInt = new int[10]; // malloc 最小内存块32bytes, 每次增加16bytes。需要8bytes的额外空间。
    for(int i=0; i<10; ++i)
        ptrInt[i] = 0xCDCDCDCD;
    cout<<"\nAFTER NEW"<<endl;
    malloc_stats();
    delete ptrInt; //No Memory Leak
    cout<<"\nAFTER DELETE"<<endl;
    malloc_stats();

    //POD类型数组
    cout<<"\nBEFORE NEW"<<endl;
    malloc_stats();
    arrPOD * ptrArrPOD = new arrPOD[10];
    cout<<"\nAFTER NEW"<<endl;
    malloc_stats();
    delete ptrArrPOD; //No Memory Leak
    cout<<"\nAFTER DELETE"<<endl;
    malloc_stats();
    cout<<sizeof(arrPOD) <<endl;

    //用户定义类型数组
    cout<<"\nBEFORE NEW"<<endl;
    malloc_stats();
    complexStruct * ptrComplexStruct = new complexStruct[10];
    cout<<"\nAFTER NEW"<<endl;
    malloc_stats();
    delete ptrComplexStruct; //Memory Leak; 运行到这里会出现segment fault
    cout<<"\nAFTER DELETE"<<endl;
    malloc_stats();
    cout<<sizeof(complexStruct) <<endl;

    return 0;
}
{% endhighlight %}

说明一下，malloc_stats()函数用来查看内存中malloc()申请的内存状况。
另外，程序运行到 delete complexStruct 的时候会segment fault。
我们主要是用gdb来跟踪，然后来查看内存中这些数组的数据。
编译的时候使用`gdb -O0`来关闭优化，防止编译器将一些信息优化掉。
Ps. 每次运行时会将其余部分注释掉，只测试本部分的数据内存模型。

首先对于内置类型(int * ptrInt = new int [10])，在`new[]`之后ptrInt的值是`0x602010`,为了更方便的查看数据，我们将
里边的值都赋为`0xcdcdcdcd`，同过`x/8xg 0x602000`来显示从`0x602000`开始的64bytes的内存如下：

{% highlight cpp %}
0x602000:       0x0000000000000000      0x0000000000000031
0x602010:       0xcdcdcdcdcdcdcdcd      0xcdcdcdcdcdcdcdcd
0x602020:       0xcdcdcdcdcdcdcdcd      0xcdcdcdcdcdcdcdcd
0x602030:       0xcdcdcdcdcdcdcdcd      0x0000000000020fd1
{% endhighlight %}

其中有个问题是ptrInt的开始地址是`0x602010`，但我们为什么要从`0x602000`开始呢？
实际上，`malloc/free`调用的时候每次传过来的指针有个头部信息，该信息一般用来存放32bit
的内存块信息，包括该块的大小以及是否空闲。我们这里的是`0x00000031`，最后一位为1表明
该块被使用，剩下的`0x00000030`表示该块大小为48个bytes。所以通过`malloc`返回的指针实际上
不是你使用的内存的首地址，而是越过了8个字节的头部信息的位置，而`free`的时候自动会将
指针回退8个字节来提取出该内存块的信息。一旦`free`的时候找不到内存块信息则会出现segment fault的错误。(Ps. 最后一句话纯属个人理解)

下面看下POD类型数组的结构发现与内置类型的结果一模一样。

{% highlight cpp %}
0x602000:       0x0000000000000000      0x0000000000000031
0x602010:       0xcdcdcdcdcdcdcdcd      0xcdcdcdcdcdcdcdcd
0x602020:       0xcdcdcdcdcdcdcdcd      0xcdcdcdcdcdcdcdcd
0x602030:       0xcdcdcdcdcdcdcdcd      0x0000000000020fd1
{% endhighlight %}

所以POD的`new[]/delete`也不会导致内存泄露的问题。

接下来看一下用户定义的class数组。这一次`p ptrComplexStruct`的时候发现地址不再是`0x602010`,而成了`0x602018`。
通过`x/32xg 0x602000`来查看从`0x602000`开始的256个bytes内存如下：

{% highlight cpp %}
0x602000:       0x0000000000000000      0x0000000000000061
0x602010:       0x000000000000000a      0x0000000000602070
0x602020:       0x0000000000602090      0x00000000006020b0
0x602030:       0x00000000006020d0      0x00000000006020f0
0x602040:       0x0000000000602110      0x0000000000602130
0x602050:       0x0000000000602150      0x0000000000602170
0x602060:       0x0000000000602190      0x0000000000000021
0x602070:       0x00000000cdcdcdcd      0x0000000000000000
0x602080:       0x0000000000000000      0x0000000000000021
0x602090:       0x00000000cdcdcdcd      0x0000000000000000
0x6020a0:       0x0000000000000000      0x0000000000000021
0x6020b0:       0x00000000cdcdcdcd      0x0000000000000000
0x6020c0:       0x0000000000000000      0x0000000000000021
0x6020d0:       0x00000000cdcdcdcd      0x0000000000000000
0x6020e0:       0x0000000000000000      0x0000000000000021
0x6020f0:       0x00000000cdcdcdcd      0x0000000000000000
{% endhighlight %}

其中`0x00000061`跟之前的`0x00000031`一样是malloc出的内存块的头部，如果按照前种情况来看，说明对于`new`来讲首地址应该是
`0x602010`，而我们发现通过malloc出的内存块在头部之后又添加了一个8 字节的`new`的头部，存放的内容是`0xa`，也就是10，即该
数组的大小。之后从`0x602018`开始才是真正的数据。这样的话也不難理解了。因为我们的class里边含有析构函数，所以`delete[]`的
时候需要将数组中的每个object进行析构，而数组的个数就被存储在整个数组的开头部分，占8个bytes。

那class数组的结构有时包含数组长度，有时不包含数组长度，是通过什么判断的呢？
根据上边我们了解的`delete[]`的过程中可以得知数组长度主要用途是为了`delete[]`时进行析构的，所以我们假设结构的不同跟class是否
含有析构函数有关。

最终得证。如果把用户定义类型class的析构函数注释掉，则其内存模型中数组长度就不存在了。
而如果给POD类型添加一个析构函数，其内存模型也会添加一个数组长度。

好了，现在真相大白。总结一下， 普通的malloc申请的内存会包含一个头部信息存储块的大小以及使用信息，free通过读取这些信息来
进行回收，否则会出现`segment fault`错误(个人理解)， 而对于包含析构函数的的class，`new[]`会对申请的块继续包裹一个头部信息
来存储数组的大小，`delete[]`根据这个大小来一一进行析构。

而对于内存泄露，如果普通的内置类型以及class不包含动态分配的指针的情况下，利用`new[]/delete`组合不会导致内存泄露，因为这本质
跟`malloc/free`是一样的。而如果class中有`new/malloc`动态分配的内存，如果`new[]/delete`的话就会导致内存泄露。这是因为class内部的
内存本身应该由object的析构函数来回收内存，而由于`delete`只会析构一个object，所以其他的objects成员的内存并没有得到回收，但
这些存放指针的内存却被回收了，从而导致了内存泄露。

另外，这个程序为什么会`segment fault`呢？
这是由于对于g++来讲，`new[]`出的内存第一个位置放的是数组长度，所以真正使用的内存的起始位置是在`new[]`得到的指针后边8字节处，
而只有`delete[]`才能读懂这种模型，它会将指针向前回退8个字节，然后将指针传给`free`， 之后`free`会继续回退8字节来查看该内存块的信息。
但是`delete`的话只能将当前位置的指针传给`free`，`free`通过回退8字节后的位置实际上是数组的长度信息，而此时由于`free`获取不到有用的
内存信息从而产生`segment fault`的错误。
