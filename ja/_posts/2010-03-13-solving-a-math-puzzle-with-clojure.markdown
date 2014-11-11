---
author: ento
lang: ja
date: 2010-03-13 11:00:51+00:00
layout: post
title: 「笑わない数学者 - 森博嗣 」に出てくる数学パズルをプログラム(Clojure)で解く [吾輩の小説 for iPhone]
tags:
- その他
- 吾輩の小説
---

自炊系小説ビューワ{% app_link mynovel %}で今日も電車で本を読んでいたら、話の中に数学パズルが出てきました。それもそのはず、読んでいたのは森博嗣 による[「笑わない数学者」](http://www.amazon.co.jp/dp/4062646145)です。

{% youtube V729gFDX7Fw %}



<blockquote>
五つのビリヤードの玉を、真珠のネックレスのように、リングにつなげてみるとしよう。玉には、それぞれナンバが書かれている。さて、この五つの玉のうち、幾つ取っても良いが、隣どうしが連続したものしか取れないとしよう。一つでも、二つでも、五つ全部でも良い。しかし、離れているものは取れない。この条件で取った玉のナンバを足し合わせて、1から21までのすべての数ができるようにしたい。さあ、どのナンバの玉を、どのように並べて、ネックレスを作れば良いかな？
</blockquote>



うーん、まず1を作るには「1」の玉が必要。次に2を作るには、0+2、1+1の組み合わせがあって、1の玉を2つは入れられないから、「2」の玉も必要だ。と、ここまで考えたところで気付きました。プログラマにはコンピュータという計算の得意な友達がいる！

ということで計算機にパズルを解いてもらいました。言語は、最近はまっている[Clojure](http://clojure.org/)という関数型言語です。


```clojure
; 名前空間の設定と使うライブラリのインポート
(ns ball-chain
  (:use [clojure.contrib.combinatorics :only (combinations permutations)])
  (:use clojure.contrib.test-is))
 
; 玉を定義
(defn balls [] (range 3 15))
 
; ネックレスの start 番目から length 個だけ取り出して数を合計する関数
(defn take-sum [chain start length]
  (reduce + (for [i (range start (+ start length))]
	       (nth chain
		    (mod i (count chain)) 1))))

; ネックレスから玉を取り出して
; 合計が number になるようにできるか? を返す関数
(defn yields? 
  ([chain number]
    (not (empty? (take 1 (filter #(yields? chain number %) (range 0 5))))))
  ([chain number start]
    (not (empty? (take 1 (filter #(= number (take-sum chain start %)) (range 1 5)))))))

; ネックレスが条件に合うか? を返す関数
(defn correct? [chain]
     (every? identity (map #(yields? chain %) (range 1 20))))

; 玉を組み合わせてネックレスを作る関数
(defn all-chains [] (map permutations (map #(concat % (list 1 2)) (combinations (balls) 3))))

; ネックレスの組み合わせの中から、条件に合うものを抽出する関数
(defn answers []
  (for [perms (all-chains) :when (not-empty (filter correct? perms))]
    (filter correct? perms)))

; yields? のテスト
(deftest test-yields
  (is (yields? (list 1 2 3 4 11) 1))
  (is (yields? (list 1 2 3 4 11) 2))
  (is (yields? (list 1 2 3 4 11) 3))
  (is (yields? (list 1 2 3 4 11) 4))
  (is (yields? (list 1 2 3 4 11) 11))
  )

; テストを実行
(run-tests)

; 答えを1つ出力
(println (take 1 (answers)))
```



「1と2の玉が必ずある」という条件を組み込んで、多少の高速化をはかっています。ネックレス状なので右回りも左回りも同等の組み合わせになる、といった条件は考慮できていません。

これを Mac OS X で動かすには、たとえば ball-chain.clj というファイルに保存した上で、以下のように実行します。


```sh 
$ sudo port install clojure clojure-contrib
$ java -classpath .:/opt/local/share/java/clojure/lib/clojure.jar:/opt/local/share/java/clojure/lib/clojure-contrib.jar clojure.main ball-chain.clj --
```



※ 本来は

```sh
$ clj ball-chain.clj
```

だけで実行できるはずなんですが、MacPorts の[バグ](http://trac.macports.org/ticket/22889)のため、それには少し設定が必要です。詳しくはリンク先を参照してください。

答え? 答えはネタバレなのでここには書きません。どうしても見たい方は↓へどうぞ



。。。





スクリプトの出力結果はこちら:


```sh
$ clj ball-chain.clj

Testing ball-chain

Ran 1 tests containing 5 assertions.
0 failures, 0 errors.
(((3 10 2 5 1) (3 1 5 2 10) (5 1 3 10 2) (5 2 10 3 1) (10 3 1 5 2) (10 2 5 1 3) (1 3 10 2 5) (1 5 2 10 3) (2 5 1 3 10) (2 10 3 1 5)))
```



1 つ目の答え (3 10 2 5 1) が本当に合っているか、見てみましょう。

<table >
<tr >
<td >1
</td>

<td >3 10 2 5 **1**
</td>
</tr><tr >
<td >2
</td>

<td >3 10 **2** 5 1
</td>
</tr><tr >
<td >3
</td>

<td >**3** 10 2 5 1
</td>
</tr><tr >
<td >4
</td>

<td >**3** 10 2 5 **1**
</td>
</tr><tr >
<td >5
</td>

<td >3 10 2 **5** 1
</td>
</tr><tr >
<td >6
</td>

<td >3 10 2 **5 1**
</td>
</tr><tr >
<td >7
</td>

<td >3 10 **2 5** 1
</td>
</tr><tr >
<td >8
</td>

<td >3 10 **2 5 1**
</td>
</tr><tr >
<td >9
</td>

<td >**3** 10 2 **5 1**
</td>
</tr><tr >
<td >10
</td>

<td >3 **10** 2 5 1
</td>
</tr><tr >
<td >11
</td>

<td >**3** 10 **2 5 1**
</td>
</tr><tr >
<td >12
</td>

<td >3 **10 2** 5 1
</td>
</tr><tr >
<td >13
</td>

<td >**3 10** 2 5 1
</td>
</tr><tr >
<td >14
</td>

<td >**3 10** 2 5 **1**
</td>
</tr><tr >
<td >15
</td>

<td >**3 10 2** 5 1
</td>
</tr><tr >
<td >16
</td>

<td >**3 10 2** 5 **1**
</td>
</tr><tr >
<td >17
</td>

<td >3 **10 2 5** 1
</td>
</tr><tr >
<td >18
</td>

<td >3 **10 2 5 1**
</td>
</tr><tr >
<td >19
</td>

<td >**3 10** 2 **5 1**
</td>
</tr><tr >
<td >20
</td>

<td >**3 10 2 5** 1
</td>
</tr><tr >
<td >21
</td>

<td >**3 10 2 5 1**
</td>
</tr></table>

その他の答えも、右回り・左回りを逆にしたり、さらに開始点をずらしたりすることで 1 つ目の答えと同じネックレスになっていることがわかります。

