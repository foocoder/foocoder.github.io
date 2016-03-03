---
title: Stack vs Heap
date: 2016-03-03
categories: C/C++
tags: [译文, C/C++, Linux, 内存]
summary:
cover-image: 9.jpg
---

关于操作系统的内存管理方面有很多文献，最主要的方面在于`Stack`与`Heap`之间的区别与联系。
这里翻译一篇[gribblelab.org](http://gribblelab.org/CBootcamp/7_Memory_Stack_vs_Heap.html)的教程，对`Stack`于`Heap`有个初步的了解。

简单的介绍下文章的结构

* [Stack vs Heap](#part1)
* [The Stack](#part2)
* [The Heap](#part3)
* [Stack vs Heap Pros and Cons](#part4)
    * [Stack](#part4_1)
    * [Heap](#part4_2)
* [Examples](#part5)
* [When to use the Heap?](#part6)
* [Links](#part7)

## <span id="part1">Stack vs Heap</span> ##

一般来讲，`Stack`即为栈，`Heap`即为堆。
两者分别是`C/C++`内存管理过程中的两大不同类型的存储空间。

## <span id="part2">The Stack</span> ##

什么是`Stack`？它是内存中用来存储程序执行过程中各个函数(也包括`main`函数)创建的临时变量的区域。
`Stack`字如其名，其本质的结构就是数据结构中的`stack`类型。
它是一种`FILO`(先入后出)类型的数据结构，这里的`Stack`完全由CPU进行操作与维护。
每当一个函数声明一个新临时变量的时候，系统会将这个变量`push`到`Stack`里边中去。
而一旦一个函数执行完毕退出的时候，所有的由该函数创建的临时变量会被`pop`出来，也就是说该变量的生存周期已经到期被删除了。
而本来存放该变量的`Stack`区域就可以重新被`Push`一个新的变量。

使用`Stack`的最大的优势在于，`Stack`的内存的管理由CPU来进行操作，并不需要你来操心。
你可以不用手动的分配内存，释放内存，因为这些工作都已经被CPU做了。
而且CPU操作的方式会更加高效，从而使用`Stack`方式来读写变量的速度会很快的。

要理解`Stack`最关键的一点是理解一旦一个函数退出，其所有的临时变量都会被从`Stack`中`Pop`出来。
因此本质上`Stack`中的变量都是`Local`的。
与之相对应的概念就是`Variable scope`，我们称之为变量的生命周期，或者说`local`与`global`的概念。
C程序中经常遇到的一个Bug就是尝试从一个函数的外边访问该函数内部的变量或者当该函数退出后访问其内部变量。

另外一个需要注意的是`Stack`的总的存储空间是有限制的，如果超出该存储大小会出现`Stack Overflow`的错误而导致Crash。

总结起来如下几点：

* `Stack`里的存储的内容会随着函数`push`或`pop`局部变量而增加缩小。
* `Stack`中不需要我们来手动的管理内存，变量的分配与内存的释放都是系统进行。
* `Stack`有着大小的限制，具体大小跟操作系统有关。
* `Stack Variables`只有当创建该变量的函数运行时才有效。

## <span id="part3">The Heap</span> ##

`Heap`则是内存中可以由程序员来管理的变量存储区域。相对于`Stack`而言，`Heap`有着更大的自由性。
要想分配内存空间，你可以用`malloc()`函数或者`calloc()`函数来申请空闲空间。
而当我们使用完内存，也必须通过`free()`函数来释放掉已经分配好的空间。
也就是说`malloc`要有与之相对的`free`来对应。
否则的话就会导致`Memory Leak`的现象。
因为我们申请的空间没有被释放，所以这块空间会一直被占用而得不到重新利用。
我们通常利用`valgrind`这个工具来检测程序有没有`memory leak`的现象。

与`Stack`不同的是，`Heap`的大小都没有限制。
但一般而言，`Heap`上变量的读取速度相对`Stack`是有点慢的。
因为从底层考虑，`Heap`需要利用指针来访问内存的数据，而`Stack`直接访问就可以了。
间接访问总会比直接访问多一些指令。

另外一点与`Stack`不同的是，`Heap`上的变量可以由任何函数访问到，也就是说`Heap`上的变量本质上全局的。
但前提是你得有指向`Heap`区域的地址。

## <span id="part4">Stack vs Heap Pros and Cons</span> ##

### <span id="part4_1">Stack</span> ###

* 快速访问
* 不需要显式回收变量，释放内存
* 内存空间可以由CPU来进行高效管理，不会出现碎片
* 只针对局部变量
* 大小有限制
* 变量空间的大小不能改变

### <span id="part4_2">Heap</span> ###

* 变量可以在全局访问到
* 对内存大小没有限制
* 相对较慢的访问速度
* 空间的利用率不能被保障，可能由于内存的不断分配释放导致空间不连续产生碎片
* 程序员需要手动管理内存(申请释放空间)
* 变量空间大小可以通过`realloc`函数来重新分配大小

## <span id="part5">Examples</span> ##

一个关于`Stack`的小例子。

{% highlight cpp %}

#include <stdio.h>

double multiplyByTwo (double input) {
  double twice = input * 2.0;
  return twice;
}

int main (int argc, char * argv[])
{
  int age = 30;
  double salary = 12345.67;
  double myList[3] = {1.2, 2.3, 3.4};

  printf("double your salary is %.3f\n", multiplyByTwo(salary));

  return 0;
}

{% endhighlight %}

{% highlight bash %}
double your salary is 24691.340
{% endhighlight %}

`main`函数里前三行分别定义了一个`int`，一个`double`以及一个三元素的`double`数组。
这三个变量会在`main`函数中被`push`到`Stack`区间。
一旦`main`函数退出程序结束，这些变量便会被从`Stack`中`pop`出来而删除。
同样的函数`multiplyByTwo`，在被调用的时候两个`double`变量会被`push`到`Stack`中去。
而当函数执行完毕，这两个变量也从而被`pop`出来删除了。

另外有个特例就是`static`变量。`static`变量并不会被存放在`Stack`上，而是存放到内存区域的`data`与`bss`区域。
因为静态变量并不随着其创建函数的退出而消亡，因此不能放置到`Stack`区域上。

下面一个关于`Heap`的小例子。

{% highlight cpp %}
#include <stdio.h>
#include <stdlib.h>

double * multiplyByTwo (double * input) {
  double * twice = malloc(sizeof(double));
  *twice = *input * 2.0;
  return twice;
}

int main (int argc, char * argv[])
{
  int * age = malloc(sizeof(int));
  * age = 30;
  double * salary = malloc(sizeof(double));
  * salary = 12345.67;
  double * myList = malloc(3 * sizeof(double));
  myList[0] = 1.2;
  myList[1] = 2.3;
  myList[2] = 3.4;

  double * twiceSalary = multiplyByTwo(salary);

  printf("double your salary is %.3f\n", *twiceSalary);

  free(age);
  free(salary);
  free(myList);
  free(twiceSalary);

  return 0;
}
{% endhighlight %}

我们利用`malloc`来申请`Heap`上的空闲空间然后用`free`来释放不需要的空间。

## <span id="part6">When to use the Heap</span> ##

When should you use the heap, and when should you use the stack?
If you need to allocate a large block of memory (e.g. a large array, or a big struct), and you need to keep that variable around a long time (like a global), then you should allocate it on the heap.
If you are dealing with relatively small variables that only need to persist as long as the function using them is alive, then you should use the stack, it's easier and faster.
If you need variables like arrays and structs that can change size dynamically (e.g. arrays that can grow or shrink as needed) then you will likely need to allocate them on the heap, and use dynamic memory allocation functions like malloc(), calloc(), realloc() and free() to manage that memory "by hand".
We will talk about dynamically allocated data structures after we talk about pointers.

## <span id="part7">Links</span> ##

* [The Stack and the Heap](http://www.learncpp.com/cpp-tutorial/79-the-stack-and-the-heap/)
* [What and Where are the stack and heap](http://stackoverflow.com/questions/79923/what-and-where-are-the-stack-and-heap)



