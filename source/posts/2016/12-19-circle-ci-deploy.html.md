---
title: CircleCIを使って、Middlemanで作ったものをrsyncでデプロイする
date: 2016-12-19 13:20 JST
tags: やぎすけAdventCalendar2016,middleman
---

こんにちは、やぎにいです。
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の19日目です。  
私事ですが、今朝Nexus5Xがbootloopに陥って死にました。  
docomoで買ってたので、持ち込んで修理見積もり出しました。見積もり結果は年明けらしいです。つらいですね。  
今年もガジェット運はダメダメでした。  

昨日は僕が[RaspberryPiを使って、家に超A&G+を垂れ流す環境を作った](https://blog.yagi2.com/2016/12/18/raspi-radio.html)を書きました。  
  
今日はこのブログを自動でデプロイするお話です。  
<br><br>
## はじめに
僕はこのアドベントカレンダーで17日目に[Mac上でMiddlemanを使ってCentOSにホストするとNFD問題にぶち当たる](https://blog.yagi2.com/2016/12/17/wtf-nfd.html)という記事を書きました。  
結果はMacでビルドしたのをそのままCentOSでホストすると死ぬ。ということだったので、じゃあMacでビルドをやめようという発想に至りました。  
  
今までの環境だと、Macで記事を書く→Mac上のMiddlemanでビルド→CentOSへMacからrsyncという形を取っていました。  
が、このブログは[GitHub - yagi2/blog](https://github.com/yagi2/blog)のリポジトリで管理している、つまり書く度にリモートのリポジトリにpushしているのでせっかくだしCIで自動デプロイしようと思いました。  
  
使用するのはCircleCIです。理由は特にないです。  
最初はうなすけが書いていた[うなすけとあれこれ - CircleCIでmiddlemanのdeployを自動化した](https://blog.unasuke.com/2015/middleman-deploy-from-circle-ci/)を参考にしようと思ったのでCircleCIを登録だけしていました。  
上記事では`middleman-deploy`を使用していたのですが、不便なのとMaintenanceがあまりされてないという理由でやめました。  
不便というのは、例えばrsyncはssh通したときに鍵を指定したく鳴る時があり、rsyncのコマンドでは`$ rsync -e "ssh -i /path/to/key"`とかで書けるわけですが、`middleman-deploy`では鍵の指定コンフィグが見つからなかったので最初は`deploy.flags = '-rltgoDvzO --no-p --del -e "ssh -p PORT_NUM -i /path/to/key'`とか指定してました。こんなものflagではない。  
  
今回は純粋に`circle.yml`に書いてあげました。  
<br><br>
## 手順

### circle.ymlを用意する  

今回はテストとか考えずとりあえずデプロイをしたかったので以下のとおりです。  

```yml
deployment:
  push_to_server:
    branch: master
    commands:
      - rsync -rltgoDvzO --no-p --del -e "ssh -p $PORT_NUMBER" build $USER_NAME@$HOST_NAME:$DOCUMENT_ROOT
```

### CircleCIのWeb上から環境変数を設定する  

上記の設定では

* PORT_NUMBER（rsyncで使うsshポート番号）  
* USER_NAME（sshでのログインユーザ名）  
* HOST_NAME（デプロイ先のホスト名）  
* DOCUMENT_ROOT（デプロイするドキュメントルートのパス）  

の4つを変数としているので、これらをCircleCIのWebページから設定します。  
circle.ymlでも設定できるのですが、このブログはオープンソースなので外部に漏れるとまずいのでこの手順を踏んでいます。特に公開してないという場合は直書きしてあげてもいいかもです。  
projectのBUILD SETTINGSにEnvironment Variablesという項目が存在するので、ここに上記の4つを設定しました。    
  
なんとこの2手順で完了してしまいました。  
あとはmasterブランチにコミットしてpushするだけです。  
非常に便利ですね。  
<br><br>
## これから
今のところNo TestなのでなんかこれCircleCIでいいのか……？という感じがしています。  
テストを書くか、なんか他の自動でデプロイするのを目的としたツールを使うべきなのかなとか早くも思いはじめています。  
  
ちなみにうなすけが、このアドベントカレンダーの記事として14日目に[うなすけとあれこれ - このblogのCIをCircle CIからwerckerに変更しました](https://blog.unasuke.com/2016/change-blog-ci-service-from-circle-ci-to-wercker/)という記事を出しています。  
このCircleCIでの自動デプロイに苦戦している時に1歩未来に行かれました。  
が、僕は今のところCircleCIでデプロイされるまでに1分30秒くらいなのであまりこれに関しては困っていないです。  
今後もいろいろ模索していきたいと思います。  
  
以上、やぎにいでした！