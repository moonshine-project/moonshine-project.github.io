---
author: akira
lang: ja
date: 2010-01-06 11:48:23+00:00
layout: post
title: iPhoneアプリ「販売レポート共有支援サービス」MaryApps
tags:
- 発売
---

{% alert danger %}MaryApps はサービスを終了しました。{% endalert %}

iPhoneアプリの「販売レポート共有支援サービス」である [MaryApps](http://www.maryapps.com/) を公開しました。

[MaryApps http://www.maryapps.com/](http://www.maryapps.com/)

現在は英語のみで運用していますが、サービス公開後に利用者から便利だとの声を多く頂きましたので、より多くの日本の開発者にもご利用いただけるように、日本語で利用手順を書きたいと思います。



## MaryAppsとは？



[![maryapps_ja_01](/ja/files/2010/01/maryapps_ja_01.jpg)](/ja/files/2010/01/maryapps_ja_01.jpg)

MaryApps は毎日、アプリごとに登録されたメールアドレスに、販売数やアップグレード数そして売上レポートファイルを送信してくれるサービスです。複数人の開発者や関係者で、販売数の共有を簡単に行う事ができます。



## ログインまでの手順



[MaryApps](http://www.maryapps.com/) にアクセスし、画面右上の "Login" をクリックします。[MaryApps](http://www.maryapps.com/) では Google アカウント によって認証を行いますので、必要があれば "Signup" からアカウントの取得を行ってください。

[![maryapps_ja_02](/ja/files/2010/01/maryapps_ja_02.jpg)](/ja/files/2010/01/maryapps_ja_02.jpg)

認証が成功すると、ユーザーごとの home ページが表示されます。



## アプリケーションの登録



MaryApps で販売報告メールを送信するにはアプリ登録をおこないます。以下にアプリ登録の手順を書きます。

[![maryapps_ja_03](/ja/files/2010/01/maryapps_ja_03.jpg)](/ja/files/2010/01/maryapps_ja_03.jpg)

表示された home ページから "Add App" ボタンをクリックし、アプリ編集画面を出します。

[![maryapps_ja_04](/ja/files/2010/01/maryapps_ja_04.jpg)](/ja/files/2010/01/maryapps_ja_04.jpg)



### Login Apple ID:


iTunes Connect のログインIDを入力してください。



### Login Apple Password:


iTunes Connect のログインパスワードを入力してください。



### App Identification #:


アプリごとに割り振られている番号を入力してください。



### Display name:


MaryApps で表示するアプリの名前を入力してください。 iTunes Connect に登録してある名前と違っていても問題はありません。

[![maryapps_ja_05](/ja/files/2010/01/maryapps_ja_05.jpg)](/ja/files/2010/01/maryapps_ja_05.jpg)

販売報告メールを送るメールアドレスと、時間を設定します。



### Email



メールアドレスを入力し "Add"  ボタンを押してください。



### Attach report file?



レポートファイルを添付する場合はチェックを付け、添付しない場合はチェックを外してください。



### Action



追加したメールアドレスを削除する場合は "Remove"  ボタンを押してください。



### Time of day



メールを送信する時間を入力します。入力の形式は "時:分" の "HH:MM" か、"時:分:秒" の "HH:MM:SS" になります。



### Time zone offset



メールを送信する時間のタイムゾーンを設定します。 日本の場合 "UTC+09:00" を選択してください。

[![maryapps_ja_06](/ja/files/2010/01/maryapps_ja_06.jpg)](/ja/files/2010/01/maryapps_ja_06.jpg)

送信するメールの内容はカスタマイズが可能です。定義されたタグを埋込み、自由な文面を作成してください。以下は定義されたタグの説明です。



### [[app_name]]



上記で設定した "Display name:" の値が入ります。



### [[app_sales]]



アプリの売上数が入ります。



### [[app_upgrades]]



アプリのアップグレード数が入ります。



### [[now_date]]



メール送信時の日付が入ります。



### [[report_date]]



取得したレポートファイルの日付が入ります。



### 登録



以上の内容を記入し "Save" ボタンを押すとアプリの登録が完了します。初回の登録時には過去７日分のレポートが送信されるように設定されます。



## 手動でメールの送信



[![maryapps_ja_07](/ja/files/2010/01/maryapps_ja_07.jpg)](/ja/files/2010/01/maryapps_ja_07.jpg)

アプリを登録した後に、ユーザーの home 画面でレポートメールを手動で送信する事ができます。



### Report date:



取得するレポートの日付を "月/日/年" の形式で入力してください。 "01/01/2009" などです。



### Force Send



ボタンを押すとメールの送信が開始されます。



## 動作ログ



ユーザーの "home" 画面下に動作ログが表示されます。

[![maryapps_ja_08](/ja/files/2010/01/maryapps_ja_08.jpg)](/ja/files/2010/01/maryapps_ja_08.jpg)

