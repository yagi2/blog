---
title: Javaでリストを操作するときにfor文をやめてみる
date: 2016-12-10 04:23 JST
tags: やぎすけAdventCalendar2016,Java
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の10日目です。  
ついに10日ですね。今年も残すところあと21日、そしてアドベントカレンダーはのこり15日。そう考えると半分近く来たものですね。
      
昨日は僕は[Androidアプリ開発のちょっとした小ネタ](https://blog.yagi2.com/2016/12/09/tips-of-development-android-app.html)を書きました。  
これを書いた当日の夜にも実はタレが増えました。そのうちまとめてご紹介します。
  
今日はプログラムを書くときに欠かせないリスト操作のお話です。  
## はじめに

```java
List<String> messages = Arrays.asList("やぎにい", 
                                      "うなすけ",
                                      "やぎすけ", 
                                      "アドベントカレンダー", 
                                      "2016-12-10", 
                                      "首を突っ込む", 
                                      "やっていき");
```

のようなリストがあり、それぞれの要素を1つずつ表示したい時どうやって表示していたでしょうか。  
僕は以下の通りやっていました。  

```java
for (String str : messages) {
    System.out.println(str);
}
```

定番ですね拡張for文（for-each）を使って処理してあげると非常にスマートにかけます。  
僕は初めて触ってそのまま長いこと使っていたのが`C言語`だったため最初は

```java
for (int i = 0; i < messages.size(); i++) {
    System.out.println(messages.get(i));
}
```

の用に書いていましたが、初めてfor-eachに出会った時はすんごい楽だし見やすいなと感動したのを覚えています。
  
さて、今回の話はこういうリストなどを操作するときにfor文を使わずにやってみようというお話です。  
前提条件として以下の2つのリストを使います。

```java
List<String> msgJapanese = Arrays.asList("やぎにい", 
                                         "うなすけ", 
                                         "やぎすけ", 
                                         "アドベントカレンダー", 
                                         "2016-12-10", 
                                         "首を突っ込む", 
                                         "やっていき");
		
List<String> msgEnglish = Arrays.asList("yagi2", 
                                        "unasuke", 
                                        "yagisuke",  
                                        "advent-calendar",
                                        "2016-12-10", 
                                        "kubi wo tukkomu", 
                                        "yatteiki");
```

<br><br>
## 出力してみる
java8に`java.util.function.Consumer`を引数に取る`forEach(Consumer action)`メソッドが存在します。  
名前がいかにもそれっぽい！ 早速使ってみる。
Consumerのインスタンスは`accept(T)`メソッドで処理を実装できる。引数の消費者。

```java
msgJapanese.forEach(new Consumer<String>() {
    public void accept(final String str) {
		    System.out.println(str);
		}
});
```

おお、いけた。でもfor-each文でよくね？感が出てきちゃいました。  
そこでjava8のラムダ式。こいつを使ってみます。  

```java
msgJapanese.forEach(str -> System.out.println(str));
```

……は？1行だと……。  
ラムダ式はちょっと慣れるまで読みづらいイメージがありますが、`RxJava`でのサンプルコードや知見はラムダ式で転がっていることが多いので僕もラムダ式に慣れていきましょう。  
<br><br>
## 加工してみる
`msgEnglish`を大文字に加工してみる

```java
List<String> msgEnglishUppercase = new ArrayList<>();
msgEnglish.forEach(str -> msgEnglishUppercase.add(str.toUpperCase()));
msgEnglishUppercase.forEach(str -> System.out.println(str));
```

出力まですると`.forEach(str -> System.out.println(str.toUpperCase()));`でいいのでは？となりますが、今回は加工のお話なのでご容赦を。  
  
ふむふむなるほど。でもやっぱり変数を宣言してそれに加工して〜というのがいまいちな気がする。  
加工するということは加工した結果を使うわけだからそれを次に渡す、のような処理を行いたいですね。  
  
そんなときはJava8の`Stream`です。  
`Stream`では関数を連続して適用するようなことができます。◯◯した結果を✕✕して▲▲する。のようにできます。  
やってみましょう。  

```java
msgEnglish.stream().map(str -> str.toUpperCase()).forEach(str -> System.out.println(str));
```

これです……まさに求めていたのはこれ！ まるまる→ばつばつ→さんかくさんかく 流れるStreamです。  
せっかくなのでメソッド参照を使ってみましょう。

```java
msgEnglish.stream().map(String::toUpperCase).forEach(str -> System.out.println(str));
```

つよい……！見た目でわかりやすい。  
今までの拡張for文を使って加工してそれを出力よりだいぶコード量もスッキリするはずです。
<br><br>
## Stream
じゃあめっちゃ`Stream`ってすごいじゃん。となります。
上記ではリストを加工するために`map`を使いました。これは基本的に要素を変換します。
他にも中間操作が存在し、僕がよく使うのを紹介します。
  
* filter

これは式が真になる要素を次に渡します。

```java
msgJapanese.stream().filter(str -> str == "うなすけ").forEach(str -> System.out.println(str));
```

とすれば”うなすけ”という文字列だけ取り出すことが出来ます。  
数値であれば

```java
List<Integer> num = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
num.stream().filter(n -> n % 2 == 0).forEach(n -> System.out.println(String.valueOf(n)));
```

で1〜10の数字の中で偶数だけ取り出すことが出来ます。
他にも`sorted`や`skip`等の中間操作もあります。  
  
中間操作は上記で上げたようにいろいろありますが、終端操作（いままでは`.forEach`）も複数種類があります。
こちらも個人的によく使うのも紹介します。

* count

最終的な要素数を返します。

```java
List<Integer> num = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
System.out.println(String.valueOf(
    num.stream().filter(n -> n % 2 == 0).count()
    ));
```
とやれば、1〜10で偶数の個数を出力することが出来ます。
※`println`で囲っているため、`Stream`の部分だけわかりやすいように変な改行をしています。

* max, min

最小値、最大値を返します。

```java
Random rnd = new Random();
System.out.println(String.valueOf(
    num.stream().map(n -> rnd.nextInt(101)).max(Integer::compare)
    .orElse(-1)));

System.out.println(String.valueOf(
	num.stream().map(n -> rnd.nextInt(101)).min(Integer::compare)
    .orElse(-1)));
```

`min(Compare) max(Compare)`の`Compare`で比較した結果の最大値最小値が`Optional`で返ってきます。

ここらへんをよく使います。
<br><br>
## おわりに
今日はコード量も多く、長かったですがJavaでリストの操作をするときに拡張for文をやめよう！という話でした。  
今回はStreamやラムダ式のような`Java8`での機能をふんだんに使いましたが、`Java7`でも

* [evant/gradle-retrolambda](https://github.com/evant/gradle-retrolambda)    
* [aNNiMON/Lightweight-Stream-API](https://github.com/aNNiMON/Lightweight-Stream-API)

のようなライブラリを使うと同じような操作をすることができます。  
僕もほとんどのAndroidアプリをJava7で触っていますが、そろそろJava8の時期になっていますね。  

今回いろいろな操作は`Gradle Project`で作成し[yagi2/java8-list-sample](https://github.com/yagi2/java8-list-sample)においておきました。  
大切なのは[Main.java](https://github.com/yagi2/java8-list-sample/blob/master/src/main/java/Main.java)です。（ちょっとインデント崩れてる）
  
以上、やぎにいでした！！