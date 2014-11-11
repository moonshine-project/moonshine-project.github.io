---
author: ento
lang: ja
date: 2009-12-01 01:24:26+00:00
layout: post
title: 'GHUnit と NSInvocation を使って非同期通信の単体テストをする'
name: async-testing-ghunit-nsinvocation
tags:
- 開発
---

## 1. 通信への依存を切る


アプリのコンテンツの5段階評価をサーバに送信して保存する機能を作っているとします。例えばこんなコードです:


```objc
@implementation StarService

- (void)star:(NSUInteger)pictureNumber count:(NSUInteger)count {
	// リクエストオブジェクトをつくる
	NSString *url = [NSString stringWithFormat:@"http://%@:%d/api/star/", serviceHostname, servicePort, nil];
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// ... ここで呼び出しパラメータやHTTPヘッダを設定 ...
	StarRequestDelegate *requestDelegate = [[StarRequestDelegate alloc] initWithService:self delegate:serviceDelegate];
	/* API呼び出し開始! */
	NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:aRequest delegate:requestDelegate];
}
...
// API呼び出し用のNSURLConnectionデリゲート
@implementation StarRequestDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (delegate && [(NSObject*)delegate respondsToSelector:@selector(starService:didFinishStar:)]) {
		/* APIが正常に終わったので、デリゲートのコールバックを呼ぶ */
		[delegate starService:service didFinishStar:receivedData];
	}
	[super connectionDidFinishLoading:connection];
}
```

こんなコードを見るとまず作りたくなるのは、同じインターフェイスだけれど、実際はネットワークにアクセスしないクラスです。そうですよね。そうすれば、アプリの他の部分を実装するときも、サーバを立てたりすることなく開発をちゃきちゃき進めることができます。

```objc 
@implementation FakeStarService

- (void)star:(NSUInteger)pictureNumber count:(NSUInteger)count {
	/* デリゲートのコールバックを直接呼び出すNSInvocationをつくる */
	NSInvocation *invocation;
	[[NSInvocation retainedInvocationWithTarget:serviceDelegate invocationOut:&invocation]
	 starService:self didFinishStar:nil];

	/* ネットワーク遅延を装うためにさらにNSInvocationをかぶせる */
	NSInvocation *delayInvocation;
	[[NSInvocation retainedInvocationWithTarget:invocation invocationOut:&delayInvocation]
	 performSelector:@selector(invoke) withObject:nil afterDelay:delay];
	[delayInvocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
}
```

上の例では、偽のネットワーク遅延を実現するために、NSInvocationを2つ使っています。待て待て、NSInvocationを使うのはもっとめんどくさかったはず？その通りです。上のコードは [ForwardedConstruction](http://cocoawithlove.com/2008/03/construct-nsinvocation-for-any-message.html) という拡張の助けを借りて書かれています。

iPhoneでこの拡張を使うには、リンク先からコードをダウンロードした上で、以下の変更を加える必要があります。

```diff
--- Downloads/NSInvocationForwardedConstruction/NSInvocation(ForwardedConstruction).h	2009-05-04 11:55:34.000000000 +0900
+++ NSInvocation(ForwardedConstruction).h	2009-12-02 10:17:07.000000000 +0900
@@ -11,7 +11,7 @@
 //  appreciated but not required.
 //
 
-#import <Cocoa/Cocoa.h>
+#import <UIKit/UIKit.h>
 
 @interface NSInvocation (ForwardedConstruction)
 
@@ -21,3 +21,10 @@
 	invocationOut:(NSInvocation **)invocationOut;
 
 @end
+
+#if (TARGET_OS_IPHONE)
+@interface NSObject (ForwardedConstruction)
+- (NSString *)className;
++ (NSString *)className;
+@end
+#endif
--- Downloads/NSInvocationForwardedConstruction/NSInvocation+ForwardedConstruction.m	2009-05-04 11:55:34.000000000 +0900
+++ NSInvocation(ForwardedConstruction).m	2009-12-02 10:17:43.000000000 +0900
@@ -12,7 +12,9 @@
 //
 
 #import "NSInvocation(ForwardedConstruction).h"
-#import <objc/objc-runtime.h>
+//#import <objc/objc-runtime.h>
+#import <objc/runtime.h>
+#import <objc/message.h>
 
 //
 // InvocationProxy is a private class for receiving invocations via the
@@ -376,4 +378,21 @@
 	return invocationProxy;
 }
 
+@end 
+
+#if (TARGET_OS_IPHONE)
+
+@implementation NSObject (ForwardedConstruction)
+
+- (NSString *)className
+{
+	return [NSString stringWithUTF8String:class_getName([self class])];
+}
++ (NSString *)className
+{
+	return [NSString stringWithUTF8String:class_getName(self)];
+}
+
 @end
+
+#endif
```


## 2. スレッドに注意する


単体テストフレームワークとして、[GHUnit](http://github.com/gabriel/gh-unit)を使います。これは Objective-C 向けのフレームワークで、Mac OS X 10.5 と iPhone 2.x/3.x で動作します。テスト実行用のGUIも付いています。さらに、自分自身を独立したスレッドで動かす機能もあり、これが NSURLConnection がからむテストで効いてきます。

というのも、NSURLConnectionの内部仕様的に、メインスレッド上で接続開始メソッドを呼ばないといけないらしく、テストフレームワークに別スレッドで走ってもらうことで、ネットワーク関連のコードをメインスレッドで動かしつつ、テスト実行用UIもスムーズに使うことができます。

ということで辿り付いたのが以下の構成です:

```objc
// 実際にネットワーク接続するクラスでテストをするクラス。
// 偽クラスをテストするテストクラスも別にある
@implementation HttpNetTest

- (BOOL)shouldRunOnMainThread {
	/* GHUnitは別スレッドで */
	return NO;
}

- (void)test_send_star {
	[tester do_test_send_star:service];
}

@implementation StarServiceTests

- (void)do_test_send_star:(id)service {
	// NSInvocationをつくり、
	NSInvocation *invocation;
	[[NSInvocation retainedInvocationWithTarget:service invocationOut:&invocation]
	  star:0 count:1];
	/* メインスレッドで呼び出す */
	[invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];

	/* 終了を待つ */
	BOOL notTimeout = [AsyncTestHelper wait:service.delegate property:@selector(receivedDidFinishGetStarsCount) atLeast:1];

	/* アサートたち */
	GHAssertTrue(notTimeout, @"Should not timeout");
	GHAssertEquals((NSUInteger)1, [service.delegate receivedDidFinishStarCount], @"delegate should receive star callback");
}
```



## 3. 通信の終了を待つ


非同期通信のテストでやっかいなのが、いつ通信が終了したかを検知する必要がある点です。テストコードでは以下の部分になります。

```objc
@implementation StarServiceTests

- (void)do_test_send_star:(id)service {
	// ..
	[AsyncTestHelper wait:service.delegate property:@selector(receivedDidFinishStarCount) atLeast:1];
	// ..
}
```

このメソッドの中身は、ただ与えられたオブジェクトのプロパティが指定の値以上になるのを待つだけのものです:

```objc 
@implementation AsyncTestHelper

+ (BOOL)wait:(id)target property:(SEL)getter atLeast:(NSUInteger)count {
	int tried = 0;
	while((NSUInteger)[target performSelector:getter]  10) {
			return FALSE;
		}
		[NSThread sleepForTimeInterval:0.5];
	}
	return TRUE;
}
```


テスト実行画面は以下のような感じ。

![ghunit_test_runner](http://img.skitch.com/20091202-rdp1ea91iuxwcjtwpbndua1i9w.png)

最後に、登場したクラス群の関係を示す簡単な図を作ってみました。XcodeのCore Dataモデリングツールを使用しています。

![](http://img.skitch.com/20091122-j6q7axd8up53qb1m1xdaxswrai.png)
