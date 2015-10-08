---
title: Liquid for Designers
categories: 转载
tags: [转载, 译文, Liquid, 不时之需]
cover-image: 9.jpg
---

这两天在用jekyll搭博客,一看是liquid语言立刻傻眼了!

话说Liquid是个什么鬼?

不过好在Github上有[文档](http://github.com/Shopify/liquid/wiki/Liquid-for-Designers), 但是可惜是英语的.虽说作为一个Code Monkey来说,英语应该作为第二母语来使用,但我还是尽我所能的去寻找第一母语吧.

功夫不负有心人,让我找到了 [@Havee](http://havee.me)的这篇[Jekyll扩展的Liquid设计](http://havee.me/internet/2013-11/jekyll-liquid-designer.html),虽然这篇也是转自[http://yanshasha.com/2013/01/22/Liquid-for-designers/](http://yanshasha.com/2013/01/22/Liquid-for-designers/),不过可惜原文已挂,为了防止这么好的母语翻译文档继续挂掉,so,我还是转过来吧,以备不时之需.

> <center>原文:Jekyll扩展的Liquid设计</center>

在Liquid中有两种类型的标记:`Output`和`Tag`.

* `Output`标记(有些可能解析文本)被包含在:

{% highlight liquid %}
{% raw %}
{{ 两个配对的花括号中 }}
{% endraw %}
{% endhighlight %}

* `Tag`标记(不能被解析文本)被包含在:

{% highlight liquid %}
{% raw %}
{% 成对的花括号和百分号中 %}
{% endraw %}
{% endhighlight %}

## Output ##
---
下面是关于输出标记的简单实例:

{% highlight liquid %}
{% raw %}
Hello {{ name }}
Hello {{ user.name }}
Hello {{ 'tobi' }}
{% endraw %}
{% endhighlight %}

### 高级输入:过滤器 ###
输入标记带有过滤器,方法很简单.第一个参数总是过滤器左边值的输出.当下个过滤器运行时,刚刚所得到的过滤器的返回值就会成为新的左边值.知道最后没有过滤器时,模板就会接受最后的结果字符串.

{% highlight liquid %}
{% raw %}
Hello {{ 'tobi' | upcase }}
Hello tobi has {{ 'tobi' | size }} letters
Hello {{ 'tobi' | capitalize }}
Hello {{ '1982-02-01' | date:"%Y" }}
{% endraw %}
{% endhighlight %}

输出的结果是:

{% highlight liquid %}
Hello {{ 'tobi' | upcase }}
Hello tobi has {{ 'tobi' | size }} letters
Hello {{ 'tobi' | capitalize }}
Hello {{ '1982-02-01' | date:"%Y" }}
{% endhighlight %}

### 标准过滤器 ###

* `data` - 格式化日期
* `capitalize` - 将输入语句的首字母大写
* `downcase` - 将输入字符串转为小写
* `upcase` - 将输入字符串转为大写
* `first` - 获取传递数组的第一个元素
* `last` - 获取传递数组的最后一个元素
* `join` - 将数组中元素连成一串,中间通过某些字符分隔
* `sort` - 对数组元素进行排序
* `map` - 从一个给定属性中映射/收集一个数组
* `size` - 返回一个数组或字符串的大小
* `escape` - 对一串字符串进行编码
* `escape_once` - 返回一个转义的html版本,而不影响现有的转义文本
* `strip_html` - 去除一串字符串中的所有html标签
* `strip_newlines` - 从字符串中去除所有换行符(\n)
* `newline_to_br` - 将所有的换行符(\n)换成html的换行标记
* `replace` - 替换每一处匹配字符串,如:{% raw %}`{{ 'foofoo'|replace:'foo','bar' }}`{% endraw %} #=> `{{ 'foofoo' | replace:'foo','bar' }}`
* `replace_first` - 替换第一处匹配字符串,如:{% raw %}`{{ 'barbar'|replace_first:'bar','foo' }}`{% endraw %} #=> `{{ 'barbar' | replace_first:'bar','foo' }}`
* `remove` - 删除每一处匹配的字符串,如:{% raw %}`{{ 'foobarfoobar'|remove:'foo' }}`{% endraw %} #=> `{{ 'foobarfoobar'|remove:'foo' }}`
* `remove_first` - 删除第一处匹配的字符串，如:{% raw %}`{{ 'barbar'|remove_first:'bar' }}`{% endraw %} #=> `{{ 'barbar'|remove_first:'bar' }}`
* `truncate` - 将一串字符串截断其前x个字符,而且，也可以在第二个参数上来为其追加字符，如:{% raw %} `{{ 'foobarfoobar'|truncate:5,'.' }}`{% endraw %} #=> `{{ 'foobarfoobar'|truncate:5,'.' }}`
* `truncatewords` - 将一串字符串截断其前x个单词
* `prepend` - 在一串字符串前添加指定字符串,如:{% raw %}`{{ 'bar'|prepend:'foo' }}`{% endraw %} #=> `{{ 'bar'|prepend:'foo'}}`
* `append` - 在一串字符串后添加指定字符串，如:{% raw %}`{{ 'foo'|append:'bar' }}`{% endraw %} #=> `{{ 'foo'|append:'bar' }}`
* `slice` - 切割字符串，需要输入切割位置以及切割长度(暂不支持)，如:{% raw %}`{{ 'hello'|slice:-3,3 }}`{% endraw %} #=> `{{ 'hello'|slice:-3,3 }}`
* `minus` - 减法运算，如:{% raw %}`{{ 4|minus:2 }}`{% endraw %} #=> `{{ 4|minus:2 }}`
* `plus` - 加法运算，如:{% raw %}`{{ '1'|plus:'1' }}`{% endraw %} #=> `{{ '1'|plus:'1' }}`
* `times` - 乘法运算，如:{% raw %}`{{ 5|times:4 }}`{% endraw %} #=> `{{ 5|times:4 }}`
* `divided_by` - 整型除法，如:{% raw %}`{{ 10|divided_by:3 }}`{% endraw %} #=> `{{ 10|divided_by:3 }}`
* `round` - 将输入的数近似到最接近的整数或者指定小数点后面的位数(暂不支持)
* `split` - 将一串字符串根据匹配模式分割成数组，如:{% raw %}`{{ 'a~b'|split:'~' }}`{% endraw %} #=> `{{ 'a~b'|split:'~' }}`
* `modulo` - 取余，如:{% raw %}`{{ 3|modulo:2 }}`{% endraw %} #=> `{{ 3|modulo:2 }}`

## Tags ##
---
`tags`用于你的模板中的逻辑，新的标签很容易开发，因此我希望在发布这些代码以后，大家可以为标准标签库增加更多的内容。
下列是当前已经支持的标签：

* **assign** - 将一些值赋给一个变量
* **capture** - 块标记，把一些文本捕捉到一个变量中
* **case** - 块标记，标准的case语句
* **comment** - 块标记，将一块文本作为注释
* **cycle** - Cycle通常用于循环轮换值，如颜色或DOM类
* **for** - 用于循环`for...loop`
* **break** - 退出for循环
* **continue** - 跳过当前循环剩下语句，执行下一次循环
* **if** - 标准if/else区块
* **include** - 包含其他模板，对于区块化非常有效
* **raw** - 暂时性的禁用标签解析
* **unless** - if语句的简版

### 注释 ###

{% raw %}任何被包含在`{% comment %}`以及`{% endcomment %}`之间的语句被解析为注释，也就是说这些语句不会被显示出来{% endraw %}

{% highlight liquid %}
{% raw %}
We made 1 million dollars {% comment %} in losses {% endcomment %} this year
{% endraw %}
{% endhighlight %}

输出的结果是：

{% highlight liquid %}
We made 1 million dollars {% comment %} in losses {% endcomment %} this year
{% endhighlight %}

### Raw ###

`raw`会暂时性的禁用对标签的解析功能。这在需要展示一些可能产生冲突的内容（如下代码中，要展示liquid语句，就需要包含在`raw`标签之间，否则就会被解析）时非常有用。

{% highlight text %}
{{ "{% raw "}}%}
{% raw %}
    In Handlebars,{{ this  }} will be HTML-eacaped, but {{{ that }}} will not.
{% endraw %}
{{ "{% endraw "}}%}
{% endhighlight %}

### if/else ###

`if/else`在其他编程语言里应该已经被熟知了。Liquid使得你可以通过`if`或`unless`(`elsif`和`else`为可选)编写简单的表达式：

{% highlight liquid %}
{% raw %}

{% if user %}
  Hello {{ user.name }}
{% endif %}

# Same as above
{% if user != null %}
  Hello {{ user.name }}
{% endif %}

{% if user.name == 'tobi' %}
  Hello tobi
{% elsif user.name == 'bob' %}
  Hello bob
{% endif %}

{% if user.name == 'tobi' or user.name == 'bob' %}
  Hello tobi or bob
{% endif %}

{% if user.name == 'bob' and user.age > 45 %}
  Hello old bob
{% endif %}

{% if user.name != 'tobi' %}
  Hello non-tobi
{% endif %}

# Same as above
{% unless user.name == 'tobi' %}
  Hello non-tobi
{% endunless %}

# Check for the size of an array
{% if user.payments == empty %}
   you never paid !
{% endif %}

{% if user.payments.size > 0  %}
   you paid !
{% endif %}

{% if user.age > 18 %}
   Login here
{% else %}
   Sorry, you are too young
{% endif %}

# array = 1,2,3
{% if array contains 2 %}
   array includes 2
{% endif %}

# string = 'hello world'
{% if string contains 'hello' %}
   string includes 'hello'
{% endif %}

{% endraw %}
{% endhighlight %}

### Case语句 ###

如果你需要更多的条件判断，你可以使用 `case` 语句:

{% highlight liquid %}
{% raw %}
{% case condition %}
    {% when 1 %}
        hit 1
    {% when 2 or 3 %}
        hit 2 or 3
    {% else %}
        ... else ...
{% endcase %}
{% endraw %}
{% endhighlight %}

Example:

{% highlight liquid %}
{% raw %}
{% case template %}
    {% when 'label' %}
        // {{ label.title }}
    {% when 'product' %}
        // {{ product.vendor | link_to_vendor }} / {{ product.title }}
    {% else %}
        // {{page_title}}
{% endcase %}
{% endraw %}
{% endhighlight %}

### Cycle ###

我们常常需要在不同的颜色或类似的任务间轮流切换。Liquid 对于这样的操作有内置支持，通过使用 `cycle` 标签。

{% highlight liquid %}
{% raw %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% endraw %}
{% endhighlight %}

输出结果是

{% highlight liquid %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% endhighlight %}

如果一组 `cycle` 没有命名，那默认情况下有用相同参数的会被认为是一个组。
如果你希望完全控制 `cycle` 组，你可以指定一个组名，这个组名甚至可以是一个变量。

{% highlight liquid %}
{% raw %}
{% cycle 'group 1': 'one', 'two', 'three' %}
{% cycle 'group 1': 'one', 'two', 'three' %}
{% cycle 'group 2': 'one', 'two', 'three' %}
{% cycle 'group 2': 'one', 'two', 'three' %}
{% endraw %}
{% endhighlight %}

输出结果是：

{% highlight liquid %}
{% cycle 'group 1': 'one', 'two', 'three' %}
{% cycle 'group 1': 'one', 'two', 'three' %}
{% cycle 'group 2': 'one', 'two', 'three' %}
{% cycle 'group 2': 'one', 'two', 'three' %}
{% endhighlight %}

### 循环 ###

Liquid 允许循环一个集合 :

{% highlight liquid %}
{% raw %}
{% for item in array %}
    {{ item }}
{% endfor %}
{% endraw %}
{% endhighlight %}

而当迭代循环一个哈希表时，`item[0]`存放的是key，`item[1]`存放的是value：

{% highlight liquid %}
{% raw %}
{% for item in hash %}
  {{ item[0] }}: {{ item[1] }}
{% endfor %}
{% endraw %}
{% endhighlight %}

在每次循环期间，下列的帮助变量都可用于额外的展示需要:

{% highlight liquid %}
{% raw %}
forloop.length      # => length of the entire for loop
forloop.index       # => index of the current iteration
forloop.index0      # => index of the current iteration (zero based)
forloop.rindex      # => how many items are still left?
forloop.rindex0     # => how many items are still left? (zero based)
forloop.first       # => is this the first iteration?
forloop.last        # => is this the last iteration?
{% endraw %}
{% endhighlight %}

你可以使用一些属性来影响接受循环中的哪项。
`limit:int` 使你可以限制接受的循环项个数；`offset:int` 可以可以让你从循环集合的第 n 项开始.

{% highlight liquid %}
{% raw %}
# array = [1,2,3,4,5,6]
{% for item in array limit:2 offset:2 %}
    {{ item }}
{% endfor %}
# results in 3,4
{% endraw %}
{% endhighlight %}

反转循环

{% highlight liquid %}
{% raw %}
{% for item in collection reversed %}
    {{item}}
{% endfor %}
{% endraw %}
{% endhighlight %}

除了对一个已经存在的集合进行循环，你还可以定义一段范围区域内的数字进行循环。这段区域既可以通过文字也可以通过变量数定义得到:

{% highlight liquid %}
{% raw %}
# if item.quantity is 4...
{% for i in (1..item.quantity) %}
    {{ i }}
{% endfor %}
# results in 1,2,3,4
{% endraw %}
{% endhighlight %}

一个`for`循环可以通过`else`语句来处理当集合中不存在元素的情况：

{% highlight liquid %}
{% raw %}
# items => []
{% for item in items %}
   {{ item.title }}
{% else %}
   There are no items!
{% endfor %}
{% endraw %}
{% endhighlight %}

### 变量赋值 ###

你可以把数据存储在你自己定义的变量中，以便在输出或者其他标签中使用。创建一个变量的最简单方式是使用 `assign` 标签，其语法也是简单明了的：

{% highlight liquid %}
{% raw %}
{% assign name = 'freestyle' %}

{% for t in collections.tags %}
    {% if t == name %}
        <p>Freestyle!</p>
    {% endif %}
{% endfor %}
{% endraw %}
{% endhighlight %}

另一种常见用法是把 `true/false` 值赋给变量:

{% highlight liquid %}
{% raw %}
{% assign freestyle = false %}

{% for t in collections.tags %}
    {% if t == 'freestyle' %}
        {% assign freestyle = true %}
    {% endif %}
{% endfor %}

{% if freestyle %}
    <p>Freestyle!</p>
{% endif %}
{% endraw %}
{% endhighlight %}

如果你希望把一系列字符串连接为一个字符串，并将其存储到变量中，你可以使用 `capture` 标签。这个标签是一个块级标签，它会 captures 任何在其中渲染的元素，并把捕获的值赋给给定的变量，而不是把这些值渲染在页面中。

{% highlight html %}
{% raw %}
{% capture attribute_name %}{{ item.title | handleize }}-{{ i }}-color{% endcapture %}

<label for="{{ attribute_name }}">Color:</label>
<select name="attributes[{{ attribute_name }}]" id="{{ attribute_name }}">
  <option value="red">Red</option>
  <option value="green">Green</option>
  <option value="blue">Blue</option>
</select>
{% endraw %}
{% endhighlight %}
