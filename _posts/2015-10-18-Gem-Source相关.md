---
title: Gem Source相关
date: 2015-10-18
categories: Jekyll
tags: [Blog, Jekyll, Gem]
cover-image: 9.jpg
---
之前由于`Markdown`的引擎问题，导致在`md`文件中普通换行就被解析成了一段，导致每次写一段的话得拖的好长好长，但自己又没有那么宽的屏幕，于是把`Markdown`引擎换成了`rdiscount`。
在笔记本上实验成功，分段的话需要空一行。

然后回到实验时`yekyll server`的时候报错了，发现并没有安装`rdiscount`软件包。这个简单，`gem install`一下就可以了。可是可是，事与愿违

{% highlight bash %}
$ gem install rdiscount
ERROR:  Could not find a valid gem 'rdiscount' (>= 0), here is why:
Unable to download data from http://ruby.taobao.org/ - bad response Not Found 404 (http://ruby.taobao.org/specs.4.8.gz)
{% endhighlight %}

看来是`source`出问题了，谷歌一下，讲淘宝已经停止了http协议的镜像服务，使用https协议了，那就改吧。

{% highlight bash %}
$ gem source --remove http://ruby.taobao.org/
$ gem source -a https://ruby.taobao.org/
$ gem install rdiscount
ERROR:  While executing gem ... (Gem::FilePermissionError)
You don't have write permissions for the /var/lib/gems/2.1.0 directory.
{% endhighlight %}

需要`root`用户权限，那就`sudo !!`，可是，老问题又出现了。

{% highlight bash %}
$ sudo !!
$ sudo gem install rdiscount
ERROR:  Could not find a valid gem 'rdiscount' (>= 0), here is why:
Unable to download data from http://ruby.taobao.org/ - bad response Not Found 404 (http://ruby.taobao.org/specs.4.8.gz)
{% endhighlight %}

想起来了，只是给当前用户修改了`source`，`root`用户的`source`还没改呢。好吧，那就继续改掉

{% highlight bash %}
$ sudo gem source --remove http://ruby.taobao.org/
$ sudo gem source -a https://ruby.taobao.org/
$ sudo gem install rdiscount
Fetching: rdiscount-2.1.8.gem (100%)
Building native extensions.  This could take a while...
Successfully installed rdiscount-2.1.8
Parsing documentation for rdiscount-2.1.8
Installing ri documentation for rdiscount-2.1.8
Done installing documentation for rdiscount after 0 seconds
1 gem installed
{% endhighlight %}

现在问题解决了，终于可以启动`jekyll server`了。

不过后来看到`gem source`配置其实都在`~/.gemrc`里边，想修改`source`只要`vim ~/.gemrc`以及`/root/.gemrc`就可以了，真是后知后觉。
