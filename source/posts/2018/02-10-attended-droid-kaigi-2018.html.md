---
title: DroidKaigi 2018に参加してきた
date: 2018-02-10 23:37 JST
tags: Android, DroidKaigi
---

## DroidKaigiとは
DroidKaigiとはAndroidエンジニアたちが集まって各々の知見をセッションで発表したり、それを聞いたり交流するカンファレンスです。Androidエンジニアのおっきいおまつりみたいな感じで大丈夫です（ざっくり）  
公式サイトは[ここ](https://droidkaigi.jp/2018/)にあります。 
  
去年は参加しなかったのですが、今年は会社より経費を出して頂き参加しました。  
  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">アイコンを変えるタイミングを誤るとこうなるの例 <a href="https://t.co/8yHU1aBruA">pic.twitter.com/8yHU1aBruA</a></p>&mdash; やぎにいちゃん (@yaginier) <a href="https://twitter.com/yaginier/status/961399373887291392?ref_src=twsrc%5Etfw">2018年2月8日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
## DroidKaigiアプリ  
DroidKaigiでは通年、公式アプリがGitHub上のリポジトリに上げられ誰でもPRを出すことができます。  

[DroidKaigi/conference-app-2018: The Official Conference App for DroidKaigi 2018 Tokyo](https://github.com/DroidKaigi/conference-app-2018)  
  
毎年その時点でのナウいあれこれを使って攻めの作りになっていたり、設計もしっかりしているのでかなり参考になるのでリポジトリをcloneして軽く見てみるだけでかなりの知識を得ることができます。  
  
今年はガンガンContributeしていこうと思っていたのですが、思いの外業務が忙しくリポジトリ公開初日にtypoの修正のPR提出とバグのIssue立てを1件行いました。  
  
[fix typo of not prepared exception. by yagi2 · Pull Request #76 · DroidKaigi/conference-app-2018](https://github.com/DroidKaigi/conference-app-2018/pull/76)  
  
[[Assigned] StatusBar color on Contributor screen is different from other screens · Issue #212 · DroidKaigi/conference-app-2018](https://github.com/DroidKaigi/conference-app-2018/issues/212)  
  
このくらいしかできませんでしたが、アプリ内のコントリビューター一覧にいたり、DroidKaigi1日目のオープニングトークのスライドに自分が居て感動しました。来年はもっとしたい……。  
  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="und" dir="ltr"><a href="https://t.co/bFIZCWAdZw">pic.twitter.com/bFIZCWAdZw</a></p>&mdash; やぎにいちゃん (@yaginier) <a href="https://twitter.com/yaginier/status/961437810933710848?ref_src=twsrc%5Etfw">2018年2月8日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
## セッション  
セッションは全部で14セッション聴講しました。どれも業務に適用できるかなり良い知見を得ることができました。  
特に自分の中に強く残ってるセッションとして2つ軽く挙げさせていただきます。  
  
### watanaveさんによる「Anko試食会」  
[Kotlin/anko: Pleasant Android application development](https://github.com/Kotlin/anko)の話で、これはAndroidアプリをつくる時に便利にしてくれるライブラリです。  
特に今回はAnko Layoutについてのセッションでした。  
  
DSLでコードとしてレイアウトを書くという内容でそもそもDSLが凄く読みやすくXMLでレイアウトを記述するよりかなりいいのでは？という気持ちです。  
コンストラクタで状態を受け取ったりしてランタイムに色々描画できるのはかなり可能性として良いなという印象です。が、プレビュー面でかなりまだつらい部分があったり逆に冗長になってしまう場合もあったりするのでAnkoとXMLによるレイアウト記述は適材適所でやっていくとかなり使いやすそうだなと思いました。  
  
正直今すぐにでも業務にAnko導入したい勢いで良かったです。  
  
セッション後半はDSLについてが主で、Kotlinイン・アクションにもDSLの章があるのですが今回はAnkoのDSLと同じような働きをするDSLをつくるというトピックでKotlinのDSLの仕組みをわかりやすく説明していただきました。  
  
DSL、出てきた当時はかなり自分にとっては難解でかなり悩んだのですが「DSLではそのLambdaのスコープでのthisが何なのかを意識していく」という1点で腑に落ちた感じがしてなるほど！！！という気持ちでいっぱいです。  
Kotlinイン・アクションと併せて更にDSLについて理解していきたい。  
  
### shiraji‏さんによる「How to Kontribute」  
もともとshirajiさんはこの「How to Kontribute」のセッションを昨年のKotlinConfで発表されていて、それよりさらに前に[How to Kontribute (for Japanese) - Shiraji's Blog](http://shiraji.github.io/blog/2016/07/14/how-to-kontribute/)という記事を読んでKontributeに関して非常に興味を持っていました。  
というのも、当時社内でKotlinを使うぞ！と使い始めたところで同じ会社で働いていた先輩Androidエンジニアもこの記事でKontributeをしていたので「よしやってみるぞ」という気持ちで環境を記事を読みながら整えてYouTrackを眺めていました。（結局PRは出せていない）  
  
そこからKotlinConfでのセッションアーカイブを数回見て、Kontributeへの道のりを知識として得たものの、どういうところから手を付けていこうかなという感じで実際にKontributeするまでには至って居ませんでした。  
<iframe width="560" height="315" src="https://www.youtube.com/embed/-y2vW94mBDE" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>  
（shirajiさんによるKotlinConfでのセッション）  
  
今回のDroidKaigiではどういうところから手を付けるとやりやすいかというものが細かく説明されており、まさに自分の中でのKontributeまでの障壁が全て壊れたことになりました。  
  
アフターバーティーでもshirajiさんとお話させて頂き「コントリしてみようよ！」という流れで「ええい、こういうやっていきは勢いよ。できなくてgive upしたところで首を刈られるわけではあるまい！」という気持ちでYouTrackで「やりまーす」と軽く手を上げました。  
  
セッションを聞くとやっぱり自分のやっていき度が上がっていくので非常に良いです。  
  
[shirajiさんのツイート: "Selfies with future kontributors!!! #droidkaigi_room6 #DroidKaigi… "](https://twitter.com/shiraj_i/status/961463046848704512/photo/1?ref_src=twsrc%5Etfw&ref_url=https%3A%2F%2Ftwitter.com%2Fshiraj_i)  
（上手くはれなかったからリンクだけど、セルフィーやるのかな？と思って最前に座っていた図です）  
  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr"><a href="https://t.co/R870LFiwDQ">https://t.co/R870LFiwDQ</a><br>↓<a href="https://t.co/YKxTYOFwyy">https://t.co/YKxTYOFwyy</a><br>↓<br>パーティーでコントリしてくれたら嬉しい！と話す<br>↓<a href="https://t.co/QHxRnuAREL">https://t.co/QHxRnuAREL</a><br>↓<a href="https://t.co/c6iSj16zUT">https://t.co/c6iSj16zUT</a><br>↓<a href="https://t.co/tHkowNxVkZ">https://t.co/tHkowNxVkZ</a><a href="https://twitter.com/yaginier?ref_src=twsrc%5Etfw">@yaginier</a> さんのやっていき力半端ない。スゴい嬉しいけど、明日もDroidKaigiだよ！無理しないで！</p>&mdash; shiraji (@shiraj_i) <a href="https://twitter.com/shiraj_i/status/961637702847275008?ref_src=twsrc%5Etfw">2018年2月8日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
[Provide samples for all standard library functions : KT-20357](https://youtrack.jetbrains.com/issue/KT-20357#comment=27-2701625)  
※実際にやるぞいと言ったTask  
  
実際にはホテルの回線だとタイムアウトしてだめだったのでスマホのテザリングでギガを減らしました。  
京都に帰ってからじっくり取り組もうと思います。  
  
## さいごに
1,000人規模で本当にスタッフの皆様方お疲れ様でした。本当にありがとうございます。  
プレパーティーやセッション間の休憩時間に様々な方とお話してAndroidについて、プロダクトについてを語ることができて大変有意義な時間を過ごすことができました。  
  
来年はCfPを出すところまで行きたいです。頑張ろう。  
  

