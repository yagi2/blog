---
title: GitHubレポジトリにMavenのリポジトリを作成する
date: 2016-12-15 00:07 JST
tags: やぎすけAdventCalendar2016,Android,Java,Maven
---

こんにちは、やぎにいです。  
  
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の15日目です。  
驚くべきことにもう既に12月の半分となってしまいました。もう今年もおわってしまうんですね……。  
このアドベントカレンダーもあと10日ちょっと。頑張っていきましょう。  
      
昨日はうなすけがが[このblogのCIをCircle CIからwerckerに変更しました](https://blog.unasuke.com/2016/change-blog-ci-service-from-circle-ci-to-wercker/)を書いてくれました。  
  
今日はGitHubでMavenのリポジトリをpushするお話です。  
<br><br>  
## はじめに
僕はこのカレンダーの13日目の記事で、主に自分が使う用途として[RxBox](https://github.com/yagi2/RxBox)というjavaライブラリを作りました。  
これをいざ自分で使うというときに、いちいち.jarファイルをビルドで作成してそれを物理的にインポートするとなるとすごく面倒です。  
  
そこでAndroid StudioとかでAndroidのアプリを作っているときに`build.gradle`に`com.hoge.lib:x.y.z`と書けば使えるようになるのを思い出し、僕のこのライブラリもそれで使えるようにしてやろう！と意気込みました。  
  
インターネットでさて、これはどうやるのかと調べてみるとどうやら[bintray](https://bintray.com)というところに登録し、そこにpushしてあげたあと、jcenterに反映させるとすごく楽（しかもGradleのプラグインでよしなにできる）らしいということがわかりました。  
ならばやるしかありません。  
  
ところが、いくらアカウントを作っても、他の記事で紹介されているようなMavenのリポジトリを作成するボタンが見つかりません。稚拙な英語でサポートに連絡してみると「すまんな、個人とか個人アカウントでは作れないので所属団体でリポジトリを作ってくれ」という返答。  
な、なんだってー。  
  
数歩妥協して、`maven { url 'http://hoge.com/lib' }`を追加することにはなるが、GitHubで確かホストしているライブラリを過去に見たことがあるな……という記憶から色々調べてみました。
  
## Mavenリポジトリの作成
ほぼ全て[【Android】Libraryを作ってprivateなgithubリポジトリにpushして、チームのみんなでgradleに書くだけで使えるようにするまで - Qiita](http://qiita.com/kgmyshin/items/87f560172c31c2fbd899)こちらを参考にさせていただきました。本当にありがとうございます。  
ライブラリプロジェクトの`build.gradle`に

```gradle
def repo = new File(rootDir, "repository")

apply plugin: 'maven'

uploadArchives {
    repositories {
        mavenDeployer {
            repository url: "file://${repo.absolutePath}"
            pom.version = 'x.y.z'
            pom.groupId = 'com.yagi2'
            pom.artifactId = 'rxbox'
        }
    }
}
```

と記入し、`./gradlew assembleRelease uploadArchives`これでルートに`repository`というディレクトリが出来て、その中にpomファイルとか色々作成されてると思います。
  
これでローカルにMavenのリポジトリが完成しました。
<br><br>
## GitHubでホストする
次はこの完成したリポジトリをGitHubにPushしてあげましょう。  
そのままPushしてもいいのですが、使う側が`gradle.build`に記入するリポジトリURLがイマイチかっこよくありません。  
そこで、GitHubの[GitHub Pages](https://pages.github.com/)の機能を使い、`http://<user>.io/lib` のようなURLで依存関係を解決できるようにしましょう。  
  
GitHubPagesはリポジトリに`gh-pages`というブランチを作り、そこにPushすればそれらがホストされます、例えば`gh-pages`に`index.html`が存在すれば`http://<user>.io/<repo>`というURLを叩けばそのindex.htmlが描画されます。  
  
今回はローカルに`repository`というディレクトリが完成したので、このディレクトリを`gh-pages`にPushするのが最終目的です。  
しかし、このリポジトリはライブラリ本体や、Android用のサンプルコードなど、様々なファイルから構成されています。それらが`gh-pages`にPushされるのはあまりよくありません。`repository`ディレクトリだけがPushされたい。
  
そこで今回は頑張ってググって出てきた[nobuoka/commit-built-files-to-gh-pages-branch.markdown](https://gist.github.com/nobuoka/d0f088df57d50e4cda1a)こちらを参考にし、Pushすることができました。（本当に有難うございます）  
  
```shell
$ git add -f ./repository
$treeObjId = git write-tree --prefix=repository
$ git reset -- ./repository

$ git branch gh-pages

$commitId = git commit-tree -p gh-pages -m "add the vx.y.z files for the Maven repository" $treeObjId

git update-ref refs/heads/gh-pages $commitId
```

この手順で無事`repository`ディレクトリだけ`gh-pages`にPushすることが出来ました。  
もともと`gh-pages`というブランチをローカルに作成してなかったため、途中で作成しています。  
ツリーオブジェクトをつくり、それでコミットを作り、リモートの`gh-pages`にそのコミットを参照させる、という流れらしいです。  
  
今回は`gh-pages`にだけ`repository`ディレクトリをPushし、このディレクトリは他のブランチに含みたくなかったため、この手法をとりましたが、そうでない場合（ビルドした物を`develop`や`master`ブランチに含めてもいい場合）は`git subtree`コマンドを利用して特定のディレクトリだけ別ブランチに切り出して公開するのが手っ取り早いようです。
  
これで今回作成したライブラリは使いたいプロジェクトの`build.gradle`に

```gradle
repositories {
    maven { url 'http://yagi2.github.io/RxBox/' }
}

dependencies {
    compile 'com.yagi2:rxbox:0.0.1'
}
```

と記入するだけで使えるようになりました。  
嬉しい！早く充実させなければ。  
<br><br>
## おわりに
今回はbintrayに見事にお断りされたので（個人でMavenリポジトリ作れないと書いているブログは見当たらなかった）この手法を取りました。  
利用する側はちょっとurlを書かなければならないという手間は出来てしまいますが、ビルドして出来たライブラリをインポートしてという手順を踏むよりは100倍良いのではないかと思います。
個人利用の簡単なライブラリではありますが、頑張って充実させていきたいと思います（僕も今のところ足りなくて不便している）  
  
以上。やぎにいでした！