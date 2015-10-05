---
title: Liquid for Designers
categories: 转载
tags: [转载, 翻译, Liquid, 会用得着的]
cover-image: 91.jpg
---

这两天在用jekyll搭博客,一看是liquid语言立刻傻眼了!

话说Liquid是个什么鬼?

不过好在Github上有[文档](http://github.com/Shopify/liquid/wiki/Liquid-for-Designers), 但是可惜是英语的.虽说作为一个Code Monkey来说,英语应该作为第二母语来使用,但我还是尽我所能的去寻找第一母语吧.

功夫不负有心人,让我找到了 [@Havee](http://havee.me)的这篇[Jekyll扩展的Liquid设计](http://havee.me/internet/2013-11/jekyll-liquid-designer.html),虽然这篇也是转自[http://yanshasha.com/2013/01/22/Liquid-for-designers/](http://yanshasha.com/2013/01/22/Liquid-for-designers/),不过可惜原文已挂,为了防止这么好的母语翻译文档继续挂掉,so,我还是转过来吧.

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
* `replace` - 替换每一处匹配字符串,如{% raw %}{{ 'foofoo'\|replace:'foo','bar' }}{% endraw %}#=>{{ 'foofoo' | replace:'foo','bar' }}
