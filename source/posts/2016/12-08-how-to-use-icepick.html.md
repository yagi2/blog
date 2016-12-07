---
title: Icepickを使ってActivityの破棄に備える
date: 2016-12-08 05:42 JST
tags: やぎすけAdventCalendar2016,Android
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の8日目です。
昨日は僕が[ButterKnifeを使ってソースコードのダイエットをする](https://blog.yagi2.com/2016/12/07/how-to-use-butterknife.html)を書きました。  
  
今日は[Androidプロジェクトを作って結構な確率で導入するライブラリ](https://blog.yagi2.com/2016/12/04/recommended-android-library.html)で書いた4つ目のIcepickの使い方をまとめたいと思います。  
<br><br>
## 導入
[Icepick](https://github.com/frankiesardo/icepick)の導入もいつも通り`build.gradle`に以下を追加してあげます。  

```gradle
repositories {
  maven {url "https://clojars.org/repo/"}
}
dependencies {
  compile 'frankiesardo:icepick:3.2.0'
  provided 'frankiesardo:icepick-processor:3.2.0'
}
```

このライブラリもButterKnife同様、特にアプリケーションクラスでの初期化や設定などは必要ありません。`build.gradle`をに依存関係を追加したらあとは使うだけです。  
<br><br>
## Icepickとは
Androidアプリを開発するときに、アクティビティ（やフラグメントなどのUI系）の状態が変わるのを考慮してコードを書く思います。  
ライフサイクルを調べて処理を書いたりすることが多々あると思いますが、意外なところで破棄されたりします。例えば端末を回転させたりとか（回転を抑制してない場合）すると簡単に破棄されたりします。  
そこで困るのが、`EditText`に入力していた値や`TextView`で表示していた値が保持されなかったりすると、ユーザはもう一度値を入力しなきゃならなくなったりしてとても不便なアプリになってしまいます。  
  
そんなときは`onSaveInstanceState`メソッドと`onRestoreInstanceState`メソッドをしっかり使って状態の保存復元を行います。  
それを少し楽にさせるライブラリがIcepickになります。  
<br><br>
## 使い方
簡単です、保持したい変数にアノテーション`@State`をつけ`Icepick#saveInstanceState`と`Icepick#restoreInstanceState`を呼んであげるだけです。  
実際に`EditText`が1つ存在しており、その中の値を保持するようなソースを書いてみます。 （ついでに`EditText`は昨日紹介した`ButterKnife`を使います） 

```java
public class MainActivity extends AppCompatActivity implements RecyclerViewAdapter.Listener {

    @State String editTextValue;
    @BindView(R.id.editText1) EditText editText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ButterKnife.bind(this);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
      super.onSaveInstanceState(outState);
      
      editTextValue = editText.getText().toString();
      Icepick.saveInstanceState(this, outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
      super.onRestoreInstanceState(savedInstanceState);

      Icepick.restoreInstanceState(this, savedInstanceState);
      editText.setText(editTextValue);
    }
}
```

以上のような感じになります。  
いちいち`outState.putString(KEY, VALUE);`などをいっぱい書かずに`@State`アノテーション付きの変数にさえ入っていれば保持されるので楽になりました。  
あんまり`EditText`から値を取り出して変数へツッコミとすると保持したい物分の変数が増えるので、個人的には`ButterKnife`+`Icepick`なライブラリがほしいです。（`@BindState EditText editText`とか書くと`ButterKnife`も使えるし、中の値も`Icepick`的に保持してくれるような感じで。)
<br><br>  
## おわりに
本日は短いですが、以上がIcepickの使い方になります。このライブラリも`ButterKnife`同様、ソースコードのダイエットにとても貢献してくれるライブラリです。  
`onSaveInstanceState`でめちゃくちゃいっぱい描いちゃってる……みたいな方は導入の価値があると思います。が、`ButterKnife`とはちょっと違って導入の場面を考えないと逆に変数が多くなってしまう……みたいなことになってしまうのでそこは十分にご注意を。  
  
最後に注意として`Icepick`はいろんなライブラリに依存しており芋づる式で追加されるのでメソッド数が少ない場合は注意です。`Proguard`を使う際はGithubのREADMEに設定が描いてあるのでそれを使ってあげましょう。
  
以上、やぎにいでした！