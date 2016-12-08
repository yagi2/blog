---
title: Androidアプリ開発のちょっとした小ネタ
date: 2016-12-09 02:41 JST
tags: やぎすけAdventCalendar2016,Android
---

こんにちは、やぎにいです。  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の9日目です。  
12月ももう1桁日がおわってしまいますね。年の瀬という感じがだんだんしてくるのでしょう。  
あ、その前にクリスマスか。  
  
昨日は僕が[Icepickを使ってActivityの破棄に備える](https://blog.yagi2.com/2016/12/08/how-to-use-icepick.html)を書きました。  
  
本日は僕が今年1年Androidアプリを開発をする上で溜まった秘伝のタレみたいなTipsを紹介したいと思います。  
僕も自分で書いたり、インターネットの波に乗って頂いたものもあるのでタレをMixして再配布みたいな感じです。  
<br><br>
## 実機のUSB接続をやめる
皆さんはAndroidアプリを開発するときにエミュレータで開発しますか？実機で開発しますか？  
両方使うのが大半だと思いますが、僕はよっぽどのケースではないと実機を主に使います（マシンもそこまでいいのではないので）。
    
その時USBケーブルを使ってAndroidの端末をマシンに接続すると思うのですが、よく`ADB`から認識されなくなることがありませんか？  
あと、デバッグしてるんだけどトイレに行きたくてケーブルを外すのを迷うケース。  
そんな時のためのTipsです。  
  
簡単に言うと開発マシンとデバッグに使っている実機のAndroid端末を同一ネットワークに置いてIPアドレスを指定して接続します。  
手順は以下のとおりです。

* まずUSBケーブルを使用してマシンと接続し、ADBから端末が見えてることを確認します
* 続いて`$ adb tcpip 5555`と入力し実行します。 ポート番号は恐らくこれ以外でも大丈夫です。
* そしたら次に`$ adb connect [デバイスのIPアドレス]:5555` と打ちます。
  
以上です。これであとはUSBケーブルを抜いてもネットワークを利用してADBに接続されています。  
デバッグ中にトイレに行きたい！でも1回ケーブル抜くと再び認識させるのに手間取るんだよな……という悩みからもおさらばです！
  
ココらへんの操作はAndroid Studioとかを使っていればプラグインが存在するのでそれを使うのも手です。  
[pedrovgs/AndroidWiFiADB](https://github.com/pedrovgs/AndroidWiFiADB)とかがあります。  
<br><br>
## Android Wearの実機でデバッグする時の話
Android Wearアプリを作る時、実機デバッグをしたくてもADBに認識させることがなかなか難しかったりします。  
接続する手順をメモがてら置いておきます。  

* まずAndroid Wearの`設定-端末情報`のビルド番号を7回タップしましょう（Android端末と同じですね）
* 開発者向けオプションをタップして有効にしましょう
* Wear端末の開発者向けオプションの中にある`Bluetooth経由でデバッグ`を有効にしてください。
* Android端末のAndroid Wearアプリの設定で`Bluetooth経由のデバッグ`を有効にする
* 「ホスト：未接続」「ターゲット：接続済み」の表示になっていればOK
* ADBにAndroid端末を接続してください（USBでもネットワーク経由でも大丈夫です）
* ターミナルで`$ adb forward tcp:4444 localabstract:/adb-hub`と`$ adb connect localhost:4444`を実行します。（これもポート番号は任意で大丈夫なはずです）
  
以上の手順でADBでもAndroid Wearの端末が認識されると思います。  
<br><br>
## ADBをターミナルで使う
みなさんはAndroidアプリをAndroid Studioで作成している時にデバッグ実行はAndroid StudioのRunを使いますか？  
僕は結構ターミナルから`./gradlew`を使ってビルドをしたりします。理由としては`C-c`で即ビルドを取りやめることができるからです。Android Studioでのビルドは停止を押しても実際に止まるまで結構な時間がかかってしまうことがあります。
    
そこでシェル芸とは行かないもののターミナル上で色々便利に使う物をご紹介します。  
殆どが[Android開発を爆速にする10のコマンドラインスクリプト - クックパッド開発者ブログ](http://techlife.cookpad.com/entry/2014/12/17/182050)ここを参考にしています。  
が、僕自身使っているシェルが`fish shell`なのでそれ用に書き換えていたりします。  
今回はそれを書き記しておきます。（大部分が`peco`を必要としています）  
<br>
### ADBをリスタートする
端末の認識等々で調子が悪くなったりしてADB再起動したい時

```
function restart-adb
  adb kill-server; adb start-server
end
```
<br>
### 端末を複数接続しているときにADBの実行対象を選ぶ
端末を複数接続しているとデバイスIDを渡さないとADBは怒ってきます。それをpecoで指定してあげましょう

```
function adpeco
  adb devices | awk 'NR>1 {print $1}' | peco | xargs -I deviceID echo "adb -s deviceID $argv" | pbcopy
end
```

最後が`pbcopy`になっているのは僕もスマートでないのでどうにかしたいのですが、`xargs -I deviceID adb -s deviceID $argv`ではコマンドが実行されないために応急処置的に`pbcopy`にして`Cmd+v`で実行できるようになっています。  
`fish shell`に強い方がいらっしゃいましたら改善策を教えていただけると幸いです。  
<br>
### ADBに接続しているAndroid端末の中のアプリをアンインストールする
いちいち設定を開いたりしてアンインストールのが面倒なのでターミナルから削除します。  
これは接続されている端末が1つの前提なので複数あると多分エラーを吐きます（未確認）

```
function uninstallapp
  adb shell pm list package | sed -e s/package:// | peco | xargs adb uninstall
end
```

<br>
### 逆にインストールする
`./gradlew assembledebug`とかでビルドしたapkファイルをpecoで選択してAndroid端末にインストールしましょう。

```
function installapp
  find ./ -name "*.apk" | peco | xargs adb install -r
end
```

複数の`flavor`で生成したapkもfindコマンドを使っているのでpecoで選択できます。
<br>
### Androidのスクリーンショットを撮って開く
現時点のスクショを撮って確認、もしくはそれをプロジェクトディレクトリに含めてREADMEに追加したりissueに貼ったりとかしたりすると思いますが、端末で撮ればマシンに転送がめんどくさいのでADBでやりましょう。

```
function screenshot
  screenshot2 /Users/aoyagi/Pictures/Andoid/screenshot.png; open /Users/aoyagi/Pictures/Andoid/screenshot.png
end
```

実行してあげるとスクショがプレビューで開くと思います。
<br>
### ターミナルでLogcatを見やすく表示する。
これにはJake Wharton氏作のツールを使いましょう。  
このAdvent Calendar内で何回Jake Wharton氏のGitHubのリンクを書くんでしょう。  
[JakeWharton/pidcat](https://github.com/JakeWharton/pidcat)  
  
これをインストールし

```
function pidpeco
  adb shell pm list package | sed -e s/package:// | peco | xargs echo "pidcat" | pbcopy
end
```

を僕は使っています。  
これも`pbcopy`を使用していますが、理由は上と同じです。  
`cmd+v`の1手間が増えるだけなのでなんとか我慢していますがそのうち修正したいですね。  
<br><br>
## おわりに
今日は僕がAndroidアプリ開発をする上でどんどん蓄積していったTipsを思い出せる範囲で書き記しました。  
今後もあっこれはいけるぞと思ったら随時ご紹介したいとおもいます。
  
以上、やぎにいでした！