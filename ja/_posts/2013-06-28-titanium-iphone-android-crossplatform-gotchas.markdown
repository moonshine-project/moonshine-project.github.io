---
author: akira
lang: ja
date: 2013-06-28 04:09:53+00:00
layout: post
title: iPhone向けに作られたTitaniumアプリのAndroid対応で気をつけること
tags:
- 開発
---


Titanium 3.1.0 で作られた iPhone アプリを Android で動くようにしてみたところ、いくつかの問題がでてきましたので対処方法などまとめておきます。






#### Android の判定






なにはともあれ、まずは実行している端末が Android かを判定する情報を保持します。alloy.js の初めの方で定義しておけばよいでしょう。

    
```javascript
Alloy.Globals.isAndroid = /android/i.test(Ti.Platform.osname);
```


OS_IOS での判定もありますが、こちらバグがあるようです。



## iPhone と Android でデザインが大きく違うところ


#### Android にはナビゲーションバーがない


Android には iPhone で言うところのナビゲーションバーがありませんので、iPhone 側でナビゲーションバーを使用するなら Android 側ではその機能に変わるものを実装する必要があります。いくつか方法があると思いますが、１つは iPhone のナビゲーションバーを模したものを再実装する方法。Android にはメニューキーやバックキーを使用する文化があるので、あえて iPhone を模すことはユーザーを混乱させるだけなのでお勧めはしません。しかし、仕様が統一できるので開発側にすると楽だと思います。もう１つは、Android の機能である ActionBar（Android 3.0以降） もしくはメニューキー・バックキーを使用する方法です。ActionBarやメニュー画面の設計が必要になるのでコストはかかりますが、Android ユーザには見慣れたものになるので使いやすくなると思います。



#### Android ではタブバーが上にくる


Android のタブバーは iPhone とは逆で画面の上に配置されます。Titanium2 までは下に配置する方法がありましたが、今のところ Titanium3 ではできないようです。また、最近のアプリではタブバーを使用しないものが多くなってきているように感じますので、Titanium で iPhone, Android 両対応のアプリを作るさいは、タブバーを使用しないデザインにした方がよいかもしれません。


## iPhone と Android で別の API を利用しなければいけないケース


#### ナビゲーションバー関連のメソッドを呼ぶと落ちる


Android にはナビバーが無いので、関連するメソッドを呼ぶと落ちます。判定を入れましょう。

    
```js
if (!Alloy.Globals.isAndroid) {
	$.window.hideNavBar();
}
```


#### カスタム URL scheme で起動した場合の URL を取得する


iPhone は Ti.App.getArguments().url で取得できますが、Android の場合は intent から取得します。

```js
var url;
if (Alloy.Globals.isAndroid) {
	var activity = Ti.Android.currentActivity;
	var args = activity.getIntent().getData();
	if (args) {
		url = args.toString();
	}
} else {
	var args = Ti.App.getArguments();
	if (args.url) {
		url = args.url;
	}
}
```


#### 画像を端末に保存する


アプリ内の画像を端末に保存する方法が iPhone と Android で違います。ImageView に設定した画像を保存するときは以下のようにします。

```js
function saveToPhotoGallery (imageView, fileName){
    if (Alloy.Globals.isAndroid) {
        var dir = Ti.Filesystem.getFile(Ti.Filesystem.externalStorageDirectory, 'appname');
        if (!dir.exists()) {
            dir.createDirectory();
        }
        var f = Ti.Filesystem.getFile(dir.resolve(), fileName + '.jpg');
        f.write(imageView.toImage().media);
        Ti.Media.Android.scanMediaFiles([f.nativePath], null, function(e){});
    } else {
        Ti.Media.saveToPhotoGallery( imageView.image )
    }
}
```



#### Titanium.UI.iPhone 関連の使用

iPhone でしか使用できない Titanium.UI.iPhone 以下の定数やメソッドがありますが、こちらを使用する場合は Android かどうかの判定を入れないとアプリが落ちます。


    
```js
var template = {
 	properties: {
 	    height: '100dp',
 	},
};
if (!Alloy.Globals.isAndroid) {
	template['properties']['selectionStyle'] = Titanium.UI.iPhone.ListViewCellSelectionStyle.NONE;
}
```

#### iPhone と Android で違うビューのマークアップを使う

[Alloy XML Markup](http://docs.appcelerator.com/titanium/latest/#!/guide/Alloy_XML_Markup-section-35621528_AlloyXMLMarkup-ConditionalCode) ガイドにあるように、 platform 属性によってビューを出し分けることができます。また、 formFactor 属性でデバイスの形状によって出し分けることもできます (指定できる値は tablet か handheld)。

{% gistit /moonshine-project/gist/blob/master/blog/cross-platform-titanium/conditional_alloy_xml.xml %}



[Supporting Multiple Platforms in a Single Codebase](http://docs.appcelerator.com/titanium/latest/#!/guide/Supporting_Multiple_Platforms_in_a_Single_Codebase-section-29004890_SupportingMultiplePlatformsinaSingleCodebase-Platform-specificstyling) も参考になるので一読しておくと吉です。


#### ディスプレイの大きさを dip 単位で取得する

iPhone では Ti.Platform.displayCaps.platformHeight などをそのまま使用できますが、Android の場合はその値に Ti.Platform.displayCaps.logicalDensityFactor を掛ける事で同じように使用することができます。

   
```js
var displayHeight = Ti.Platform.displayCaps.platformHeight;
if( Alloy.Globals.isAndroid ) {
	// convert to dips
	displayHeight = displayHeight / Ti.Platform.displayCaps.logicalDensityFactor;
}
```

## iPhone と Android で Titanium の内部実装が違う


#### タブバーの項目が消せない

タブバーを作るときは、TabGroup に Tab を追加しますが iPhone では Tab を remove する事もできます。しかし、Android ではできません。Tab の内容を変更したい場合は TabGroup の作りなおしが必要になります。


#### ビューを複数重ねて上のビューを非表示にしても下のビューがタップできない。もしくは非表示でもタップできてしまう。


ビューを重ねて配置し、上のビューを消して下のビューを操作させたい場合があります。iPhone は opacity = 0 で表示を消すと下のビューの操作も可能ですが、Android の場合は touchEnabled = false も設定する必要があります。


```xml
<View id="view1" left="0" top="0" width="100dp" height="100dp" />
<View id="view2" left="0" top="0" width="100dp" height="100dp" />
```
    
```js
$.view1.opacity = 0;
$.view1.touchEnabled = false;
``` 

また touchEnabled = false にしないと上のビューがタップできてしまいます。


#### 表示が崩れる

iPhone では綺麗に表示されていたものが Android だと違う見た目になってしまうという問題が起きます。その場合は xml に設定忘れの値が無いかなど確認します。以下の例では label1 label2 は横に並べて配置したいのですが、親のビューに width="Ti.UI.SIZE" を設定していなかったために、Android では label2 で改行されて label1 の下に表示されてしまいました。

```xml
<!-- <View layout="vertical" left="10dp" height="Ti.UI.SIZE" > -->
<View layout="vertical" left="10dp" width="Ti.UI.SIZE" height="Ti.UI.SIZE" >
    <Label id="label1" left="0" color="#000" />
    <Label id="label2" left="0" color="#999" />
</View>
```


#### ボタンの中身が表示されない（コンテナになれないビューたち）


ビューにビューを追加して、階層構造で画面を構築していきますが、親ビューになれないものも存在します。たとえば Button は親ビューになれないため、Label や ImageView などを子として配置しても表示されません。しかし、iPhone はその仕様を無視して表示ができてしまうのです。Android でも正しく表示させるには、以下の例であれば Label を使わずにテキストを Button タグで囲う必要があります。

    
```xml
<!--
<Button id="button">
    <Label>OK</Label>
</Button>
-->
<Button id="button">OK</Button>
```


背景画像を使いたいのであれば Button の backgroundImage に設定することで表示できます。また複数の画像やテキストなどを配置したいのであれば、Button の使用をやめて View で配置し、onClink を設定すればタップも取れます。

どのビューが親になれないかの情報は View.add メソッドの説明に書いてあります。
[Titanium.UI.View-method-add](http://docs.appcelerator.com/titanium/latest/#!/api/Titanium.UI.View-method-add)



#### creation-only なプロパティに注意


Titanium でビューを作るには、XML に記述する方法と、コントローラ内で JavaScript の API を呼び出す方法があります。この時、JavaScript の API 経由でしか設定できないプロパティがあるので注意しましょう。こうしたプロパティは、リファレンスに "CO" または "CREATION-ONLY" というラベルが付いています。


#### テーブルビューをタップしたときに行のデータが取得できない


テーブルビューをタップしたときに iPhone では e.rowData にもその行のデータが入ってきますが、Android ではこの値は空になるので e.row を使うようにします。

 
```js
function onTableViewRowTap(e) {
  var cid = e.row.cid;
}
```


#### テーブルビューの表示更新が動かない


リファレンスにも書かれていますが、[updateSection() の引数の順序が違っているというバグ](https://jira.appcelerator.org/browse/TIMOB-12625)があります。Android の場合と iPhone の場合で引数の順序を変えましょう。

   
```js
if (Alloy.Globals.isAndroid) {
  table.updateSection(index, section, animation);
} else {
  table.updateSection(section, index, animation);
}
```


#### TableView の filterAttribute 用のプロパティを TableViewRow に後から設定できない


[オフィシャル Q&A](http://developer.appcelerator.com/question/131215/) に投稿があるように、Android 版の不具合のためカスタムの filterAttribute を使う場合は createTableViewRow で指定する必要があります。

  
```js
// works
var tableViewRow = Ti.UI.createTableViewRow({filter:'stuff',...});
// doesn't work
tableViewRow.filter = 'stuff';
```

デフォルトの filterAttribute、title を使う場合は後から設定できます。ただし、TableViewRow 内でラベルなどを使っている場合は注意が必要です: iPhone では TableViewRow に設定した title とラベルのタイトルの両方が表示されてしまうので、iPhone ではカスタムの filterAttribute を使うなどの対策が必要になります。


#### 検索欄のキャンセルが効かない

[SearchBar のキャンセルボタンが動作しない不具合](https://jira.appcelerator.org/browse/TIMOB-7748)があるので、自前で実装する必要があります。

  
```xml
<SearchBar id="search" height="44dp" hintText="検索" />
```
   
```js
$.search.addEventListener('cancel', onSearchCancel);
    
function onSearchCancel(e) {
  $.search.value = "";
  $.search.blur();
}
```

#### exports問題

[Titanium では CommonJS にのっとって JavaScript を書く](http://docs.appcelerator.com/titanium/latest/#!/guide/CommonJS_Modules_in_Titanium)、ということになっています。Titanium における CommonJS の実装では、NodeJS にならって以下のようにモジュールの API を定義することができます。


{% gistit /moonshine-project/gist/blob/master/blog/cross-platform-titanium/module_export.js %}

ここで、 2 番目の例のようにモジュールを require() した時に返るオブジェクトそのものを書き換えたい時に、 module.exports ではなく exports 変数に代入してしまうと NG です。 require() を実行すると実際には以下のような疑似コードが走ります。

{% gistit /moonshine-project/gist/blob/master/blog/cross-platform-titanium/module_export_behind_the_scene.js %}

exports 変数を書き換えても、最終的に返す値、 module.exports オブジェクトは変わりません。ところが! iPhone 版 Titanium では exports 変数そのものを書き換えることで require() の返り値も変わってしまうのです。このような exports 変数の使い方は [Titanium のドキュメントでも推奨されてません。](http://docs.appcelerator.com/titanium/latest/#!/guide/CommonJS_Modules_in_Titanium-section-29004791_CommonJSModulesinTitanium-AntipatternsandUnsupportedBehavior)



#### アニメーションでViewの表示がおかしくなる


View の位置やサイズを変更するときにアニメーションを使って素敵な演出が可能ですが、Android の場合は問題がおきます。まずアニメーション速度がとても遅くなります。iPhone だとスッと動くところが、Android ではカクッカクッカクッカクッとなります。そして、ビー内部に配置した子ビューの座標がずれました。こちらは情報が見当たらなかったので手元で起きた現象を説明します。まず画面の下半分にビュー（view1とする）を配置し、その中にいくつかボタンを配置しました。そして、view1をフルスクリーンになるようにアニメーションしたところ、まずボタン類がview1のアニメーションに一歩遅れる感じでついてきます。たとえば、ボタンを top="10dp" で配置しても、アニメーション中は 10dp だったり 20dp だったりして見えます。そして最終的にアニメーションが終わっても top="10dp" とは違う場所に表示されます。こちらは解決方法が見つからなかったため、Android ではアニメーションをしないようにしました。



## おわりに


Titanium は iPhone では動くのに Android では動かない事がよくあります。それは、そもそも Titanium が iPhone アプリ開発用に作られた経緯もあり、iPhone での実装の記事が多くあるからかもしれません。リファレンスに禁止事項が書かれていますが、記事にはその通り書かれていないものもあります。そして、それでも iPhone では動く事があります。また、Android での実装が後手にまわっているようなので機能が無いものもあります。iPhone, Android 両対応アプリを作るさいにこの記事が目に止まり、問題が回避できれば幸いです。

