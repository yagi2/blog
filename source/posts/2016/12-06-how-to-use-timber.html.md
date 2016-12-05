---
title: TimberをLogの代わりに使用して快適ログ確認
date: 2016-12-06 05:49 JST
tags: やぎすけAdventCalendar2016
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)6日目です。そろそろキツくなってきましたね。  
昨日は僕が[Stethoを使ってGoogle Chromeでデバッグをする](http://localhost:4567/2016/12/05/how-to-use-stetho.html)を書きました。  
  
今日は[Androidプロジェクトを作って結構な確率で導入するライブラリ](https://blog.yagi2.com/2016/12/04/recommended-android-library.html)で書いた2つ目のTimberの使い方をまとめたいと思います。
<br><br>
## 導入
[Timber](https://github.com/JakeWharton/timber)の導入をします。  
`build.gradle`に`compile 'com.jakewharton.timber:timber:4.3.1'`を追加してあげるだけです（バージョンは執筆時）。  
このTimberは`android.util.Log`をラッパーしているライブラリなので非常に軽量です。とても嬉しい。 

次にアプリケーションクラスで初期化しましょう（Timberでは`Tree`を`plant`すると言います ちょっとおしゃれ）。  

```java
public class MyApplication extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    
    Timber.plant(new DebugTree());
  }
}
```

これで導入が完了しました。  
今まで`Log.d();``Log.e();`などと書いていた部分はすべて`Timber.d();``Timber.e();`に置き換えることが出来ます。  
`release`ビルドではログを出力したくない！というときは以下のように書けば`debug`ビルドだけで有効になります。  

```java
public class MyApplication extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    
    if (BuildConfig.DEBUG) {
      Timber.plant(new DebugTree());
    }
  }
}
```

簡単ですね。  
これでリリースしてるアプリのログを見られてしまうということもなくなります。  
非常に軽量ですし、`Log`ではなく`Timber`を使わない利点が無いですね！
<br><br>
## Treeをカスタマイズする
`plant`で渡しているのが`new DebugTree()`であるように、この`Tree`は自分でカスタマイズすることが出来ます。  
`DebugTree`は`Tree`クラスを継承しており、`Tree`クラスは抽象クラスとして書かれています。  
https://github.com/JakeWharton/timber/blob/master/timber/src/main/java/timber/log/Timber.java#L573  
https://github.com/JakeWharton/timber/blob/master/timber/src/main/java/timber/log/Timber.java#L390  
このへん。  
  
自分用にTreeをカスタマイズするときは`DebugTree`を継承して作ってあげるといいでしょう。

```java
public class MyDebugTree extends Timber.DebugTree {
  // ここで自分ん好みのTreeをつくる
}
```

試しに、Android Studioとかを使っていて、エラー落ちした際に該当コードの該当行数に飛ぶ機能がありますが、それをDebugにもつけてあげましょう。  
あの機能はログメッセージに` at packageName(fileName:lineNumber)`が付けばいいのでそれっぽく書きます。  

```java
package com.yagi2.recyclerview_sample;

import android.util.Log;

import timber.log.Timber;

public class MyDebugTree extends Timber.DebugTree {
    @Override
    protected void log(int priority, String tag, String message, Throwable t) {
        StackTraceElement[] thread = new Throwable().getStackTrace();

        if (thread != null && thread.length >= 5) {
            StackTraceElement stack = thread[5];
            String className = stack.getClassName();
            String packageName = className.substring(0, className.lastIndexOf("."));
            String fileName = stack.getFileName();

            String msg = message + " at " + packageName + "(" + fileName + ":" + stack.getLineNumber() + ")";

            Log.println(priority, tag ,msg);
        }
        else {
            Log.println(priority, tag, message);
        }
    }
}
```

これを3日目で書いたRecyclerViewのサンプルアプリに突っ込んで起動してみると。  
![](2016/12-06-how-to-use-timber-001.png)
  
こんな感じで`MainActivity.javaの42行目にクリックで飛べるようになりました。  
以外と便利ですね。
  
ただ、結構ガバガバなTreeになってるのでごめんなさい（かなり知識不足です）。
<br><br>
## おわりに
今回はStetho同様デバッグがしやすくなるライブラリ`Timber`の使い方と、Treeの拡張方法をご紹介しました。  
僕は間違いなくAndroidのプロジェクトを作成した直後にTimberを`build.gradle`に追加するところから始まると思います。  
  
Treeの拡張方法に寄っては、`debug`ビルド時は`DebugTree()`を使うが、`release`ビルドの際は自分で`Tree`を拡張した`MyReleaseTree()`などを定義してその中で`Crashlytics`をどうこうしてクラッシュログを収集するとかいう使い方もできるでしょうか。  
僕は未だに`release`用のログ設定を作ったことが無いのでわかりませんが何れやってみたいと思います。  
  
以上、やぎにいでした！