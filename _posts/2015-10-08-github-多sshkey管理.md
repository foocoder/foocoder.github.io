---
title: Github多sshkey管理
date: 2015-10-08
categories: Github
tags: [Github, ssh, 免密码登陆]
cover-image: 9.jpg
---

<p>
断断续续的牺牲了一个十一黄金周的时间，终于配置好了这个blog，
虽说还有一些不足之处，留着以后再来逐步的完善就好。可是这个blog被妹子给瞧见了，
非要也给她也搭一个。好吧，还好这个repo已经建好，直接给clone过去就OK了，倒是省了不少事。
</p>

<p>
但是，这时候问题却出现了，之前一直只用一个github帐号，完全可以用一个sshkey来登陆github.
不过现在要管理两个帐号， <code>push</code> 以及 <code>pull</code>就不成了。但一直输入密码跟帐号也不是问题啊.还是看看怎么解决吧。
</p>

## 单个github帐号免密码登陆 ##

对于单个github，还是老方法，先生成sshkey，然后把`publickey` copy 到github的setting > SSH keys中

{% highlight bash %}
cd ~/.ssh
ssh-keygen -t rsa -C "youremail@email.com"
{% endhighlight %}

其中`-t`是指`type` -- 指定要创建密钥的类型，另一个`-C`是个什么鬼？man一下原来是添加注释，难怪发现网上有的提到，有的没有提到。

之后，我们打开repo的git配置文件`.git/config`，将远程仓库地址改成ssh形式，`git@github.com:user.name/repoName.git`

当然，在`git commit`之前还要通过`git config`来设置user.name以及user.email。如果只是单个帐号的话global模式会比较方便，而多个帐号只能设置成local模式。

## 多个github帐号管理 ##

<p>
以上是单个github帐号进行sshkey登陆的配置。但遇到两个及以上的github的帐号时，一个key显然不能满足两个帐号。
这样就必须用到两个key了。同样我们需要利用<code>ssh-keygen</code>来生成每一个帐号的sshkey,当然此时不能一路回车了，要为每个帐号的sshkey分别命名。
由于不是默认的名称，所以我们需要 <code>ssh-add</code> 来添加每一个会用到的sshkey。
哦，对了，如果之前设置了<code>git config --global</code>,现在必须<code> git config --global --unset</code>掉，然后为每个repo设置local的<code>user.name</code>以及<code>user.email</code>.
</p>

{% highlight bash %}
ssh-add ~/.ssh/id_rsa1
ssh-add ~/.ssh/id_rsa2
{% endhighlight %}

然后在 <code>~/.ssh/config</code> 中添加每个帐号的Host信息。

{% highlight vim %}
Host user1.github.com
HostName github.com
User git
IdentityFile ~/.ssh/id_rsa1

Host user2.github.com
HostName github.com
User git
IdentityFile ~/.ssh/id_rsa2
{% endhighlight %}

好了，现在就可以测试是否可以链接了。

{% highlight shell-session %}
ssh -T user1.github.com
Hi user1! You've successfully authenticated, but GitHub does not provide shell access.
ssh -T user2.github.com
Hi user2! You've successfully authenticated, but GitHub does not provide shell access.
{% endhighlight %}

如上显示，便表示链接成功了。

现在我们需要将每个仓库下的配置改成相应`Host`的形式了，改成如下所示

{% highlight bash %}
url=user1.github.com:user.name/repoName.git
url=user2.github.com:user.name/repoName.git
{% endhighlight %}

自此以后，就可以`git push`了。
