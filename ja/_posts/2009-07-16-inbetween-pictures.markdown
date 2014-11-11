---
author: akira
lang: ja
date: 2009-07-16 08:20:37+00:00
layout: post
title: 写真の継ぎ目
tags:
- 開発
---

{% app_banner kyoto_summer %}


[![IMG_0003](http://farm3.static.flickr.com/2604/3726316788_6558d863ff_o.png)](http://www.flickr.com/photos/akiraak/3726316788/)

画像ビューワーのiPhoneアプリを作っていますが、画像をスライドして切り替えるときに、写真と写真との境目がパッキリするのが非常に格好わるい。

そこで、スライド中は境目をぼかすようにしてみました。もちろんスライド後はぼかしが消えます。

技術的には、OpenGLで描画を行っていて、１枚の写真を３枚の四角形ポリゴンで構成し、両はじの２つのアルファ値を0にしています。
