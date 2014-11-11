---
author: akira
lang: ja
date: 2009-07-18 00:32:24+00:00
layout: post
title: iPhoneでの画面の向きの正しい判定
tags:
- 開発
---

{% app_banner kyoto_summer %}


UIViewController を継承したクラスに以下のコードを書く事で、iPhoneの向きが自動で取得ができる。XCode で OpenGL のテンプレートから作成した場合は、UIViewController を自前で作成し間に挟む事。

    
```objc
//----------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
//----------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			// 縦向きでホームボタンが下
		case UIInterfaceOrientationPortraitUpsideDown:
			// 縦向きでホームボタンが上
			break;
		case UIInterfaceOrientationLandscapeLeft:
			// 横向きでホームボタンが左
		case UIInterfaceOrientationLandscapeRight:
			// 横向きでホームボタンが右
			break;
	}
}
//----------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
}
```


willRotateToInterfaceOrientation は回転開始時に呼ばれ toInterfaceOrientation には回転後の方向が入るが、didRotateFromInterfaceOrientation は回転後に呼ばれ fromInterfaceOrientation には回転前の方向が入るので、最終的な方向を知りたいなら toInterfaceOrientation で判定しなければならない。

<del>また、OpenGLのビューは自動で正しい方向に回転されるため、フレームバッファのサイズを480x480で作成してしまえば回転の対応も楽かもしれない。</del>

[画面回転時のフレームバッファの作成し直しはこちらで説明
]({% post_url 2009-07-23-recreating-frame-buffer-on-rotation %})
