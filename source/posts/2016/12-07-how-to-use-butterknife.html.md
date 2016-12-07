---
title: ButterKnifeを使ってソースコードのダイエットをする
date: 2016-12-07 09:20 JST
tags: やぎすけAdventCalendar2016,Android
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の7日目です。12月も1週間が経過してしまいました。なんだか記事を書く、新しい知識を得たらどこかにメモを取る癖がついてきた気がします。  
昨日は僕が[TimberをLogの代わりに使用して快適ログ確認](https://blog.yagi2.com/2016/12/06/how-to-use-timber.html)を書きました。  
  
今日は[Androidプロジェクトを作って結構な確率で導入するライブラリ](https://blog.yagi2.com/2016/12/04/recommended-android-library.html)で書いた3つ目のButterKnifeの使い方をまとめたいと思います。
<br><br>
## 導入
[ButterKnife]()を導入します。いつも通り`build.gradle`を開いて。

```gradle
dependencies {
  compile 'com.jakewharton:butterknife:8.4.0'
  annotationProcessor 'com.jakewharton:butterknife-compiler:8.4.0'
}
```

を書いてあげて`Sync`すればもう導入完了です。  
特にアプリケーションクラス等での初期化とかも要らないので、早速Activity等で使ってみましょう。  
今回も3日目に書いた[さくっとRecyclerViewを使ってリストを作成する](https://blog.yagi2.com/2016/12/03/how-to-use-recyclervie.html)のソースコード[yagi2/RecyclerView-sample](https://github.com/yagi2/RecyclerView-sample)を使って行きたいと思います。  
<br><br>
## 使い方
使い方は簡単です、`findViewById`をしているものをアノテーションを用いてフィールドとしてやります。
実際に[さくっとRecyclerViewを使ってリストを作成する](https://blog.yagi2.com/2016/12/03/how-to-use-recyclervie.html)のMainActivityで使ってみましょう。  
以下のような感じです。  

```java
public class MainActivity extends AppCompatActivity implements RecyclerViewAdapter.Listener {

    private RecyclerView mRecyclerView;
    // 以下省略

// を以下の通り書き換えましょう
public class MainActivity extends AppCompatActivity implements RecyclerViewAdapter.Listener {

    @BindView(R.id.recycler_view) // @BindViewアノテーションにViewのidを渡してあげる
    RecyclerView mRecyclerView;

    // 中略

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ButterKnife.bind(this); // この行を追加してください。
```

これで実行しても`RecyclerView`の参照している部分で特に`null`落ちもせずにアイテムが表示されたと思います。  
  
アイテムをタップした際のコールバックメソッドにもButterKnifeを適用してみましょう

```java
@Override
public void onRecyclerClicked(View v, int position) {
    TextView textView = (TextView) v.findViewById(R.id.text); // この行を
    Toast.makeText(this, textView.getText().toString(), Toast.LENGTH_SHORT).show();
}
```


```java
@Override
public void onRecyclerClicked(View v, int position) {
    TextView textView = ButterKnife.findById(v, R.id.text); // こう変更します
    Toast.makeText(this, textView.getText().toString(), Toast.LENGTH_SHORT).show();
}
```

`ButterKnife#findById`を使用することに酔って、`findViewById`のときに必要だったViewのキャストが必要なくなります。  
結構lintに指摘されるのでかなり便利ですね。  
  
`ButterKnife`は`Adapter`の`ViewHolder`にも適用します。  
実際に[さくっとRecyclerViewを使ってリストを作成する](https://blog.yagi2.com/2016/12/03/how-to-use-recyclervie.html)で作った`Adapter`を使ってやってみましょう。
先ほどと同じようにしてあげます。`ViewHolder`は以下の通りになります。  

```java
public class ViewHolder extends RecyclerView.ViewHolder {
    @BindView(R.id.text) TextView textView;

    public ViewHolder(View itemView) {
        super(itemView);
        ButterKnife.bind(this, itemView);

        textView = (TextView)itemView.findViewById(R.id.text);
    }
}
```

以上の通りで`Adapter`にも`ButterKnite`を適用させることができます。  
今回のこのソースでは`View`の数が少ないのであんまり効果がわからないかもしれませんが、`onCreate`でたくさん`findViewById`をしている場合等、これを使うとスッキリします。  
<br><br>
## さらなる使い方
`View`のバインドについて紹介しましたが、イベントリスナーも`ButterKnife`で作ってあげることが出来ます。  
例えばボタンを押したらトーストを表示させるような場合

```java
findViewById(R.id.button).setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        Toast.makeText(this, "押された!", Toast.LENGTH_LONG).show();
    }
});
```
このように書いてあげたりすると思いますが、`ButterKnife`を使うとアノテーションでこれも処理できます。  

```java
@OnClick(R.id.button)
void buttonClick() {
    Toast.makeText(this, "押された!!", Toast.LENGTH_LONG).show();
}
```

こっちも見た目がスッキリしますね。  
複数のボタンで同じ処理をするときはアノテーションに複数`View`の`id`を渡します。

```java
@OnClick(R.id.button1
         R.id.button2
         R.id.button3
         R.id.button4)
void buttonClick() {
    Toast.makeText(this, "押された!!", Toast.LENGTH_LONG).show();
}
```

結構`View`のイベントリスナーはどうやってセットしようかというのは迷うと思うのですが、`ButterKnife`を使ってあげることによって見やすく書いてあげることが出来ます。  
使えるアノテーションは[JakeWharton/butterknife#butterknife-annotations](https://github.com/JakeWharton/butterknife/tree/master/butterknife-annotations/src/main/java/butterknife)にある通りです。  
`String`や`int`、`dimen`などリソースで`id`を渡して設定しているものも`bind`することができます。  
同じ文言を使用するとかの場合にいちいち`R.string.hoge_msg`とか書く必要がなくなりますね。  
<br><br>
## おわりに
今回は`View`などを簡単にセットして`findViewById`を減らし、ソースコードをダイエットする話を書きました。  
僕はこの`ButterKnife`に出会ってから`Fragment``Activity`のソースをかなりダイエットさせることができました。  
 　
実はAndroidには[データ バインディング ライブラリ](https://developer.android.com/topic/libraries/data-binding/index.html)が存在してそっちでも同じように書くことができるのだが、未だにButterKnifeを使っているプロジェクトが多く感じる。  
でもそろそろこっちも触って置いたほうが良いんだろうなと個人的にも思っているところでした。  
  
以上、やぎにいでした！