---
author: akira
lang: ja
date: 2009-07-23 11:17:39+00:00
layout: post
title: 画面回転時のフレームバッファの作成しなおし
tags:
- 開発
---

{% app_banner kyoto_summer %}


前回、フレームバッファのサイズを 480x480 で作成しておけば、回転時も問題ないと書いてしまったけど、それは間違いでした。

[【iPhoneでの画面の向きの正しい判定】]({% post_url 2009-07-18-iphone-determine-device-rotation %})

回転時には UIView の


    
```objc
    - (void)layoutSubviews {
    }
```


が呼ばれるので、UIView の frame を再設定して、フレームバッファを作成しなおせば完了。
