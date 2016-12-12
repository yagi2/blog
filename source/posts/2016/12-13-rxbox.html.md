---
title: dropbox-java-sdkをRxJavaで使うライブラリを作ってみました
date: 2016-12-13 07:40 JST
tags: やぎすけAdventCalendar2016,Android,Java
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の13日目です。  
  
昨日は僕が[RxLifecycleでのライフサイクルへのバインドについて](https://blog.yagi2.com/2016/12/12/rxlifecycle.html)を書きました。  

今日は昨日一昨日と紹介した`RxJava`を使ったライブラリを作ってみたので紹介します。  
<br><br>
## RxBox
名前は`RxBox`です（超直球）  
リポジトリは公開していて[GitHub - yagi2/RxBox](https://github.com/yagi2/RxBox)になります。  

機能としては[Dropbox Core SDK for Java 6+](https://github.com/dropbox/dropbox-sdk-java)の機能をRxJavaでラッピングしたものです。  
DropboxのAPIはちょくちょくAndroidのアプリで使ったりするのですが、めっちゃ使いづらかったりします（個人的な感想）  
あとDropbox Core SDK for JavaのAndroidサンプルや、記事をググっても大体AsyncTaskのクラスを作ってコールバックで処理しまくるものです。  
Androidの機能を使っていないのでJavaライブラリです。AndroidでもJavaでも使えます。  
  
そこで個人的にRxJavaのObserverを返すクラスを作っていたのですが、他のアプリ作成でも使う場面が出てきたので思い切ってライブラリにしてみました。  
  
バージョン0.0.1とあるように、現在自分が使っているメソッドしかライブラリ化出来ていません。  
今後はメソッドの充実を図ります。ある程度メソッドが揃ったらv1.0として公開したいです。  
それまではWIPなライブラリとして公開しています。  
<br><br>
## 使い方
今はjcenterに登録できていないので、自分でビルドする必要があります。  
リポジトリをcloneして`./gradlew jar`を行えば`rxbox/build/libs/rxbox.jar`が作成されるのでこれをJavaプロジェクトやAndroidプロジェクトにインポートしてください。  
各メソッドは`Observable<T>`を返すので以下のように使います。  
以下はユーザのアカウントデータを取得するサンプルコードです。

```java
// for Java Project
RxBox.getCurrentAccount(DbxClientV2)
    .toSingle()
    .subscribe(new SingleSubscriber<FullAccount> {
        @Override
        public void onSuccess(FullAccount account) {
          // ここでアカウントデータをいじれる
        }

        @Override
        public void onError(Throwable error) {
          // Error
        }
    }); 

// for Android Project with RxLifecycle and RxAndroid
RxBox.getCurrentAccount(DbxClientV2)
    .subscribeOn(Schedules.io())
    .toSingle()
    .compose(bindToLifecycle().<FullAccount>forSingle())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(new SingleSubscriber<FullAccount> {
        @Override
        public void onSuccess(FullAccount account) {
          // ここでアカウントデータをいじれる
        }

        @Override
        public void onError(Throwable error) {
          // Error
        }
    });
```
  
あんまりDropboxAPIを気にせず使うことができるようになりました。  
`DbxClientV2`を渡してあげてください。  
  
使い方としては、認証→アクセストークンを保持→アクセストークンを使って`DbxClientV2`を作成→`RxBox`に渡すという感じです。  
理由としてはAndroidだと`com.dropbox.core.android.AuthActivity`で認証できちゃうためです。  
これは非常に便利な認証アクティビティで、`RxBox`で認証周りを追加するまでに至らなかったためです。  
もちろんこれはAndroid用に用意されたものでJavaプロジェクトでは使えません。  
  
僕自身あまりAndroid以外でJavaのプロジェクトを触ることがないのでJavaでは必要だけどAndroidではいらないみたいなものは実装後回しになります。ごめんなさい。  
Javaライブラリにした理由は冒頭でも上げたとおりAndroidの機能を一切使わないためです。
<br><br>
## これから
これからはメソッドの充実とテストの追加などをやっていきたいと思います。  
  
あと現状.jarファイルを自分で作ってインポートしないと使えないので早急にjCenterに登録したいと思います。  
  
bintrayに登録したのですが、個人のリポジトリを作れない（オーガニゼーションでは作れる）ので、それが解決したらとっととあげたいです。  
gradleをご覧いただければわかるのですが準備はできています……。  
いろんなbintrayを使ってjcenterに登録している記事を見てもどれもリポジトリをつくるボタンがあるのが存在しないのでbintrayに問い合わせた次第です。  
  
どなたか解決方法知っていたら教えていただけると幸いです。  
  
AndroidプロジェクトでDropboxAPIを使うときは是非試してみてください。

以上、やぎにいでした！
