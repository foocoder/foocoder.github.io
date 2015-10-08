---
title: github多sshkey管理
categories: github
tags: [github, sshkey, 免密码登陆]
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

对于单个github，还是老方法，先生成sshkey，然后把`publickey` copy 到github的setting > SSH keys中

{% highlight bash %}
cd ~/.ssh
ssh-keygen -t rsa -C "youremail@email.com"
{% endhighlight %}>

其中`-t`是指`type` -- 指定要创建密钥的类型，另一个`-C`是个什么鬼？man一下原来是添加注释，难怪发现网上有的提到，有的没有提到。

之后，我们打开repo的git配置文件`.git/config`，将远程仓库地址改成ssh形式，`git@github.com:user.name/repoName.git`

<p>
以上是单个github帐号进行sshkey登陆的配置。但遇到两个及以上的github的帐号时，一个key显然不能满足两个帐号。
这样就必须用到两个key了。然后在 <code>~/.ssh/config</code> 中添加每个key的声明。
</p>

{% highlight bash %}
Host gi
{% endhighlight %}>
