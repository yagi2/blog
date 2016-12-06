---
title: Stethoを使ってGoogle Chromeでデバッグをする
date: 2016-12-05 18:41 JST
tags: やぎすけAdventCalendar2016,Android
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の5日目です。  
昨日は僕が[Androidプロジェクトを作って結構な確率で導入するライブラリ](https://blog.yagi2.com/2016/12/04/recommended-android-library.html)を書いて5つのライブラリを紹介しました。  
今日はその中から[Stetho](https://github.com/facebook/stetho)の使い方をまとめていきます。  
<br><br>
## 導入
Androidで導入する際には`build.gradle`に`compile 'com.facebook.stetho:stetho:1.4.1'`を追加してあげてください（執筆時最新が1.4.1でした）。  
`build.gradle`にStethoを追加したら、次はアプリケーションクラスで初期化してあげます。

```java
public class MyApplication extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    
    Stetho.initialize(
      Stetho.newInitializerBuilder(this)
        .enableDumpapp(Stetho.defaultDumperPluginsProvider(this))
        .enableWebKitInspector(Stetho.defaultInspectorModulesProvider(this))
        .build());
    )
  }
}
```

基本はこれを書けば導入完了になります。  
後はこれを導入したアプリをエミュレータや実機で実行し、GoogleChromeのアドレスバーに`chrome://inspect/#devices`と入力してあげれば`inspect`というリンクが表示されるはずです。 
  
試しに12月3日に書いた[さくっとRecyclerViewを使ってリストを作成する](https://blog.yagi2.com/2016/12/03/how-to-use-recyclervie.html)で作ったアプリに導入してみましょう。
![](2016/12-05-how-to-use-stetho-001.png)

この状態だと、`Resouces`でアプリが持つ`Preference`の値や`SQL`の中身、`Elements`では`View`の構造をWebページを見ているかの用にデバッグできると思います。
この状態でもかなり便利ですね。`Preference`の値も自分で`Developer Tool`で追加変更もできます。  
同じように以前のサンプルアプリで`View`の構造を見てみるとこうなります。  
![](2016/12-05-how-to-use-stetho-002.png)
<br><br>
## Realmのデータを確認する
僕自身最近Androidで利用するORMとして[Realm](https://realm.io/jp/)を個人的によく使用するようになりました。  
`Realm`の詳しい紹介は機会があればするとして、デフォルトの初期化だと`SQL`は覗けるものの、`Realm`のデータは覗くことが出来ません。  
以下のように導入して`Realm`のデータも確認できるようにしましょう。  
  
まず、`Stetho-Realm`を導入します。[Stetho-Realm](https://github.com/uPhyca/stetho-realm)  
`build.gradle`に

```gradle
repositories {
    maven {
        url 'https://github.com/uPhyca/stetho-realm/raw/master/maven-repo'
    }
}

dependencies {
    compile 'com.uphyca:stetho_realm:2.0.0'
}
```

を書いてあげます。  
そして先ほどアプリケーションクラスに書いた初期化処理を以下のように書き換えます。  

```java
public class MyApplication extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    
    Stetho.initialize(
      Stetho.newInitializerBuilder(this)
        .enableDumpapp(Stetho.defaultDumperPluginsProvider(this))
        // 以下の行が変更点
        .enableWebKitInspector(RealmInspectorModulesProvider.builder(this).build())
        .build());
    )
  }
}
```

これで.realmのデータをチェックすることが可能になります。  
Realm公式で[Realm Browser](https://realm.io/jp/docs/java/latest/#realm-browser)が配布されていますが、僕自身はAndroidの開発で使ったことはないです。  
`RealmInspectModulesProbider``this`を渡せばデフォルトの設定になりますた、設定用のメソッドを使い自分好みの設定を行うことも出来ます。
[RealmInspectorModulesProvider.java](https://github.com/uPhyca/stetho-realm/blob/master/stetho_realm/src/main/java/com/uphyca/stetho_realm/RealmInspectorModulesProvider.java)に載っていますが、個人的によく使う物をピックアップします。  

* `withLimit()`  
これはデータの表示件数の上限を指定します。デフォルトは250件ですが、`withLimit(long)`で指定した件数表示できます。  
大きくしすぎるとかなり時間がかかってしまうので気をつけてください。僕は大体500にしています。  

* `withDescendingOrder()`  
テーブル内のデータはインデックスの値に従ってソートされていますが、それをデフォルトの昇順から降順に変更します。  
開くだけで後ろのデータを確認したいときによく使っています。  

<br><br>
## ネットワーク状況を見る
様々なAPIを使ってjsonを取得したり、画像を取得したりして処理をする、のような事をAndroidアプリではよくやると思いますが、その際にうまく動かないと「APIサーバが応答していないのか」「処理が間違っているのか」等様々な可能性に当たります。  
そのときにCheomeのDevToolを使ってレスポンス時間などを確認できるようにしましょう。 　
今回は僕自身がAPI取得や画像周りには`Retrofit`や`Picasso`を使うのでそれを前提に紹介します。  
  
まずおなじみ`build.gradle`に依存関係を書いてあげます`compile 'com.facebook.stetho:stetho-okhttp3:1.4.1'`と書いてあげれば大丈夫です。  
そして使う際は、それぞれのインスタンスを生成するときに`NetworkInterceptors`を追加した`OkHttpClient`を追加してあげます。  
以下の感じです。  

```java
// OkHttpClientのnetworkInterceptorsにStethoを追加する
OkHttpClient client = new OkHttpClient();
client.networkInterceptors().add(new StethoInterceptor());
```

そしてここで生成した`client`を`Retrofit`や`Picasso`の`Builder`に渡してあげます。

```java
// Retrofit
RestAdapter restAdapter =  new RestAdapter.Builder()
        .setEndpoint("http://example.com/")
        .setClient(new OkCkient(client))
        .build();

// Picasso
Picasso picasso = new Picasso.Builder(this)
        .downloader(new OkHttpDownloader(client))
        .build();

// Picassoはこれをシングルトンインスタンスとして指定する
Picasso.setSingletonInstance(picasso);
```

以上のように設定してあげればChromeのDevToolsで確認できます。  
<br><br>
## おわりに
機能紹介したライブラリの1つ`Stetho`を紹介しました。  
個人的にAndroidアプリを開発する上で無くてはならないライブラリとなっているので本当におすすめできるライブラリです。  
デフォルトの設定でも十分使えますが、自分でより細かく設定できるのも魅力の1つだとおもいます。
  
尚蛇足ではありますが、記事執筆当時のバージョンで書いているので、導入する際はバージョンを確認してください。  
  
以上、やぎにいでした！