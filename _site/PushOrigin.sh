#!/bin/sh


# -*- coding: utf-8 -*-
## ---- Program Info Start----
#FileName:     PushOrigin.sh
#
#Author:       Fuchen Duan
#
#Email:        slow295185031@gmail.com
#
#CreatedAt:    2016-03-29 19:01:00
## ---- Program Info End  ----

git add -A
git commit -m "$1"
git push origin master
