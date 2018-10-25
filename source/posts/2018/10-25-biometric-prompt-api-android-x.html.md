---
title: AndroidXにおけるBiometricPromptAPIについて
date: 2018-10-25 14:28 JST
tags: Android
---
  
## 今回の主題  
私自身、もともとFingerprintManagerを使用し指紋認証を実装していて、Android PよりBiometricPromptに乗り換えましたがそこで1つの問題が発生しました。  
その問題を強引に（スマートではなく）解決し運用をしていましたが、AndroidXのBiometricPromptを使ってみたところ、問題が解決されており、更に使い方も変わっていました。  
使い方に関しての変更も探した限りでは解説などが見つからなかったので備忘録を兼ねて書かせていただきたいと思います。  
  
## BiometricPromptとは  
Android端末における生体認証はAndroid P以前では[FingerprintManager](https://developer.android.com/reference/android/hardware/fingerprint/FingerprintManager)を使用して指紋認証を行なうことで実現していました。  
そのFingerpringManagerはAndroid PよりDeprecatedになり新しく登場したのがBiometricPromptです。  
2018年6月21日にはAndroid Developers Blogに[Android Developers Blog: Better Biometrics in Android P](https://android-developers.googleblog.com/2018/06/better-biometrics-in-android-p.html)という記事も投稿されました。  
これに従ってFingerprintManagerからBiometricPromptへ乗り換えることによって、もっと生体認証を使いやすく、また指紋以外での認証も可能になるというものでした。  
  
## AndroidX以前のBiometricPrompt  
[BiometricPrompt  |  Android Developers](https://developer.android.com/reference/android/hardware/biometrics/BiometricPrompt)  
パッケージとしては`android.hardware.biometrics`に存在するものでした。  
使い方も前述したDevelopers Blogに乗っている通り  
  
```Kotlin
BiometricPrompt.Builder(this)
    .setTitle("title")
    .setSubtitle("sub title")
    .setDescription("description")
    .setNegativeButton("cancel", executor, listener)
    .build()
    .authenticate(cryptoObject, cancellationSignal, executor, callback)
```
  
という記述で生体認証のダイアログを表示し、認証を行うことができました（引数に取るクラスについての詳細はAndroid Developersをごらんください。）  
  
ここで問題になってくるのはBiometricPrompt自体はAndroid P以上で触るものであって、Android O以下では<biometric>Managerを触る必要があります。  
つまり、`VERSION.SDK_INT >= Build.VERSION_CODES.P`でBiometricPromptを使うか、FingerprintManagerを使うかを場合分けしなければいけないということです。  
そこでその差異を吸収するのがCompatLibraryになってきます（Androidアプリ開発者であればCompatは慣れ親しんだものだと思います。）  
  
前述のAndroid Developers Blogの表を引用させていただくと  
<img src="/images/2018/10-25-biometric-prompt-api-android-x-001.png" width="100%">  
という表があります。  
この表から分かる通りアプリケーションからはSupport Libraryである、BiometricPrompt Compat Libraryを触って、そこがよしなにバージョンに寄ってしてくれると信じていました。  
  
信じていました、が、BiometricPrompt Compat Libraryはどこにも見つからずどこだどこだと彷徨っていました。  
  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="en" dir="ltr">Hey <a href="https://twitter.com/Google?ref_src=twsrc%5Etfw">@google</a> <a href="https://twitter.com/AndroidDev?ref_src=twsrc%5Etfw">@AndroidDev</a> <a href="https://twitter.com/ianhlake?ref_src=twsrc%5Etfw">@ianhlake</a>! What about that BiometricPrompt compat library mentioned in <a href="https://t.co/BL8auKrCz0">https://t.co/BL8auKrCz0</a> ? Any ETA? I would like to use it :)</p>&mdash; Marc Reichelt (@mreichelt) <a href="https://twitter.com/mreichelt/status/1029391180516257794?ref_src=twsrc%5Etfw">2018年8月14日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>  
他にもそういう方が居た。  
  
中国人のfythonさんが出しているライブラリで[fython/BiometricPromptCompat: [DEPRECATED] A Thrid-party BiometricPrompt compat library.](https://github.com/fython/BiometricPromptCompat)というものがあり、実装を見るといい感じに中でバージョン分けをするみたいな「求めていたBiometricPrompt Compat Library！」がありました。  
  
このような感じで、BiometricPromptが出てきたのは良いが、Compatがないので結局今までのFingerprintManagerに追加してP以上であればBiometricPrompt、未満ならというコード量が増える形になっていました。  
  
## AndroidXでのBiometricPrompt  
上記OSSの個人ライブラリのREADMEでも既に[DEPRECATED]とありますが、AndroidXになってBiometricPromptが大きく変わり上記の問題も解決されていました。  
[Maven Repository: androidx.biometric » biometric](https://mvnrepository.com/artifact/androidx.biometric/biometric)まだバージョンは1.0.0のalpha02が現時点では最新です。  
  
[BiometricPrompt  |  Android Developers](https://developer.android.com/reference/androidx/biometrics/BiometricPrompt)  
  
このAndroid Developersのドキュメントを見ても分かる通り、BiometricPromptに直接Builderが存在しなくなったりと以前の書き方のままでは動かない形に変更されていました。  
まず表示させる完成形のコードをそのまま貼り付けます。  
  
```Kotlin
val promptInfo = BiometricPrompt.PromptInfo.Builder()
    .setTitle("title")
    .setSubtitle("sub title")
    .setDescription("description")
    .setNegativeButtonText("cancel")
    .build()

BiometricPrompt(this, mainExecutor, object : BiometricPrompt.AuthenticationCallback() {
    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
        // 認証成功時のハンドル
    }    
    
    override fun onAuthenticationFailed() {
        // 認証失敗時のハンドル
    }
    
    override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
        // 認証エラー時のハンドル
    }
}).authenticate(promptInfo)
```  
  
（そのままActivityクラスに貼り付けると動くと思います）  
  
変更点としては、タイトルなどの情報をコレまでは直接BiometricPromptのBuilderに対してsetTitleなどを行ってきましたが、AndroidXからはそれらの情報類は[BiometricPrompt.PromptInfo](https://developer.android.com/reference/androidx/biometrics/BiometricPrompt.PromptInfo)というクラスができたので、そちらにまとめてインスタンスを作る形になっているようです。  
  
## まとめ  
`androidx.biometrics.BiometricPrompt`の実装をちょっと覗いてみましたが、まさに`if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) { ... } else { ... }`という形でバージョンの場合分けでどれを使うかという実装になっていました。  
最初に僕たちが求めていたBiometricPrompt Compat LibraryのそれがやっとAndroidXになって登場したという感じだと思います。  
  
ただ、まだAndroidXに移行しきっていないケースが多いことやAndroidXのBiometricがアルファ版であることから、まだしばらくはFingerprintManagerと以前のBiometricPromptを自分たちで場合分けしてるケースが続くのかなと思います。  
AndroidXに移行しきっている場合だと入れてみても良さそうです。  