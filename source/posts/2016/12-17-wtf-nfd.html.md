---
title: Mac上でMiddlemanを使ってCentOSにホストするとNFD問題にぶち当たる
date: 2016-12-17 11:20 JST
tags: やぎすけAdventCalendar2016
---

こんにちは、やぎにいです。  
  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の17日目です。  
残すところあと1週間程となってしまいました。  

昨日はうなすけがが[やぎすけ Advent Calendar 16日目 testの追加](https://blog.unasuke.com/2016/yac-day16-fix-test/))を書いてくれました。  
  
今日はこのブログをジェネレートしているツール、Middlemanの話です。  
<br><br>
## 経緯
このブログサイトや、[yagi2.com](https://yagi2.com)は[Middleman](https://github.com/middleman/middleman)を使って作成しています。  
ブログを構築する手順についてはこのブログでも[Middlemanを使ってさくっとブログを立ち上げるぞい！](https://blog.yagi2.com/2016/08/27/how-to-build-blog-in-3-minutes.html)として書きました。  
  
実際僕はこの手順を踏み、Middlemanを使って私物のMacbookProにて記事を書き、そのままMBP上で`$ bundle exec middleman build`を行い、出来た成果物である`build/`を契約しているVP（CentOS）Sへアップして記事を更新していました。
すると、つい最近とある問題にぶち当たりました。  
  
問題に当たったのは今月1日に、このアドベントカレンダーの1日目の記事[やぎすけ Advent Calendar 2016](https://blog.yagi2.com/2016/12/01/introduction-yagi-suke-advent-calendar-2016.html)を書いてCentOSのVPS上にファイルをアップし、更新したときのことです。  
タグに「やぎすけAdventCalendar2016」というのをつけているわけですが、もちろん同じタグの記事をリスト閲覧できるように[Articles tagged 'やぎすけAdventCalendar2016'](https://blog.yagi2.com/tags/%E3%82%84%E3%81%8E%E3%81%99%E3%81%91adventcalendar2016.html)というページがMiddlemanではタグを解釈して自動的に作ってくれます。  
この時このページのHTMLファイルの名前は「やぎすけAdventCalendar2016.html」になり、書くファイルからリンクされる形になります。  
  
本来は。  
  
本来は、そうリンクされるはずなのですが、実際にはなぜか404エラーが出てしまうのです。  
しかし、手元のMacのlocalhostで動かすときは正常にリンクが働く……。  
しばらく頭を抱えることとなりました。  
<br><br>
## NFD問題

- やぎすけadventcalendar2016.html
- やぎすけadventcalendar2016.html

みなさんは上記2つの違いがわかるでしょうか。  
実は「ぎ」が違うのです（多分変換してるので実際には違いは消えている）。  
それぞれURLエンコードをした際に  

- %E3%82%84%E3%81%8E%E3%81%99%E3%81%91adventcalendar2016.html
- %E3%82%84%E3%81%8D%E3%82%99%E3%81%99%E3%81%91adventcalendar2016.html

になってしまったのです。  
判明したのは、VPSにsshで潜って原因を探っている時。  
「やぎすけAdventCalendar2016.html」というファイルが有るわけですから、`$ cat やぎ`まで入力しTabキーを推せば本来の補完昨日では`$ cat やぎすけAdventCalendar2016.html`と自動で保管されるはずです。  
しかし、保管されなかったのです。

- `$ cat や` Tab → 補完される  
- `$ cat やぎ` Tab → 補完されない

という状態でした。  
あれ……「ぎ」がおかしい……？  
何が何なのか全然わからない僕は頑張って調べ「NFD問題」というのが存在するということがわかりました。  
詳しくは[Wikipedia - Unicode正規化](https://ja.wikipedia.org/wiki/Unicode%E6%AD%A3%E8%A6%8F%E5%8C%96)にすべて書いてあるのですが、NFCとNDFの2つを取り出して説明すると。  

- NFC : 1文字は1文字 ぎ （きに濁点がある）だろうが、1文字なんだよこれは という形式
- NFD : 濁点半濁点などを本来の文字とは分離してエンコードする ぎ は き + ゛

これを採用している違いはファイルシステムにあり、OS X の HFS+は後者のNFDしています。  
つまり  
ファイルシステムの問題（くそ！）  
  
Macですべて完結させる場合はNFDで全然問題がないのですが、今回はそのMacで作ったファイルをCentOSでホストしているために、NFDになっているファイル名を解決できずに404エラーが出ていたということです。  
<br><br>
## こうした
実は今まで、`scp`コマンドを使用してVPS上にファイルを送っていたのですが、どうやら調べてみるとscpはNFC,NFDについて全くノータッチ。（だから問題が起きたわけですが）  
最新版の`rsync`であれば`--iconv`オプションが使えるようになるので処理できるようになります。なるほど。  
じゃあ`Homebrew`で入れよう  

```bash
$ brew tap homebrew/dupes
$ brew install rsync
$ rsync --version
rsync  version 3.1.2  protocol version 31
```
バージョンが3.1とかそれになっていればOK。  

```bash
$ rsync --iconv=UTF8-MAC,UTF-8 やぎにい.html example.com:/
```

とかしてあげると自動的に処理してくれる`--iconv=UTF8-MAC,UTF-8`が大事な部分です。  
<br><br>
## これから
まさか「やぎにい」でこの問題にぶち当たるとは思っていなかったのですが、実際ぶち当たるまでこの`Unicode正規化`についてまったく知りませんでした……。  
そしていまはまだ`$ bundle exec middleman build`したあとに`$ rsync ...`としてVPS上にファイルを上げているわけですが、いい加減やめたいです。  
  
今はとりあえずGitHubにブログのソースをPushしているわけですから、masterブランチにコミットが発生した場合にCIを使用して自動でビルド〜デプロイするようにしてあげたいと思います。  
それが出来たらまた、手順等このブログで紹介します。  
  
気をつけなはれや！  
  
以上、やぎにいでした。