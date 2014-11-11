---
author: akira
lang: ja
date: 2009-10-19 08:45:03+00:00
layout: post
title: iPhone で Crash Reports を利用したバグの発見方法
tags:
- 開発
---

{% app_banner kyoto_autumn %}


### Crash Reports とは


iPhoneアプリ開発者は、開発をおこなったアプリをユーザーが使用している時にクラッシュした場合は、その情報を iTunes connect からDLして観覧する事が可能です。


### Crash Reports の入手方法


iTunes connect に接続し、以下の画像の赤枠のボタンを順番にクリックしていきます。
"Manage Your Applications" -> "App Details" -> "View Crash Reports"

[![crash01](/ja/files/2009/10/crash01-300x185.jpg)](/ja/files/2009/10/crash01.jpg)
[![crash02](/ja/files/2009/10/crash02-300x121.jpg)](/ja/files/2009/10/crash02.jpg)
[![crash03](/ja/files/2009/10/crash03-300x175.jpg)](/ja/files/2009/10/crash03.jpg)

ここまで来るとOSのバージョンごとにレポートを見る事ができます。どうやら OS3.1 で 2 つのバグが出ているようです。今回は 2 つ目の  "PMS2: ms::GLKeyedSprite::setRenderKey + 192 38% of submitted crashes" のバグ修正を行っていきますので、その右の DOWNLOAD ボタンをクリックします。

[![crash04](/ja/files/2009/10/crash04-300x166.jpg)](/ja/files/2009/10/crash04.jpg)


### バグ修正


レポートにはいろいろな情報が書かれていますが、今回は関数呼び出しの履歴の箇所を見ると、一発で原因がわかりました。

    Thread 0 Crashed:
    0   libSystem.B.dylib             	0x32a229ac __kill + 8
    1   libSystem.B.dylib             	0x32a2299c kill
    2   libSystem.B.dylib             	0x32a2298e raise
    3   libSystem.B.dylib             	0x32a3763a abort
    4   libSystem.B.dylib             	0x32a24f30 __assert_rtn
    5   PMS2                          	0x00008d68 ms::GLKeyedSprite::setRenderKey(int const*, unsigned int) + 192
    6   PMS2                          	0x00008bec ms::GLKeyedSprite::setRenderKeyWithCString(char const*) + 228
    7   PMS2                          	0x000174c4 Time::update(unsigned int) + 180
    8   PMS2                          	0x000071bc Scene::update(unsigned int) + 388
    9   PMS2                          	0x00009a94 ms::GLScene::onUpdate() + 36
    10  UIKit                         	0x30d5d574 -[UIView(CALayerDelegate) _layoutSublayersOfLayer:]


自前で実装しているクラス関数 "ms::GLKeyedSprite::setRenderKey()" 中の "assert()" に引っかかりプロセスが殺されています。その前の関数呼び出しが "Time::update()" からなので、アプリ画面の上部に表示している時計を描画している時に問題があるようです。

[![IMG_0210](/ja/files/2009/10/IMG_0210.PNG)]({{ site.data.apps.kyoto_autumn.url }})

"ms::GLKeyedSprite::setRenderKey()" 内の "assert()" を if 文に変更し、引数に問題があってもとりあえず動作するようにします。本来ならそもそも低レベル関数を使用している "Time::update()" あたりのバグを修正することろですが、できるだけユーザーの端末でクラッシュする確率を減らすため、今回は "assert()" を削るという修正になりました。

それでは、よりよいアプリ開発を!!
