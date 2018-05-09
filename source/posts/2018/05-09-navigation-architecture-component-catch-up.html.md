---
title: Navigation Architecture Componentを触ってみた
date: 2018-05-09 19:03 JST
tags: Android
---

どもどもども〜。Google I/O 2018盛り上がっていますね（お家Extended勢）  
Day1のセッションやキーノートをいくつか見ていてDeveloper Keynoteに登場していた（確か）Xcodeのストーリーボードみたいな見た目をしていたNavigationが凄く気になったのでとりあえず軽く触ってみたので軽い説明と感想を書いてみる。  

注意点として、現状Android Studioの3.2のCanary 14からしか使えない（現状最新）のでアップデートしてから試してください）。

## tl;dr
- 1Activity内でのFragmentの遷移を1Navigation Graphファイルに定義してあげて、それぞれのActivityのレイアウトにセットするとFragmentを楽に扱える感じがした。  
- Navigation Editorもある（TextとDesign）ので画面遷移が見やすい感じで管理できて良さそう。  
- 今回以下で軽く書くものは [yagi2/Android-Navigation-Sample: The Navigation Architecture Component Sample App](https://github.com/yagi2/Android-Navigation-Sample) で公開してる。

## Navigation Architecture Componentとは
Google I/O 2018で発表されたてほやほやのアプリ内でのNavigationを簡単に実装できるコンポーネント。  
[The Navigation Architecture Component  |  Android Developers](https://developer.android.com/topic/libraries/architecture/navigation/)  
  
最初Developer Keynoteで見たときはそういう意識では見ていなくて「おっ！ストーリーボードみたいなやつくるやんけｗ」って思ってとりあえずさっと見て触ってみた。

## はじめかた
[Implement navigation with the Navigation Architecture Component  |  Android Developers](https://developer.android.com/topic/libraries/architecture/navigation/navigation-implementing)  
基本的にはこれに従ってやっていくと簡単に実装ができる。  
  
1点、コンポーネント類をプロジェクトに導入する際に[Adding Components to your Project  |  Android Developers](https://developer.android.com/topic/libraries/architecture/adding-components#navigation)を参考に`build.gradle`を記述するが、`AndroidX version of Navigation will be released in the future.`とあるようにNavigation関連の`androidx.*`はまだ存在しないらしい。  
のにもかかわらず、Safe argsで  
   
```groovy
buildscript {
    repositories {
        google()
    }
    dependencies {
        classpath "androidx.navigation:safe-args-gradle-plugin:1.0.0-alpha01"
    }
}
```
  
と書いてあるがこれは今の段階では解決できない。  
今の段階ではArchitecture Componentには存在するらしいのでclasspathを`android.arch.navigation:navigation-safe-args-gradle-plugin:1.0.0-alpha01`で使ってあげるとapplyすることができた。  
  
## 簡単な実装方法の解説  
上記のガイドをかいつまんで簡単に紹介すると  

- `res`ディレクトリを右クリックして`New > Android resource file`して`New resource`をする  
- 名前はいい感じにつけて（ここでは`nav_graph`）、Resource Typeを`Navigation`にする  
- `nav_graph.xml`でFragmentと遷移のActionなどを定義してあげる  
- それらを包むActivityのレイアウトファイルに`<fragment>`タグを作り`app:navGraph="@navigation/nav_graph"`を入れてあげる  
- 遷移のタイミング（ボタンを押した時）のイベントに`Navigation.createNavigateOnClickListener(R.id.hoge_action)`をあてる  
- いい感じに`nav_graph`で定義した遷移になる  
  
簡単でしょ。
サンプルアプリのソースもホントに軽いので多分サラッと読んでここに戻ってくると一瞬で理解できると思う（理解したとは言ってない）  

## 何が気に入ったか
今までActivityからFragmentを入れたり、FragmentからFragmentに遷移するときは`transaction`したり`commit`したりとおまじないのようなコードをめちゃくちゃいっぱい書いていたと思うが、それらがない。
Fragmentを使って遷移しているはずなのに、Activity/Fragment側のコードが簡潔になる。

今回作ったサンプルアプリでは1Activityアプリで、そこでFragmentの遷移を行っているが、`setContentView()`しか行っていない。
[Android-Navigation-Sample/MainActivity.kt at master · yagi2/Android-Navigation-Sample](https://github.com/yagi2/Android-Navigation-Sample/blob/master/app/src/main/java/com/yagi2/navigationsample/MainActivity.kt)  
  
サンプルアプリでは、`MainFragment -> 遷移1 -> 遷移2 -> 遷移3 -> MainFragmentに戻る`という遷移を実装している。  
実際のクラスとしては`MainFragment`と`FlowFragment`の2つだけが存在し、`FlowFragment`へ何番目のFragmentなのかを引数として渡している。  

[Android-Navigation-Sample/MainFragment.kt at master · yagi2/Android-Navigation-Sample](https://github.com/yagi2/Android-Navigation-Sample/blob/master/app/src/main/java/com/yagi2/navigationsample/MainFragment.kt)  

引数を定義しているのは`nav_graph.xml`で以下のような感じで遷移と同時に引数を定義している。  
  
```xml
...
    <fragment
        android:id="@+id/fragment_main"
        android:name="com.yagi2.navigationsample.MainFragment"
        android:label="MainFragment"
        tools:layout="@layout/fragment_main"
        >

        <action
            android:id="@+id/action_main_to_flow_one"
            app:destination="@id/fragment_one"
            app:enterAnim="@anim/slide_in_right"
            app:exitAnim="@anim/slide_out_left"
            app:popEnterAnim="@anim/slise_in_left"
            app:popExitAnim="@anim/slide_out_right"
            />
    </fragment>

    <fragment
        android:id="@+id/fragment_one"
        android:name="com.yagi2.navigationsample.FlowFragment"
        android:label="fragment_one"
        tools:layout="@layout/fragment_one"
        >

        <argument
            android:name="number"
            android:defaultValue="1"
            app:type="integer"
            />

        <action
            android:id="@+id/action_next_flow"
            app:destination="@id/fragment_two"
            app:enterAnim="@anim/slide_in_right"
            app:exitAnim="@anim/slide_out_left"
            app:popEnterAnim="@anim/slise_in_left"
            app:popExitAnim="@anim/slide_out_right"
            />
    </fragment>
...    
```

これは`MainFragment`から次の1つ目のFragmentに遷移する部分の抜粋で、`@id/fragment_main`の中に`<action>`タグで遷移を書く。  
`app:destination`で行き先のFragment（これはクラスではなくてNavigationでの`<fragment>`のこと）を指定する。  
  
`@id/fragment_one`ではargumentを定義してあって、defaultValueを1で定義している。そして次のFragmentに遷移するactionを記述している。
  
ここで定義した引数はFragmentから普通に取得することができ、[Android-Navigation-Sample/FlowFragment.kt at master · yagi2/Android-Navigation-Sample](https://github.com/yagi2/Android-Navigation-Sample/blob/master/app/src/main/java/com/yagi2/navigationsample/FlowFragment.kt)のようなクラス実装になっている。

## 感想
ふんわりしか触っていないのでまだあまり理解してない上に知らない機能（Nested GraphもあるっぽいしActivityもNavigationに置けるのでどう使えば良いか……）があるのでちょくちょく触りたい。
  
個人的にFragmentの管理がソースコードからだと結構わかりにくくなってしまう上に、プロジェクト引き継ぎ等の際に読み解くのが結構困難なのでかなり便利なのではないかという感想。

今の所触った感じでいうと、1Activityの中のFragmentの遷移を1Navigation Graphファイルに書いてあげて、それをActivityのレイアウトで指定してあげると良さそう。  
Google I/Oを見ている感じむやみにActivityを作らずにせよみたいな雰囲気だったのでこういうツールとコンポーネントで後押ししている感じがした。  
  
マジでストーリーボードみたいなエディターめちゃくちゃ見やすいので神。  
<img src="/images/2018/05-09-navigation-architecture-component-catch-up-001.png" width="100%">

使える機会があったら積極的に使っていくのが良さそう。（たぶん）  

（間違いとか新しいのを見つけたときは追記や訂正します）