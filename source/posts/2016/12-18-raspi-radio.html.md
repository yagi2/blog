---
title: RaspberryPiを使って、家に超A&G+を垂れ流す環境を作った
date: 2016-12-18 17:47 JST
tags: やぎすけAdventCalendar2016,RaspberryPi
---

こんにちは、やぎにいです。  
  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の18日目です。  
知ってました？今年の日曜日って今日を含めあと2回しか来ないんですよ……。

昨日は僕が[Mac上でMiddlemanを使ってCentOSにホストするとNFD問題にぶち当たる](https://blog.yagi2.com/2016/12/17/wtf-nfd.html)を書きました。  
今絶賛CIでデプロイを試みてるのですが、うまく行ってません。ホントは今日のネタにするつもりだったのに。  
  
今日はRaspberryPiでラジオを垂れ流すお話です
<br><br>
## はじめに
僕はアニメが好きで、その流れで自然と（？）声優が好きになっていて今ではアニメよりも声優を追いかけるほうが多くなってしまいました（今年のソロデビューラッシュはそれなりに嬉しい）。  
声優オタクをしていると、自然と文化放送の[超!A&G](http://www.agqr.jp/)という声優ラジオを主に配信しているインターネットラジオにたどり着きます。  
  

僕は日常生活で何か喋り声が聞こえてないと集中できない、落ち着かないという特殊な癖を持っていまして、よくニコニコ動画の何かしらやYouTubeの何かしらを流しているのですが、今回は家であんまり働いていなかったRaspberry Piを使ってこいつをラジオにしてやりました。
  
使っているのは懐かしの`Raspberry Pi 1 Model B`になります。すんげー最低スペックなので新しいのを持ってれば十分だと思います。  
OSは`Raspbian 7.5`でした（一切アップデートとかしてない気がする）
<br><br>
## 準備する
必要なものは以下です

* 本体
* rtmpdump
* mplayer
* 外部に出力するスピーカー

本体はおいといて、まずは`rtmpdump`と`mplayer`をインストールしましょう。両方`apt-get`で入手できるはずです。

```
$ sudo apt-get update
$ sudo apt-get install rtmpdump
$ sudo apt-get install mplayer
```

`rtmpdump`とはRTMPストリームをサポートしたツールで`rtmp://`とかで始まってるやつをよしなに処理してくれます。  
`mplayer`はオープンソースなメディアプレーヤーになってます。  
つまり超A&G+のストリームを処理してそれを`mplayer`で再生しようという流れです。  
  
次に予め、アナログ出力のスピーカーから音が出るようにしてあげましょう。（最初でなくて焦った）  

```
$ sudo amixer cset numid=3 1
$ speaker-test -t sine -f 600
```

`amixer`でオーディオ出力をアナログに固定してあげて`speaker-test`で鳴るかテストしてます。  
鳴らなかったら環境によって違うかもなので「ラズパイのモデル名 スピーカー 音出ない」とかでぐぐってみてください。   
  
HDMIでももちろん音は出力できるので、そのケースの際も適宜ググってください。今回は僕がアナログピンのスピーカーを使っているためです。  
  
以上で準備は完了しました。
<br><br>
## 超A&G+を鳴らす
これで再生する準備が出来ました。  
じゃあ次に超A&G+を鳴らしましょう。  
必要なものは`rtmp://`で始まるストリームです。  
「超A&G+ rmpt」とかで調べると出てきますが、使えるうちの1つは`rtmp://fms-base1.mitene.ad.jp/agqr/aandg22`というものです（現時点）  
そのうち閉じられたら適宜しらべましょう……。  
これを`rtmpdump`に渡して、更に`mplayer`に流してみましょう。  

```
$ rtmpdump -r "rtmp://fms-base1.mitene.ad.jp/agqr/aandg22" --live | mplayer - > /dev/null 2>&1 &
```

こんなコマンドでやってみましょう。すんごい勢いでストリーム情報の出力が出るので僕は`/dev/null`に捨ててます。  
どうでしょう、超A&G+の音声がスピーカーから流れてきましたでしょうか。  
ちなみに、HDMI接続したディスプレイや、sshしているターミナルで映像が流れてたりします。（ラジオとして使っているのでほぼ見ることはありません）  
  
これで超A&G+が24時間垂れ流しになるラジオの完成です！ 個人的にQoLが爆上がりしました。  
<br><br>
## これから
実はこのコマンド、何故か不定期に落ちます。（ホントわからない）  
なので、ちょくちょくsshをしてコマンドを叩いて起こすということをしているのすが、それをスマフォから操作できるようにしてあげたいですね。  
ついでにプロセスの再始動だけじゃなくて、再生停止、音量操作などWebブラウザからのコントローラーを作ってあげたいです。  
あとは超A&G+以外もサポートしたい……。  
  
なお、聞きたい番組は実は全部別のVPSで録画録音してクラウドに保存しているので安心なのです（使用容量しらべてみたら現時点で200GB弱あった、DropboxProになった要因はこれ）  
  
あと最近個人的なオススメな番組は伊藤美来さんの「まるっとまとめ！」ともしこえ（長いので省略）の「高野麻里佳 あなたの隣家のまりんか」が強いです。  
他にも好きなのはいっぱいありますが、あえてあんまり話題にならない番組でおすすめをあげました。  
  
みなさんも、RasPiを使ってQoLをちょっとずつ上げていきましょう！
以上、やぎにいでした！