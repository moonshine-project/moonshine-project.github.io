---
author: ento
date: 2009-07-08 08:46:41+00:00
layout: post
lang: ja
slug: 'skimming-through-in-app-purchases-documentation'
title: アプリ内課金のドキュメントをざっと読む
tags:
- 開発
---

[公式ドキュメント](http://developer.apple.com/iphone/library/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Introduction/Introduction.html)より



	
  * アプリ内課金はStoreKitというフレームワークを使う

	
  * 課金するにはその内容ごとに product を iTunes Connect に登録する

	
  * iTures Store から情報を取得してユーザーに表示するには: SKProductsRequest を作って必要な情報を渡し、SKRequestDelegate で応答を受け取る

	
  * 支払い処理の流れ

	
    1. SKPaymentQueue にオブザーバーオブジェクト  を登録する

	
    2. グローバルなキュー SKPaymentQueue に支払い情報 SKPayment を追加する

	
    3. キューによってトランザクション SKPaymentTransaction が生成される

	
    4. オブザーバーでトランザクションの更新を受け取る

	
    5. (AppStore のウェブAPIを使って結果の内容が正しいか確認する)

	
    6. 支払い完了、支払いエラーなどの結果にしたがって適切な処理をする




	
  * 過去に完了したトランザクションは SKPaymentQueue のメソッド restoreCompletedTransactions を呼ぶことで復元することができる

	
    * 新しい iPhone に引っ越した後などに使える







	
  * アプリの課金システムのアーキテクチャを決めるにあたって考えるべきこと

	
    * 追加購入できるモノの情報をどう管理し、どうユーザーに見せるか

	
    * 追加購入したモノをどうアプリ内で有効にするか

	
    * 追加購入できるモノの数や、更新頻度はどれくらいか





	
  * アーキテクチャの2つのモデル

	
    * 自律型 (プロダクトIDも追加機能もアプリ内に保持する)

	
    * ダウンロードコンテンツモデル (プロダクトID、追加機能のデータ、購入履歴を独自サーバに持つ)








iTunes Connect の FAQ より:


	
  * **無料アプリはアプリ内課金はできない**

	
  * プロダクトを登録するには少なくとも1つの有料アプリの登録が必要 (承認済みである必要があるかは不明)

	
  * プロダクトのステータスは最初は 「開発者による承認待ち」 になっており、まずアプリ内課金のテストをすることができるようになっている





