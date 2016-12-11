---
title: RxJava+RxAndroid+RxLifecycleを使った非同期処理を行う
date: 2016-12-11 08:09 JST
tags: やぎすけAdventCalendar2016,Android
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の11日目です。  
書き溜めもほとんどない（ネタリストだけは確保している）ので厳しくなってくる今日このごろです。
      
昨日は僕が[Javaでリストを操作するときにfor文をやめてみる](https://blog.yagi2.com/2016/12/10/i-will-try-stop-using-for-each.html)を書きました。  
  
今日はAndoirdでAPI通信を行って結果を非同期で処理します。
## はじめに
今日やる環境として使うライブラリとバージョンを載せておきます。  
おわりにコードも載せているので合わせて御覧ください。  

* RxJava v1.1.6
* RxAndroid v1.2.1
* RxLifecycle v1.0

本題に関係ないのでリストには入れてませんが通信は`Retrofit`を使います。  
  
今回のゴールはこれらを使って[お天気Webサービス仕様 - Weather Hacks - livedoor 天気情報](http://weather.livedoor.com/weather_hacks/webservice)のAPIを使用し、横浜のみなとみらいの今日明日明後日の天気を表示するアプリを作成しましょう。  
<br><br>
## Rx(Java|Android|Lifecycle)とは

### RxJava & RxAndroid
`RxJava`とはJavaでリアクティブプログラミングを行うためのライブラリです。リアクティブプログラミングは、所謂データが流れてくるような感じでそのデータを受け取る度に様々なものが反応（リアクション）するようなやつです（かなりざっくり）。  
ストリームの考え方については昨日の[Javaでリストを操作するときにfor文をやめてみる](https://blog.yagi2.com/2016/12/10/i-will-try-stop-using-for-each.html)で実際にJava8にある`Stream`を使ってリストを操作しました。  
基本的にはああいう奴です。何かしらのデータが流れてきて、それを加工なりして受け取ったタイミングで処理をする（出力等）奴にはもってこいです。  
  
実は昨日いろいろ紹介した中で`RxJava`ではリスト操作について説明しませんでしたが、もちろん`RxJava`でも昨日のような事を出来ます。  
1〜10までの整数を受け取って、2倍に加工して、出力するのようなものだったら。
  
```java
Observable.from(new Integer[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10})
    .map(new Func1<Integer, Integer>() {
        @Override
        public Integer call(Integer i) {
            return i * 2;
        }
    })
    .subscribe(new Observer<Integer>() {
        @Override
        public void onNext(Integer i) {
            Log.d("VALUE", i.toString());
        }

        @Override
        public void onCompleted() {
            Log.d("DONE", "Complete");
        }

        @Override
        public void onError(Throwable e) {
            Log.e("ERROR", e.toString)
        }
    });
```

の様に書くことが出来ます。  
今日はAndroidの話なので出力はLogにしました。  
大体昨日のと同じですね。リストがあり、`map`で加工し、それを流す。  
詳しいメソッドに関しては後で紹介します。  
<br>
`RxAndroid`は`RxJava`をAndroidで利用するために特化した感じのライブラリです。`RxJava`自体はJavaのライブラリなのでAndroidプロジェクトでなくとも使うことが出来ます。  

### RxLifecycle
`RxLifecycle`はメモリリークなどを防ぐユーティリティのライブラリです。  
Androidでは通信処理はメインスレッドで行うことが出来ず、`AsyncTask`などを使って非同期処理をすることになりますが、その際に結果は`Activity`などで弄りたい場合によく`Callback`などを使います。
そして`Callback`を使う際に戻ってくる予定だった`Activity`が破棄されてしまっている状態だと落ちてしまいます。  
  
そんなときに`RxLifecycle`を使用し、`RxJava`の処理をAndroidの`Fragment`や`Activity`のライフサイクルにバインドすることによって、そのタイミングで処理を中断させることが出来ます。  
通信途中にユーザーがホーム画面に戻っても適切に終了させることができるのです。素晴らしい。
<br>
今回は以上の事を踏まえて、お天気APIに通信する→戻ってきたデータをViewにセットする。という流れを作ってみたいと思います。
<br><br>
## 通信する
早速ですが、通信しましょう。  
前提条件として、`Retrofit`を使っています。APIインターフェースの戻り値を`Observable`にすることによって`RxJava`を簡単に使っています。

```java
@GET("json/v1")
Observable<WeatherModel> getWeather(@Query("city") String cityNumber);
```

`WeatherModel`というのはお天気APIの返す`json`をオブジェクトに変換するモデルです。気になる方は[お天気Webサービス仕様 - Weather Hacks - livedoor 天気情報](http://weather.livedoor.com/weather_hacks/webservice)を見てください。
ここのレスポンスフィールド通りに作りました。実際のモデルクラスは[WetherModel.java](https://github.com/yagi2/rxsample/blob/master/app/src/main/java/com/yagi2/rxsample/model/WeatherModel.java)です。

まずは通信して処理する完成形をペタリ

```java
retrofit.create(WeatherApi.class).getWeather(CITY_NUMBER)
    .subscribeOn(Schedulers.io())
    .toSingle()
    .compose(this.bindToLifecycle().<WeatherModel>forSingle())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(new SingleSubscriber<WeatherModel>() {
        @Override
        public void onSuccess(WeatherModel weather) {
            // ここでViewなどに返却されたデータをセットする 以下は例

            textView.setText(weather.description.text);
            unsubscribe();
        }
        
        @Override
        public void onError(Throwable e) {
            if (e instanceof CancellationException) {
                unsubscribe();
                return;
            }
            unsubscribe();
        }
    });                  
```

1つずつ噛み砕いていきましょう。
最初の`.create`行はただのAPI通信を開始する`Retrofit`の部分なので割愛するとして次の行から

* `.subscribeOn(Schedulers.io())`

`subscribeOn()`はRxJavaの機能で、ここでは通信部をどういうスレッドで行うかを指定しています。  
`Schedulers.io()`は標準で用意されている`Schedulers`であり、I/Oバウンド用のスレッドを生成して行います。
  
* `.toSingle()`

`toSingle()`は`SingleSubscriber`というものに変換してくれて、これは値が1度しか流れてこないようなものに使います。  
このAPIではAPIを通信したらjsonが1つしか流れてこないのでこれを使用しています。  
最初のリスト操作の例で上げたようなもので使うと1,2,3...,10と合計10回流れてくるので使えません。

* `.compose(thi.bindToLifecycle().<WeatherModel>forSingle())`

`compose()`は`Observable`に作用させるものであり、今回は`RxLifecycle`の`bindToLifecycle`という機能を使って居ます。  
`bindToLifecycle`はその名前のとおりAndroidのライフサイクルにバインドするものです、それを`compose()`に使うことによって「このObservableはライフサイクルにバインドされたぞ」という形になります。  
Activityなどが破棄されたらそれに従ってObservableも破棄される形です（厳密にはちょっと違いますが、`RxLifecycle`に関しては明日また別の記事を書くのでそこで説明します）

* `.observeOn(AndroidSchedulers.mainThread())`

おっと？`subscribeOn()`というのがあったじゃないかと思われるかもしれませんが、`observeOn()`と`subscribeOn()`は作用の仕方が違います。  
`subscribeOn()`は先ほど説明したとおり、今回で言うところのAPI通信部のスケジューラを決めています。  
`observeOn()`はそれを書いた以降の処理のスケジューラを決めています。今回は`AndroidSchedulers.mainThread()`としてメインスレッドでViewとかに返ってきた値をセットしますよという感じです。  

* `.subscribe(new SingleSubscriber<WeatherModel>())`

所謂処理開始のような形です。今回は`SingleSubscriber`を使用しているのでメソッドは上記の`onSuccess()`と`onError()`の2つです。メソッド名からしてわかりますね。  
それぞれのメソッド内で書かれている部分は`RxLifecycle`に関係してくることなので、詳しくは明日の記事で書きます。

大体通信部の雰囲気はつかめたでしょうか。  
これでAPIを叩いて戻ってきた値を処理することが完了しました。めちゃくちゃ簡単ですね！
<br>
以上の通信を使って実際に作ってみたサンプルアプリがこちらになります。

![](2016/12-11-rxjava-rx-android-rxlifecycle-001.png)

上記コードの`onSuccess`内でViewに値をセットしています。  
各天気は[さくっとRecyclerViewを使ってリストを作成する](https://blog.yagi2.com/2016/12/03/how-to-use-recyclervie.html)で紹介したRecyclerViewを使っています。なんかこのAdvent Calendarの復習みたいになっていますね。
  
このアプリのソースは[yagi2/rxsample](https://github.com/yagi2/rxsample)においておきました。Android Studioなどでインポートするとすぐに試すことが出来ます。  
APIのエンドポイントとベースURLとモデルを書き換えれば任意の好きなAPIで通信できますね！
<br><br>
## おわりに
かなりざっくりと駆け足で紹介してしまいましたが、RxJava+RxAndroid+RxLifecycleでのAPI通信非同期処理のやりかたでした。  
今までは`AsyncTask`の通信クラスを作りそれに対して`.execute()`を行ってコールバックで処理する、のような手法をやっていましたが、クラスが増える、コールバックがめちゃくちゃになってしまっているなどを考えると読みやすさ的にもこちらのほうが個人的には好きです。  
  
明日はRxLifecycleを掘り下げた話題をちょっとしてみようと思っています。
  
以上、やぎにいでした！