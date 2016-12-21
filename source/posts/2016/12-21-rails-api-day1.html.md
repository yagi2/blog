---
title: Ruby on RailsでつくるAPI（導入編）
date: 2016-12-21 10:19 JST
tags: やぎすけAdventCalendar2016,Rails
---

こんにちは、やぎにいです。
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の21日目です。  
今日を含め残り4日。頑張っていきましょう。  

昨日は僕が[今更理解するREST(ful)について](https://blog.yagi2.com/2016/12/20/what-is-restful.html)を書きました。  
  
今日からはRuby on Railsを使ってAPIをつくってみるという企画記事をやってみたいとおもいます。  
<br><br>
## はじめに
今回作るAPIは[THE IDOLM@STER](https://ja.wikipedia.org/wiki/THE_IDOLM@STER)（以下アイマス）APIになります。  
リポジトリは[GitHub - yagi2/imas_api_rails](https://github.com/yagi2/imas_api_rails)です。  
  
もともと実はFuelPHPを使って[GitHub - yagi2/imas_api](https://github.com/yagi2/imas_api)を作っていて、それを自宅のサーバで動かし身内のSlackでわいわい使っていた過去がありました。  
自宅のネットワークが一度リセットされたことをきっかけにこのAPIは停止し、長らくメンテ更新もしないままとなっていました（キャラデータもほとんど無かったけど）。  
  
ちょうどそこにRuby on Railsの5ではAPIモードというのが存在するという情報を得たのがつい先月の事。前々からRubyもといRailsには興味があったので、[うなすけ](https://twitter.com/yu_suke1994)の力を借りつつこのRails5のAPIモードで作ってみようと思ったのがきっかけです。  
  
機能的には簡単なものを考えていて、URIを指定してGETすると、アイマスのキャラなり楽曲なりのデータがjsonで返ってくるような物を考えています。  
目的はトレーニングと自分で使う目的ですし。  
<br><br>
## とりあえず作ってみる
Rails5はインストールされている前提でいきます。  

```shell
$ rails new imas_api_rails --api
```

この`--api`オプションを指定してあげるとAPIモードでの生成をしてくれるらしい。調べたところに寄るとAPIモードとそうでないときの差分はViewとかそういう部分のファイルらしい。  
  
とりあえずキャラクターの情報を得たいので`characters`というコントローラーを作ってみる  

``
$ rails g scaffold characters
```

これで`characters_controller.rb`とかが作成された。  
  
適当に`schema.rb`にキャラのスキーマを作ってみる

```ruby
create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "phonetic"
    t.string "production"
end
```

カラムは増やす予定だが、とりあえず名前とふりがなとプロダクション。 
そして`rails db:migrate` 
  
`db/seeds/characters.yml`にデータを書いてみる。  

```yml
characters:
  -
    name: '天海春香'
    phonetic: 'あまみはるか'
    production: '765'
  -
    name: '如月千早'
    phonetic: 'きさらぎちはや'
    production: '765'
...
```

そして`rails s`しlocalhostで`characters`を叩いてみると

![](2016/12-21-rails-api-day1-001.png)

おお、それっぽいjsonが返ってきた。  
  
なんかFuelPHPのときはもっと時間がかかった気がするが、railsだと概ね数時間で知識がなくともここまですることが出来た。  
データの充実度は考えないとしても、「アイマスのキャラの情報が/charactersを叩くとjsonで返ってくる」というAPIが出来てしまった。  
同じようにスキーマを設定し、データを書き/songsとかを作れば同様に楽曲のデータも同じように得られるAPIを作れるはず。  
  
これは……ハマってしまう。  
## 次は
では全部ではなく、クエリで名前の一部を投げるとそれに合致したものだけが返ってくるなどの絞込をしたい。  
でも、全部欲しいときは全部欲しいです。  
  
そんな実装ともっとrailsのコマンド（特にDBの挙動がイマイチ理解できていない）を深めていきたいと思います。  
  
うなすけは今のところ監督とテストおじさんとして貢献して頂いています。  
  
![](2016/12-21-rails-api-day1-002.png)