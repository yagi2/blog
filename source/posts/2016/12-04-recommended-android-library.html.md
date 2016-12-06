---
title: Androidプロジェクトを作って結構な確率で導入するライブラリ
date: 2016-12-04 02:17 JST
tags: やぎすけAdventCalendar2016, Android
---

こんにちは、やぎにいです！  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の4日目です。
昨日は僕が[さくっとRecyclerViewを使ってリストを作成する](https://blog.yagi2.com/2016/12/03/how-to-use-recyclervie.html)を書きました。
<br><br>
## 概要
今日は僕が今年1年、OSSのAndroidソースや、自分で作ってるアプリのソースを書いているときに、かなりの確率で導入する（されている）ライブラリや、僕が気に入って使っているライブラリを紹介したいと思います。  
それぞれの使い方を紹介するとかなりの分量になってしまうので、掘り下げて紹介しようと思うライブラリは後日別記事として使い方を紹介します。  
<br><br>
## Stetho
まずはじめに[Stetho](https://github.com/facebook/stetho)です。  
これはデバッグをかなり容易にできるようなライブラリです。導入するとGoogle Chromeの`chrome://inspect`にアプリが表示され、`Inspect`ウィンドウで簡単に見ることができるようになります。  
見ることができる内容としては本当に様々で、よく使うのを挙げれば。  

* Viewのレイアウトの確認
* ネットワークログ
* RealmやMySQL等のORMのデータ
* Preferenceで保存している値の確認

などを個人的にかなり使用します。  
普通にGoogle ChromeでWebページを開いて`検証`を確認した時と同じ通り、ネットワークはデータタイプやサイズ、レスポンス時間なども表示されるのでどこがネックなのか等簡単に確認することが可能です。  
まず最初にこれを入れてデバッグに備えることが多い気がします。  
<br><br>
## Timber
次は[Timber](https://github.com/JakeWharton/timber)です。  
こちらもStetho同様デバッグに使うライブラリになります。 　
よくデバッグログを出力するときは`Log.d(TAG, "message");`のように書きますが、このコードをそのまま書いてしまうと`release`ビルドなのにデバッグ出力がされていたりします。（実際にADBにつなぐと流れてきたりする）  
    
TimberはApplicationクラスで`Tree`インスタンスを`.plant`することによって簡単に場合分けのようなことが出来ます。`Tree`インターフェースは自分で実装することもでき、自由にカスタマイズ出来ます。  
予め用意されているDebugTreeを使えばTAGは自動生成されるので`Timber.d("message");`のようにいちいち`TAG`を書く必要性がなくなったりして非常に楽になったりします。  
ライブラリの導入も面倒ではないので、`Log`を使うのであれば導入してしまいましょう。
<br><br>
## ButterKnife
続いて[ButterKnife](https://github.com/JakeWharton/butterknife)です。  
よくいろんな`View`を操作するときに`TextView textView = (TextView) findViewById(R.id.text_view);`のように書いていると思いますが、量が多かったりすると`findViewById`だらけになってしまいます。  
    
それをアノテーションを利用して`onCreate`で`ButterKnife.bind(this);`をすることにより、いちいち`findViewById`をしなくても良くなります。  
使い方は後日紹介しますが、ローカルスコープ内でしか利用しないから`.bind()`するのも……というときも`ButterKnife#findById`を使用すると`(TextView)`を置くみたいなキャストが必要なくなります。`TextView textView = ButterKnife.findById(this, R.id.text_view);`の用にスッキリします。  
    
間違いなく今`findViewById`でいっぱいだよ！っていうケースではスッキリするのでおすすめです。（僕は初めて知った時めちゃくちゃスッキリしました）
<br><br>
## Icepick
そして[Icepick](https://github.com/frankiesardo/icepick)  
よくAndroidアプリを作るときはActivityやFragmentのライフサイクルを考え、破棄される時の事を考慮して設計します。  
画面回転を抑制していなければ回転した瞬間に画面にあった`EditText`に入力してた値が吹っ飛んだ！みたいな経験がきっとあると思います（僕はあります）。 
  
そういうケースでは`onSaveInstanceState`でデータを保持しておいて`onRestoreInstanceState`で復元する。みたいな実装をするのが定番の実装だと思います。  
が、結構保持するべきデータが多かったりするとそれぞれのコード量が多くなりがちです（本来こういう実装はあんまりよくないと思うけど）。
    
そんなときにこのIcepickを使うと、保持しておきたいフィールドに対して`@State`アノテーションを付け、`onSaveInstanceState`内で`Icepick.saveInstanceState(this, outState);`と記述してあげることでアノテーションがついていたフィールドの値は保持されます。  
同様に復元するときも`Icepick.restoreInstanceState(this, savedInstanceState);`と書くだけで復元されます。すっごい簡単ですね。今までは`outstate.putString(Key, value);`と書きまくっていたのが1つにまとまります。
    
EditTextの文字を保持して復元するときは、EditTextから値を引っ張り出し、`Icepick.saveInstanceState()`、そして`Icepick.restoreInstanceState()`してからEditTextにセットという手順を踏む必要はありますが、今までと比べて簡単になりました。  
保持したいなーと思うフィールドが多い場合は導入する価値があるライブラリだと思います。オススメです。
<br><br>
## IntentLogger
今回紹介する最後のライブラリは[IntentLogger](https://github.com/Drivemode/IntentLogger)です。  
Stetho,Timber含めデバッグ系のライブラリが多いなという印象ですが、このIntentLoggerもデバッグに貢献するライブラリになります。
    
Androidのアプリ開発をしていて、1画面で完結し他のActivityなどに遷移しないというのはかなりのレアケースだと思いますが、遷移する際によく`Intent`に値を含めて渡すケースが有ると思います。  
それがイマイチうまく渡ってなかったりするときに受け取り側で`intent.getXXX()`をいっぱい書いてそれを`Log`クラスなり、紹介した`Timber`なりに渡してデバッグをする必要がありましたが、このIntentLoggerを導入すると`IntentLogger.dump(TAG, getIntent());`の1つで済みます。  
Actionや含めたExtra、IntentにセットしたFlagなどがLogCatに表示されます。 
    
GitHubのスター数も今まで紹介したライブラリよりは少ない上に「Android おすすめ ライブラリ」等で検索したときもあまりヒットしないライブラリではありますが、個人的にかなりおすすめのライブラリです。  
<br><br>
## おわりに
以上5個のライブラリを僕は大体の確率で導入しています。  
今回は文字成分だけの記事になってしまいましたが、明日以降個別の記事としてIntentLoggerを除いた4つのライブラリを掘り下げて使い方などを実際のコードを交えて紹介していきたいと思います。  
Androidアプリを開発する際は本当に便利なライブラリがこの世界にはいっぱい転がっているので、色々見てみるととても楽しいです。
  
以上、やぎにいでした！