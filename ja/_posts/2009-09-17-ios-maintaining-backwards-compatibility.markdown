---
author: akira
lang: ja
date: 2009-09-17 10:51:11+00:00
layout: post
title: 「京都 夏」におけるiPhoneアプリで下位互換を維持する手法
tags:
- 開発
---

{% app_banner kyoto_summer %}


### OS別普及率



「京都　夏」の開発当時、最新の iPhone OS は 3.0 でした。3.0 からはアプリ内でマップを表示できる機能が追加されたため、この機能を使い、写真から地図を表示するという機能を実装する事にしました。しかし、OS バージョン別の普及率を調べてみると、2.2.1 が圧倒的に多く、これでは購入者を大幅に減らせてしまうと思いました。

こちらのサイトで OS バージョン別の普及率が出ています。
[iPhoneOS percentages 08/2009](http://www.sunflat.net/en/iphoneoscount/200908.html)
![](http://chart.apis.google.com/chart?chs=600x400&cht=bvs&chds=-300,0&chbh=14,2&chg=0,10,1,0&chtt=www.sunflat.net|08%2F2009&chco=0080ff,00ffff,00ff00,ff8000,ff0000,404080,008080,008000,804000,808080&chdl=iPhone+2_1|iPhone+2_2|iPhone+2_2_1|iPhone+3_0|iPhone+3_0_1|iPod+2_1_1|iPod+2_2|iPod+2_2_1|iPod+3_0|others&chxt=x&chxl=0:|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31&chd=t:-3,-2,-3,-2,-2,-2,-2,-2,-2,-3,-3,-2,-2,-2,-2,-3,-3,-2,-3,-2,-2,-2,-2,-2,-2,-3,-2,-2,-2,-1,-2|-6,-5,-5,-6,-5,-4,-6,-6,-5,-4,-5,-4,-5,-4,-4,-4,-4,-4,-4,-4,-4,-4,-5,-5,-5,-4,-4,-4,-5,-4,-5|-19,-20,-19,-17,-17,-18,-19,-17,-21,-17,-19,-17,-16,-18,-18,-16,-17,-16,-15,-16,-17,-16,-16,-14,-15,-15,-17,-14,-14,-15,-14|-90,-87,-79,-75,-74,-71,-66,-68,-65,-61,-58,-59,-55,-55,-57,-55,-50,-52,-49,-50,-47,-48,-48,-47,-45,-44,-45,-47,-42,-43,-40|-6,-10,-11,-17,-20,-25,-28,-30,-34,-36,-37,-40,-44,-45,-51,-49,-46,-45,-49,-53,-54,-57,-56,-55,-58,-61,-61,-61,-60,-64,-63|-3,-2,-3,-2,-3,-2,-3,-3,-3,-3,-3,-2,-2,-3,-3,-2,-2,-2,-3,-3,-2,-3,-3,-4,-4,-2,-3,-3,-2,-2,-2|-12,-11,-12,-13,-12,-11,-11,-10,-11,-11,-12,-10,-12,-11,-11,-12,-12,-12,-12,-11,-11,-10,-11,-12,-11,-9,-10,-10,-10,-11,-10|-133,-132,-136,-136,-135,-135,-133,-130,-125,-131,-132,-132,-134,-128,-120,-125,-132,-131,-132,-127,-128,-125,-124,-128,-123,-129,-127,-125,-127,-125,-123|-27,-29,-31,-30,-31,-30,-30,-32,-32,-32,-30,-31,-28,-31,-32,-33,-32,-32,-31,-32,-33,-33,-34,-31,-36,-32,-30,-34,-36,-34,-39|-1,-2,-1,-2,-1,-2,-2,-2,-2,-2,-1,-3,-2,-3,-2,-1,-2,-4,-2,-2,-2,-2,-1,-2,-1,-1,-1,0,-2,-1,-2)

[iPhone OS 3.0 Adoption Rate Estimates All Over The Place : 2009/06/29](http://appadvice.com/appnn/2009/06/iphone-os-30-adoption-rate-estimates-all-over-the-place/)
![](http://wp.appadvice.com/wp-content/uploads/2009/06/iphone-os-june-22-300x236.jpg)![](http://wp.appadvice.com/wp-content/uploads/2009/06/touch-os-june-2211-300x236.jpg)

iPhone では無料で OS の更新ができるため 3.0 のユーザーが多いと思うのですが、iPod touch は有料アップデートのためか依然として2.2.1が多いようで、その割合は2009年8月末時点で全体の 40% ほどを占めています。

そこで我々は、iPhone SDK 3.0 で開発を行いならが、2.2 でも動作が可能な手法をとりましたので、紹介したいと思います。


### 下位互換の手法


まず、開発のポイントは２つあります。



	
  * 3.0 にしか無いライブラリは Weak リンクをする

	
  * 実行時に OS のバージョンを調べ動作を変える


ライブラリは通常 Required というモードで追加されます。このモードでは、実機での実行時にライブラリが存在していない場合はアプリが起動しません。 これを Weak というモードに変更する事で、実機での実行時にライブラリが存在していなくても起動できるようになります。今回は 3.0 から追加されたライブラリである MapKit.framework を Weak に設定します。以下の画像が設定例です。

{% image /ja/files/2009/09/PMS1-001.jpg %}PMS1-001{% endimage %}

そして、次に OS のバージョンによって動作を変えます。MapKit.framework がリンクされていない 2.2 などでは、その機能を使おうとするとアプリが落ちてしまいます。以下のコードが OS のバージョンを調べ、3.0 以下の場合は Map に関するクラスを作成しないものになります。

```objc
float version = [[[UIDevice currentDevice] systemVersion] floatValue];
if(version >= 3.0){
	MapController	*_map = [[MapController alloc] init];
	self.mapController = _map;
	[_map release];
}
```

また、2.2 でもマップ表示を実装するために、外部マップアプリで表示する手法をとっています。

```objc
float version = [[[UIDevice currentDevice] systemVersion] floatValue];
if(version >= 3.0){
	[g_Instance.mapController setTitle:NSLocalizedString([NSString stringWithCString:title encoding:NSUTF8StringEncoding], @"") latitude:latitude longitude:longitude];
	[g_Instance push:g_Instance.mapController];
}else{
	NSString* url8 = [NSString stringWithFormat:@"%@%f,%f (%@)", @"http://maps.google.com/map?f=q&q=", latitude, longitude, NSLocalizedString([NSString stringWithCString:title encoding:NSUTF8StringEncoding], @"")];
	NSString *uelEncode = (NSString*)CFURLCreateStringByAddingPercentEscapes(
									kCFAllocatorDefault,
									(CFStringRef)url8,
									NULL,
									NULL,
									kCFStringEncodingUTF8); 

	NSURL* url = [NSURL URLWithString:uelEncode];
	[[UIApplication sharedApplication] openURL:url];
}
```


こちらが 3.0 と 2.2系 での動作を比較した動画です。

{% youtube 0U5a7kJ7A0s %}

