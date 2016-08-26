---
title: Middlemanを使ってさくっとブログを立ち上げるぞい！
date: 2016-08-27 00:08 JST
tags: 備忘録, middleman
---

題名のまま！さあ！カップ麺にお湯いれて！スタート！！  
※インストール時間とかは考慮してないですし、僕も終わるまでに2時間位かかりました。

## 環境
* ruby 2.2.5p319 (2016-04-26 revision 54774) [x86_64-darwin15]
* Middleman 3.2.2
* Mac OS X El Capitan 10.11.6 15G31

## 前準備
Rubyに関してはrbenvを使用しています。  
そこらへんまで解説しちゃうと記事1本分になるので Mac rbenv インストール とかでググってくだしあ。
大体

``` bash
$ brew install rbenv ruby-build
$ rbenv install 2.2.5
$ rbenv global 2.2.5
```

をしておけば大丈夫だとおもう。（僕は大丈夫だった）

## Middlemanのインストール
これにはgemを使います

``` bash
$ gem install middleman
$ middleman version
Middleman 4.1.10
```

とかなれば大丈夫です。  
バージョンがうえで上げた環境と違うのはbundleを利用して、実際使っているMiddlemanは上記のバージョンになるためです（30行後くらいに確認しましょう）  

## Middlemanプロジェクトの作成
今回はブログのテンプレートに[5t111111/middleman-blog-drops-template](https://github.com/5t111111/middleman-blog-drops-template)をお借りしています。  
これを使う前提で今回は進めていきます（他のテンプレートもだいたいREADMEに手順載ってるから似たようなモノだよ）  
  

``` bash
$ middleman init my_project --template=5t111111/middleman-blog-drops-template
$ cd my_project
```

こうするといろいろファイルがあるmy_projectという名前のディレクトリが出来たかと思います。  
これが今回使っていくプロジェクトのディレクトリです。  

``` bash
$ bundle install --path vendor/bundle
$ npm install
```

としてGemfileに書いてあるやつらやらnodeのモジュールをインストールしてきましょう。  
bundle installに引数をつけるかつけないかは自由です（僕はつけてるもののgitのリポジトリにはあげていません）  

ここまで来ると9割完成です！
試しに

``` bash
$ bundle exec middleman
```

とコマンドを打ち込み、localhost:4567にアクセスしてみましょう！  
もしちゃんと成功していればおしゃんてぃーなテンプレートのブログが表示されているはずです！  
  
この段階でMiddlemanのバージョンを確認すると

``` bash
$ bundle exec middleman version
Middleman 3.2.2
```

となると思います。（確認終了）

## 俺好みのものに設定
このままだとブログタイトル等々がそのままなので設定しましょう。  
ブログタイトル等々の設定は data/settings.ymlにあります  
僕のファイルは参考までに[こう](https://github.com/yagi2/diary/blob/master/data/settings.yml)なってます。  

``` yml
site_url: 'http://diary.yagi2.com'
site_title: 'やぎ日記'
site_description: 'やぎにいのどうでもいい日記'
site_author: 'やぎにい'
site_author_profile: 'ただのしがない山羊'
site_author_image: 'profile.png'
reverse_title: true
social_links:
  twitter: 'https://twitter.com/magical_reisen'
  github: 'https://github.com/yagi2'
# google_analytics_account: 'XX-12345678-9'
```

そいで忘れちゃいけないので次の設定  
config.rbを開いてあげて5行目あたりの

``` ruby
Time.zone = 'Asia/Tokyo'
```

ここをUTCからAsia/Tokyoにしてあげましょう！  
僕はUTCのままbuildをしたら日付が変わってなかったせいで静的ファイルが吐かれないっていう罠に落ちました。（うなすけ先生に助けてもらいました）

## 記事の追加
記事の追加も簡単です！  

``` bash
$ bundle exec middleman article "title"
```

と1つコマンドを打ってあげるとsource/postsの中に自動でyear-month-day-title.html.mdっていうファイルが出来上がります！  
ココらへんのファイルの命名規則はconfig.rbで設定できるのでもし違うのがいい〜って方は設定してあげましょうね。  
もちろんtitleの部分は自分の好きなタイトルでいいですよ！  
※ただし日本語はつかわないほうがいいです 使ってもいけるっちゃいけますが、記事のURLにtitleを含まないようにしないといろいろ不都合です。
  
記事は出来上がったファイルにマークダウン形式で書いてあげましょう〜。  
title:の後には日本語つけてあげて大丈夫です！  
tags:はカンマ区切りで複数タグ付けしてあげることができます。

そしてらもっかい

``` bash
$ bundle exec middleman
```

を行ってちゃんと記事がかけているか確認しましょう！  
LiveLoadingが入ってるので、別のシェル窓やバックグラウンドにしてあげれば記事のファイルを更新すれば自動で読んでくれます！便利ね〜！  

## 静的ファイルを生成する
このままでは外部に公開できないので、外部に公開するための静的ファイルを生成してあげましょう。

``` bash
$ bundle exec middleman build
```

こんな感じでコマンドを打ってあげると build/ っていうディレクトリが出来ていろいろファイルが出来上がっていると思います。  
このbuild/内を自分のサーバなりAWSなりのDocumentRootにおいてあげれば無事航海完了です！  
ちなみにこのお借りしているテンプレートはHerokuやAWSやgithub.ioに簡単にデプロイできるようになってるみたいです  
config.rbやconfig.ruを見るとそこら辺いろいろありますね（僕は使ってないのでわからないです）  
  
そこらへんの詳しい話はテンプレート作者さんのQiita記事[また Middleman blog のテンプレートができたので宣伝にきました](http://qiita.com/5t111111/items/5e79a169b3162e2eab4c)や[リポジトリ](https://github.com/5t111111/middleman-blog-drops-template)のREADMEを読んでください。  
Qiita記事の方はちょっと古く、ブログの設定がconfig.rbにあった時の名残のままっぽいので注意です。（githubリポジトリのREADMEは正しいのでそっち参照するのがおすすめ）  

## おわり
以上でいい感じのブログを立ち上げることができたでしょうか？  
ちなみに僕がこの流れで立ち上げたのは日記サイトで[やぎ日記](http://diary.yagi2.com/)になります。  
このソース群は[yagi2/diary](https://github.com/yagi2/diary)に存在します。 参考にはならないと思いますが、この手順でやっているので詰まった場合は参考にしてみてください。  
  
昔はWordPressを入れて重いからチューニングすっぞ！とかTumblrをホストしたりとかしてましたが、なんだかんだ慣れちゃうとすぐ作れるもんなんですねぇ。
と、こんなところでちょうどカップ麺が完成したでしょうか。
    
お疲れ様でした。
  
（間違いとかがあったら[Twitter](https://twitter.com/amgical_reisen)宛に何卒よろしくお願いいたします。 初心者なもので……）