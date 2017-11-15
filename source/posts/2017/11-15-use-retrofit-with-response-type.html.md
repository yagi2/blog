---
title: Retrofit2+RxJava2を使ってレスポンスのステータスコードによってパースするモデルクラスをよしなにしたい時
date: 2017-11-15 20:30 JST
tags: Android
---

タイトルが長いですがつまり  
Retrofit2 + RxJava2 という使い方をしていて、レスポンスが2xx系などの正常と4xx,5xxなどの異常なケースでパースしたいモデルクラスが違う時にどうしたらいいかという話です。  
エラーレスポンスが共通なJSONとかのAPIで使えます。  
  
## よくやる書き方
よくやるServiceの書き方はこれですね  

```kotlin
@GET
fun getUser(): Single<User>
```

これを書いてあげればConverterがよしなにレスポンスをUserクラスにパースしてくれます（Gson,Moshi等ありますが本題に関係ないので割愛）  
  

## 200〜300の正常系とそれいがいの異常系で分けたい
`retrofit2.Response<T>`というのが`retrofit2`には含まれており、それを使うことに寄って実現できます。  
正常/異常の判断は`Response#isSuccessfull()`がBooleanで教えてくれるのでこれを使います。
例えばこんな感じです。

```kotlin
@GET
fun getUser(): Single<Response<User>>
```

と定義しておけば

```kotlin
service.getUser()
  .subscribeOn(Schedulers.io())
  .subscribe({
    if (it.isSuccessfull()) {
      // ここは正常系の時に来る
      // it is User
      
      textView.text = it.name
    } else {
      // ここは異常系の時に来る
      // it is ResponseBody
      // ナマのResponseBodyが来てるのでエラークラスにパースするなら 例えばMoshiなら
      
      val moshi = Moshi.Builder().add(KotlinJsonAdapterFactory()).build()
      moshi.adapter(Error::class.java).fromJson(it.errorBody()?.string())
    }
  }, { Timber.e(it) })
  
```

のように書くことができます。  


## 何が違うか
だいたいこんなかんじ。

|                                         | <font color="red">T</font>|<font color="red">Response<T></font>|
|:----------------------------------------|:--------------------------|:-----------------------------------|
| <font color="green">正常</font>          | onSuccess                 | onSuccess                          |
| <font color="green">異常</font>          | onError                   | onSuccess                          |
| <font color="green">API途中のエラー</font>| onError                   | onError                            |
  
## まとめ
ステータスコードの正常異常でレスポンスパース変えたいけど、ResponseBodyで受けるのは嫌なときは`Response<T>`をつかおう！  
ホントは`Response<T, T>`みたいな感じにして1つ目は`isSuccessfull()`なときのレスポンスモデルクラスで、2つ目は`false`の時のモデルクラスみたいにしてあげたい。  
  
そう思ってる人居ない説。  

### 参考
[square/retfoit retrofit/Response.java at master](https://github.com/square/retrofit/blob/master/retrofit/src/main/java/retrofit2/Response.java)
