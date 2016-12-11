---
title: RxLifecycleでのライフサイクルへのバインドについて
date: 2016-12-12 04:17 JST
tags: やぎすけAdventCalendar2016,Android
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の12日目です。  

昨日は僕が[RxJava+RxAndroid+RxLifecycleを使った非同期処理を行う](https://blog.yagi2.com/2016/12/11/rxjava-rxandroid-rxlifecycle.html)を書きました。  
どうやら今日の横浜の天気は晴のち曇らしいです。  
  
今日は昨日も使った`RxLifecycle`のバインド挙動についてお話したいと思います。
<br><br>  
## はじめに
`RxLifecycle`とは昨日の記事で紹介したとおり`RxJava`のObserverをAndroidのライフサイクルにバインドすることによってメモリリークやエラーを回避するためのものです（かなりざっくり）    
`RxJava`の`compose()`メソッドで呼び出される場所`onCreate()`や`onResume()`に対応したライフサイクルで破棄される`bindToLifecycle()`、任意のイベントにバインドする`bindUntilEvent(EVENT)`があります。  
基本的な使い方はそんな感じです。  
[trelloRxLifecycle](https://github.com/trello/RxLifecycle)

## よくあるやつ
`RxLifecycle`での挙動を調べるとQiita等の記事ではよく

> RxLifecycleではライフサイクルにバインドし所定のイベントで`unsubscribe()`される  
  
という記載をよく見ます。（僕も困ったときにたどり着いた記事は大体これが書いてあった）  
これは間違い（言い過ぎではあるけど）で、`RxLifecycle`のREADMEにも以下が書いてあります。

> RxLifecycle does not actually unsubscribe the sequence. Instead it terminates the sequence. The way in which it does so varies based on the type:  
>  
>  ・Observable - emits onCompleted()  
>  ・Single and Completable - emits onError(CancellationException)
>   
> If a sequence requires the Subscription.unsubscribe() behavior, then it is suggested that you manually handle the Subscription yourself and call unsubscribe() when appropriate  

ざっくり訳すと  
unsubscribeはしない。その代わりに`Observable`では`onCompleted()`、`Single, Completable`では`onError(CancellationException)`を呼ぶので、`unsubscribe()`の動作が必要なら必要に応じて手動で呼び出すのをおすすめするぞ。  
とあります。  
  
RxLifecycleはunsubscribeしないのです。  
`onCompleted`や`onError`で最終的にunsubscribeされるので厳密にさっきの文言は間違ってはいないのですが、頭においてほしいのは`unsubscribe()`の挙動を期待しないということです。  
    
よくある勘違いとして`RxLifecycle`でバインドしてあげれば`Activity`や`Fragment`が破棄されたら即時にObservableの処理がそこで破棄される。という勘違いです。  
それを勘違いしているとちょっと困ることが起こったりします。  
<br><br>
## あぶないケース
以下のObservableの処理があったとします。

```java
hogeObservable
    .compose(bindToLifecycle())
    .subscribeOn(Schedulers.newThread())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(new Observer<Hoge> {
        @Override
        public coid onCompleted() {
            // onNext()で保存した値を呼び出して何かしらの処理をする
        }

        @Override
        public onError(Throwable e) {

        }

        @Override
        public onNext(Hoge hoge) {
          // ここでPreferenceに値を書き込む等の処理をする
        }
    });
```
  
勘違いの前提として、ちゃんと`bindToLifecycle()`を行ったので、Activityが破棄されるときはこのObservableも`unsubscibe()`で破棄されるからその時点で`onNext()``onError()``onCompleted()`のどれも呼ばれなくなるという勘違いをしているとします。  
    
これが危ないのは`onCompleted()`での処理です。  
例えばユーザーがこのアプリを開いてアプリがAPIを叩いたが、通信が長引いて全部データを保存することが出来ずにホーム画面に戻ったとします。  
すると`RxLifecycle`の作用で`onCompleted()`が呼ばれます。このコードでは`onCompleted()`の中では`onNext()`でAPIから返ってきた値を保存した物を呼び出して使おうとしています。  
ですが、APIの通信が完了しておらず、値の保存が出来ていないので、値の呼び出しに失敗します。最悪アプリは閉じてるけど`NullPointerException`が発生する可能性があります。  
非常に良くないですね。  
  
もし、`onCompleted()`では、保存された値を使って`Activity`や`Fragment`を呼び出す処理をしていたとすると、ユーザーはアプリを終了したのになんかまた勝手に立ち上がったぞ的な挙動を起こすことがあります。  
<br><br>
## こうしよう
`RxLifecycle`はとにかく`onCompleted()`と`onError(CancellationException)`を呼ぶ（しつこい）のでそれを前提にした設計にしよう。ということです。  
じゃあ`unsubscribe()`される前提の処理はどう書けばいいんだよ！みたいになると思いますが、その場合は`doOnUnsubscribe()`に書いてください。`unsubscibe()`されたらそれが呼ばれます。

こんな検証コードを書いてみました。

```java
public class MainActivity extends RxAppCompatActivity {

    private static final String TAG = "RxLifecycleAndroid";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d(TAG, "onCreate()");

        setContentView(R.layout.activity_main);

        // for Observable
        // bind to onPause()
        Observable.interval(5, TimeUnit.SECONDS)
                .doOnSubscribe(new Action0() {
                    @Override
                    public void call() {
                        Log.i(TAG, "[Observables] : Started in onCreate(), running until onPause()");
                    }
                })
                .doOnUnsubscribe(new Action0() {
                    @Override
                    public void call() {
                        Log.i(TAG, "[Observables] : Unsubscribing subscription from onCreate()");
                    }
                })
                .compose(this.<Long>bindUntilEvent(ActivityEvent.PAUSE))
                .subscribe(new Observer<Long>() {
                    @Override
                    public void onCompleted() {
                        Log.i(TAG, "[Observables] : onCompleted()");
                    }

                    @Override
                    public void onError(Throwable e) {
                        Log.i(TAG, "[Observables] : onError()");
                    }

                    @Override
                    public void onNext(Long aLong) {
                        Log.i(TAG, "[Obsercables] : onNext()");
                    }
                });

        // for Single
        // if onPause() is executed within 5 seconds, onError (CancellationException) is called.
        Observable.interval(5, TimeUnit.SECONDS)
                .doOnSubscribe(new Action0() {
                    @Override
                    public void call() {
                        Log.i(TAG, "[Single] : Started in onCreate(), running until onPause()");
                    }
                })
                .doOnUnsubscribe(new Action0() {
                    @Override
                    public void call() {
                        Log.i(TAG, "[Single] : Unsubscribing subscription from onCreate()");
                    }
                })
                .toSingle()
                .compose(this.bindUntilEvent(ActivityEvent.PAUSE).<Long>forSingle())
                .subscribe(new SingleSubscriber<Long>() {
                    @Override
                    public void onSuccess(Long value) {
                        Log.i(TAG, "[Single] : onSuccess()");
                    }

                    @Override
                    public void onError(Throwable error) {
                        if (error instanceof CancellationException) {
                            Log.i(TAG, "[Single] : onError(CancellationException)");
                        }
                    }
                });
    }

    @Override
    protected void onResume() {
        super.onResume();

        Log.d(TAG, "onResume()");

        // for Completable
        // bindToLifecycle -> onPause();
        Observable.interval(5, TimeUnit.SECONDS)
                .doOnSubscribe(new Action0() {
                    @Override
                    public void call() {
                        Log.i(TAG, "[Completable] : Started in onCreate(), running until onResume()");
                    }
                })
                .doOnUnsubscribe(new Action0() {
                    @Override
                    public void call() {
                        Log.i(TAG, "[Completable] : Unsubscribing subscription from onResume()");
                    }
                })
                .toCompletable()
                .compose(this.bindToLifecycle().<Long>forCompletable())
                .subscribe(new CompletableSubscriber() {
                    @Override
                    public void onCompleted() {
                        Log.i(TAG, "[Completable] : onCompleted()");
                    }

                    @Override
                    public void onError(Throwable e) {
                        if (e instanceof CancellationException) {
                            Log.i(TAG, "[Completable] : onError(CancellationException)");
                        }
                    }

                    @Override
                    public void onSubscribe(Subscription d) {
                        Log.i(TAG, "[Completable] : onSubscribe()");
                    }
                });
    }

    @Override
    protected void onPause() {
        super.onPause();

        Log.d(TAG, "onPause()");
    }
}
```

ちょっと長いですが  

* `onCreate()`で`Single`と`Observable`が処理開始する（`onPause()`に明示的バインド）
* `onResume()`で`Completable`が処理を開始する（`onResume()`に対応した`onPause()`にバインド）
* 5秒以内にホームボタンを押すなりして`onPause()`を呼ぶとすべての処理が終了されてそれぞれ`onError(CancellationException)`と`onCompleted()`が呼ばれる

のを確認できると思います。  
是非試してみてください。  
  
余談ではありますが、`bindToLifecycle()`はそれぞれ`Observable``Single``Completable`で以下のようにしてあげる必要があります

* Observable  -> `.compose(bindToLifecycle())`
* Single      -> `.compose(bindToLifecycle.forSingle())`
* Completable -> `.compose(bindToLifecycle.forCompletable())`

<br><br>
## おわりに
今日は`RxLifecycle`でよく見られる勘違いについて書きました。  
適切に処理してあげないと意図しない挙動を起こす原因となるので気をつけましょう（過去の自分へ）  

以上、やぎにいでした！