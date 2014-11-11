---
author: ento
lang: ja
date: 2010-03-14 03:58:05+00:00
layout: post
title: CALayerの好きなプロパティをアニメーションさせる
name: implicit-animation-of-custom-calayer-properties
tags:
- 開発
---

iPhone 上の描画システムとして、弊社ではこれまで UIKit、OpenGL を使ってきました。 UIKit を使ったのは最初のアプリだけで、パフォーマンス上の理由からそれ以降のアプリはすべて OpenGL で描画しています。

しかし先週から開始した次のアプリの開発では、Quartz と Core Animation を使ってみています。簡単な時計アプリになる予定で、これらのフレームワークでどこまでできるかの試作段階といったところです。その中で 1 つ、詰まった点があったので紹介します。

それはというと、時計の針を描画するところまではよかったのですが、その角度を変えながらアニメーションさせるところで行き詰まったのです。CALayer の「アニメーション可能なプロパティ」 animatable properties (不透明度やサイズなどが含まれます) ならば、値を変えるだけで自動的にアニメーション implicit animation が実行されます。時計の針の角度のような、自分で定義したプロパティでもそれをするにはどうすれば?

Google 検索に 3 時間お付き合いいただいた結果、iPhone OS 3.0 以降なら、CALayer の needsDisplayForKey: クラスメソッドで「変更されたら再描画が必要になるプロパティ」を指定できること、actionForKey: メソッドで「変更されたら実行するアクション (アニメーション)」を指定できることが分かりました。ここまでは簡単に調べられたのですが、時計の針をアニメーションさせるにはもう 1 つ注意すべきことがありました。こちらは後で紹介します。

まずはソースコードを見てみましょう。

はじめに、時計の針用のレイヤーを作るコードです:


```objc
@implementation ClockView

- (void)awakeFromNib {
    [self setupLayers];
    [self start];
}

- (void)start {
    // tick メソッドを呼び出すタイマーを作成
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 
        target:self
        selector:@selector(tick)
        userInfo:nil
        repeats:YES];
    self.animationTimer = timer;
}

- (void)setupLayers {
    /*
     各針用のレイヤーを追加。
     angle を変化させてアニメーションする。
     */
    {
        HandLayer *hand = [[HandLayer alloc] init];
        hand.frame = self.frame;
        self.secondHand = hand;
        [hand release];
        [self.layer addSublayer:self.secondHand];
    }
    // ...
}

- (void) tick {
    // 各針に新しい角度を通知
}
```



ここまでは大したことはありませんね。次がこの記事の心臓、アニメーション部分です:


```objc 
@interface HandLayer : CALayer {
}

@property CGFloat angle;

@end


@implementation HandLayer

@dynamic angle;

+ (BOOL)needsDisplayForKey:(NSString*)aKey {
    // angle が変わったら再描画がいるよ
    if ([aKey isEqualToString:@"angle"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:aKey];
    }
}

- (id)actionForKey:(NSString *) aKey {
    if ([aKey isEqualToString:@"angle"]) {
        // angle 用の補間アニメーションを作る
        CABasicAnimation *theAnimation = [CABasicAnimation
            animationWithKeyPath:aKey];
        // 注意: fromValue を設定しないと正しくアニメーションしない
        theAnimation.fromValue = [[self presentationLayer] valueForKey:aKey];
        return theAnimation;
    } else {
        return [super actionForKey:aKey];
    }
}

- (void)drawInContext:(CGContextRef)context {
    // angle プロパティを参照しながら針を描画
}
```



theAnimation.fromValue を現在表示中の針の角度に設定していることに注意してください。これがドキュメントを探しても見つけられなかったポイントです。解決できたのは、[Omni Group のブログ記事 "Animating CALayer content"](http://www.omnigroup.com/blog/entry/Animating_CALayer_content)のおかげでした。その当時は自分で needsDisplayForKey: 周辺の仕組みを実装しないといけなかったんですね。

最後に、動画をどうぞ:

{% youtube 4rcE0kOrjVA %}

※ 動画中の針のアニメーションは、アニメーションのローカル時間を決める関数 timingFunction にデフォルトの線形タイプではなく kCAMediaTimingFunctionEaseIn を使っています。

参考:

  
  * [Core Animation Programming Guide](http://developer.apple.com/mac/library/documentation/cocoa/conceptual/CoreAnimation_guide/Introduction/Introduction.html)

  
  * [CALayer needsDisplayForKey:](http://developer.apple.com/mac/library/documentation/GraphicsImaging/Reference/CALayer_class/Introduction/Introduction.html#//apple_ref/occ/clm/CALayer/needsDisplayForKey:)

  
  * [CALayer actionForKey:](http://developer.apple.com/mac/library/documentation/GraphicsImaging/Reference/CALayer_class/Introduction/Introduction.html#//apple_ref/occ/instm/CALayer/actionForKey:)



追記:
実際に実行されている補間アニメーションの開始値 fromValue → 終了値 toValue / 増加値 byValue をログに出してみました。

```
2010-03-13 11:12:41.179 app[14615:207] angle \
<CABasicAnimation: 0x3b02620>, 6.283185 -> (null) / (null)
```



fromValue が設定されていて、その他は設定されていないのが分かります。終了値が設定されていないのにどうやって補間しているのかは謎です...。
