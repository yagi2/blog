---
title: Kotlin Android Extensionsを使ってfindViewByIdとさよならする
date: 2017-10-18 19:39 JST
tags: Android,Kotlin
---

今回はAndroidの開発でよく書く`findViewById(ID)`をKotlin Android Extensionsを使ってさよならしたいと思います。  
  
## findViewById  
そもそも`findViewById`ですが、Androidの開発においてレイアウトを定義したXMLファイルに書いてあるidを参照して、Viewをコード側から触る時に使います。  

```kotlin
val button = findViewById(R.id.button) as Button
```

のような感じです。（サンプルコードは全てKotlinです）
  
`findViewById`の歴史を紐解いてみると、そこから`ButterKnife(KotterKnife)`を使ってViewのInjectionを行ったりし、最近だと`DataBinding`がとてもアツいのでそれを使って以下のように書いたりします。  

```kotlin
// KotterKnife
val nameTextView: TextView by bindView(R.id.name)

// DataBinding
val binding = DataBindingUtil.setContentView(activity, R.layout.hoge)
binding.nameTextView.text = "おなまえ"
```

`ButterKnife(KotterKnife)`では結局IDを参照させないといけないし、`DataBinding`は本質的な部分はViewとデータのバインディングにあるので、`findViewById`を消すためだけに使用するのはなんかイマイチ違う気がしています（個人の感想です）。  

そこで出てくるのが[Kotlin Android Extensions](https://kotlinlang.org/docs/tutorials/android-plugin.html)です。  

## Kotlin Android Extensions
Kotlin Android ExtensionsはKotlinが公式で提供している、Androidアプリ開発をサポートしてくれる拡張機能です。  
詳細は[ここ](https://kotlinlang.org/docs/tutorials/android-plugin.html)  
色々機能はあるんですが、とりあえず  

```groovy
apply plugin: 'kotlin-android-extensions'
```

を`build.gradle`に書いてあげて  

```kotlin
import kotlinx.android.synthetic.main.<layout>.*

// R.layout.activity_mainなら
import kotlinx.android.synthetic.main.activity_main.*
```

のインポート文を書いてあげてください。  

もうこれだけでインポートしたActivityではLayoutXMLで定義したidがそのまま使えます。

```xml
<!-- activity_main.xml -->
<TextView
  android:id="@+id/firstName"
  android:layout_width="match_parent"
  android:layout_height="wrap_content"
  android:text="ファーストネーム"
  />
```

```kotlin
// MainActivity.kt
import kotlinx.android.synthetic.main.activity_main.*

//...
firstName.text = "ふぁーすとねーむ"
```

こんな感じで特別変数を用意する必要も、R.id.hogeを参照する必要もなくなりました。  
✨すっきり✨  

## 注意点
レイアウトのXMLファイルでのidをスネークケースで書くと、フィールドもスネークケースになるので注意

```xml
<TextView
  android:id="@+id/text_view"
  .../>
```

```kotlin
text_view.text = "テキスト" // ←イマイチ
```

この点に関してはDataBindingは勝手にキャメルケースにしてくれるので勝ちと言えそうですね。  
Kotlin Android Extensionsを使うために、レイアウトファイル上でのidをキャメルケースにするかどうかはプロジェクトで要相談してください（僕は良いと思う）。

## まとめ
- Androidアプリ開発にKotlinを使っているならKotlin Android Extensionsを有効にしておこう
- データのバインディングを行わないケースならDataBindingよりもこっちを使ったほうが良さそう
- そろそろスネークケースとおさらばしたい気持ち
