---
title: さくっとRecyclerViewを使ってリストを作成する
date: 2016-12-03 01:47 JST
tags: やぎすけAdventCalendar2016
---
  
こんにちは、やぎにいです！  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)3日目です。今のところ順調ですね。  
2日目に昨日はうなすけが[やぎすけ Advent Calendar 2日目 Gemfileの整頓](https://blog.unasuke.com/2016/yac-day02-gemfile/)を書いてくれました。  
ここに出てきたRailsアプリはアドベントカレンダー後半で数日に渡って公開していきたいと思います。  
<br>
## RecyclerViewとは
Androidにはリストを表示するときに`ListView`なり、`GridView`なりありますがAndroidのサポートライブラリv7で提供されているより柔軟なものが`RecyclerView`になります。（ざっくり）  
`ListView`や`GridView`表示を行えるのですが、じゃあそれらと何が違うの？と言うとそれらと比べて自由にカスタマイズできるという点があります。  
`ListView`,`GridView`で解決できないような物などに出会った際`RecyclerView`を使うのが良いと思います。  
  
単純に`ListView`などで十分な場合はそれでいいと思いますが、個人的にあとで「あーやっぱ`RecyclerView`にしとけばよかった」みたいになった時に面倒なので、最近は最初からこちらを使うようにしています。  
「カスタマイズ性が高い」ので最初最小構成で`RecyclerView`を構築した際にはリストのアイテム間の区切り（devider）が無いなどありますが、この記事ではそういうカスタマイズを省いて最小構成でサクッと`RecyclerView`を実装してアイテムを表示する流れを紹介します。
<br><br>
## ひつようなもの  

* Android 2.1以上（API Level7以上）
* サポートライブラリ
  
今回はNexus 5X（Android 7.1.1）で実機実行をしています。  
<br><br>
## ライブラリの導入
`app/build.gradle`の`dependencies`に  
  
```
compile 'com.android.support:recyclerview-v7:25.0.1'
```  

を追加します。
Android Studioを使用している場合は、appを右クリックすると`Open Module Settings`があるのでそこから`recyclerview`で検索するとライブラリが存在すると思います。  
<br><br>
## layoutファイルを作成する
書くものは2つです  
  
* `RecyclerView`本体
* `RecyclerView`のアイテムのレイアウト
  
順番にやっていきましょう  
まず、`RecyclerView`本体。これは実際に配置したい場所に書いてあげます。  
今回は`layout/activity_main.xml`の中に書きました。
  
```xml
<android.support.v7.widget.RecyclerView
    android:id="@+id/recycler_view"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
```
  
次に`RecyclerView`内のアイテムのレイアウトです、今回は`TextView`だけ配置します。
  
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical" android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <TextView
        android:id="@+id/text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textAppearance="@style/TextAppearance.AppCompat.Large"/>
</LinearLayout>
```  
  
今回これは`layout/list_item.xml`として配置しました。
  
以上でレイアウトの準備は完了です。
<br><br>
## Adapterを作成する
続いて`Adapter`を作成します。 まず完成形をペタッと。
  
```java
public class RecyclerViewAdapter extends RecyclerView.Adapter<RecyclerViewAdapter.ViewHolder>  {
    private LayoutInflater mInflater;
    private ArrayList<String> mData;
    private Listener mListener;

    // アイテムタップ用interface
    public interface Listener {
        void onRecyclerClicked(View v, int position);
    }

    public RecyclerViewAdapter(Context context, ArrayList<String> data, Listener listener) {
        mInflater = LayoutInflater.from(context);
        mData = data;
        mListener = listener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ViewHolder(mInflater.inflate(R.layout.list_item, parent, false));
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        holder.textView.setText(mData.get(position));

        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mListener.onRecyclerClicked(view, position);
            }
        });
    }

    @Override
    public int getItemCount() {
        if (mData == null) {
            return 0;
        }
        else {
            return mData.size();
        }
    }

    // ViewHolder
    public class ViewHolder extends RecyclerView.ViewHolder {
        TextView textView;

        public ViewHolder(View itemView) {
            super(itemView);
            textView = (TextView)itemView.findViewById(R.id.text);
        }
    }
}
```
  
継承するのは`RecyclerView.Adapter<ViewHolder>`になります。今回はインナークラス`RecyclerViewAdapter.ViewHolder`として実装しました。
`TextView`しかアイテムが存在しないのでそれだけ書いてあげます。  
  
アイテムをタップしたときのイベント用に`interface`を作成しています。`RecyclerViewAdapter.Listener`として実装しています。  
`onRecyclerClicked()`としてタップされた場所と`view`を引数として定義しています。  
  
コンストラクタではコンテキストと実際のデータ（今回は`TextView`に表示するための`ArrayList<String>`）とインターフェースを受け取ってセットしています。
  
`onCreateViewHolder`では先ほど作成したアイテムのレイアウトを指定して、`ViewHolder`を作成しています。
  
`onBindViewHolder`では実際にアイテムに受け取ったデータをセットして、イベントリスナーをセットしています。  
  
タップイベント用のインターフェース、及び`ViewHolder`は別ファイルとしてもいいですが、この程度の規模であればクラス内に実装してあげて大丈夫でしょう。
<br><br>
## RecyclerViewにAdapterをセットする
`Adapter`が完成したらあとはもうデータを渡して`RecyclerView`にセットすれば完了です。  
今回は`Fragment`ではなく`Activity`（MainActivity）でやっていきます。
まず完成形をペタリ

```java
public class MainActivity extends AppCompatActivity implements RecyclerViewAdapter.Listener {

    private RecyclerView mRecyclerView;
    private RecyclerViewAdapter mRecyclerViewAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mRecyclerView = (RecyclerView)findViewById(R.id.recycler_view);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));

        ArrayList<String> data = new ArrayList<>();
        data.add("うなすけ");
        data.add("やぎにい");
        data.add("アドベントカレンダー");
        data.add("やっていき！");

        mRecyclerViewAdapter = new RecyclerViewAdapter(this, data, this);
        mRecyclerView.setAdapter(mRecyclerViewAdapter);
    }

    @Override
    public void onRecyclerClicked(View v, int position) {
        TextView textView = (TextView)v.findViewById(R.id.text);
        Toast.makeText(this, textView.getText().toString(), Toast.LENGTH_SHORT).show();
    }
}

```
   
  
必要なのは以下の部分。

```java
mRecyclerView = (RecyclerView)findViewById(R.id.recycler_view);
mRecyclerView.setLayoutManager(new LinearLayoutManager(this));

//データの作成
ArrayList<String> data = new ArrayList<>();
data.add("うなすけ");
data.add("やぎにい");
data.add("アドベントカレンダー");
data.add("やっていき！");

mRecyclerViewAdapter = new RecyclerViewAdapter(this, data, this);
mRecyclerView.setAdapter(mRecyclerViewAdapter);
```        
  
簡単ですね！基本的な感じは`ListView`や`GridView`と変わりません。  
このコードで実行すると`ListView`になりますが、`GridView`にしたい場合は2行目の部分を

```java
mRecyclerView.setLayoutManager(new GridLayoutManager(this, 2));
```

としてあげれば良いです。（第2引数はspanの数です）  
  
さらに横方向にスクロールするようなリストにしたい場合は
  
```java
LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
mRecyclerView.setLayoutManager(linearLayoutManager);
```
  
Activityは先ほどAdapterで作成したインターフェースを`implements`で渡してあげて、オーバーライドしてあげます。
今回はタップされたら、そのアイテムの文字をトーストで表示するような実装をしています。    
  
```java
public class MainActivity extends AppCompatActivity implements RecyclerViewAdapter.Listener {
...省略...

    @Override
    public void onRecyclerClicked(View v, int position) {
        TextView textView = (TextView)v.findViewById(R.id.text);
        Toast.makeText(this, textView.getText().toString(), Toast.LENGTH_SHORT).show();
    }
}
```
  
これでRecyclerViewの一通りの実装は完了です。  
このままだと区切り線などがないので、必要な方は実装する形になります。  
途中で横スクロールのリストを設定する際に`LinearLayoutManager`を自分で作成したことからわかるように、こうやって自分で作成することよって様々にカスタマイズをすることが出来ます。  
`ListView`から`GridView`に簡単に移行できるのも結構便利ですね。  
<br><br>
## おわりに
いかがでしたでしょうか。僕も最初はとっつきにくいと思い`ListView`などで頑張っていたのですがやってみると意外と簡単に実装できてしまいます。  
確かにそれらと比べて自前で実装しなければならないのがとても多いですが、意外ときれいに実装できるので最初にぐっと実装してしまえば以降は柔軟に使っていくことができると思います。  
  
今回ここで紹介したコードはAndroid ProjectとしてGithubに公開しておきました。  
[yagi2/RecyclerView-sample](https://github.com/yagi2/RecyclerView-sample)  
どなたかの参考に慣れれば幸いです。  
  
以上、やぎにいでした！