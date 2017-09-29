---
title: さくらのVPS（CentOS）をLet's EncryptでHTTPSに対応させる
date: 2016-08-31 02:19 JST
tags: 備忘録, Let'sEncrypt, サーバ, セキュリティ
---

2017/09/29 追記  
<font color="red">この記事は備忘録として、使ったコマンドをそのまま掲載していました（ドメイン名やメールアドレスがそのまま）が、おそらくそれをそのままコピペしたであろうことによって自分のメールアドレスに知らないドメインの証明書有効期限切れアラートメールが飛んできたので全てexample等に置き換えの修正を行っています。</font><br>  
<font color="red">以前の版を読みたい方はこのブログは全てGitHub上で公開しているので<a href="https://github.com/yagi2/blog/commit/f27c40b6fa84ab842ee6025d51c9b46a268a2529">こちら</a>を参照してください。（記事本文のMarkdown形式が読めます）</font><br>  

<br>
こんにちは。やぎにいです。
今回は[Let's Encrypt](https://letsencrypt.org/)というものを使って、自分のサーバをHTTPS対応させました。  
（日本語ポータルサイトは[こっち](https://letsencrypt.jp/))
備忘録タグがある通り、自分の環境でのメモも兼ねていますので、動かない場合や自分の環境と違うという方は適時読み替えていただくか、Google先生にたずねてください。  

## 環境
* さくらのVPS :（https://yagi2.com https://blog.yagi2.com https://diary.yagi2.com をホスト）
* CentOS release 6.6 (Final) （いい加減7にしたいですね）
* Apache/2.2.15 (Unix)
* iptables v1.4.7
* Python 2.7.8（後述します）

## 昔話
昔、このさくらのVPSにowncloudを設置したことがありまして、ブラウザから操作する分にはいいのですがPC版のクライアントアプリ（Dropboxのようなものだった）を接続するのはHTTPSじゃないと怒られるということがありました。  
そのころはLet's Enctyptなんてものがなかった（2016年4月12日が正式サービス開始らしいですね）ので、所謂”オレオレ証明書”を作って適用して使っていました。  
どうせ使うのは自分だけだしいいかぁとか思いつつ使ってたのですが、お察しの通りブラウザで出先等々からアクセスすると「このページは危険です！」というあの表示が……ｗ  
だんだんそれをいちいち処理するのがめんどうになって使わなくなったという過去があります。 良い時代になりましたね。（多分昔も何かしらあったとは思うけど）

## Pythonのバージョンを確認する。
Let's Encryptで使用されているPythonのバージョンが2.7以降でないといろいろ怒られてしまうのですが、CentOS6系でのデフォルトは上記の通りPython2.6なのでバージョンを上げてやります。  
しかし、単純に`yum install`でupdateは出来なかったので、CentOSのSCLというものを利用してパッケージをインストールします。

```bash
$ sudo yum install centos-release-SCL
$ sudo yum install python27 python27-python-tools
$ sudo yum install dialog
```

SCLでインストールしたパッケージの使い方は以下のとおりです。  
コマンドと結果を載せるので、挙動を確認してください。  

``` bash
# 素の場合
$ python --version
Python 2.6.6

# パッケージを有効にしたbashを起動する場合
$ scl enable python27 bash
$ python --version
Python 2.7.8

# bashは嫌なのでpython27でコマンドを実行したい場合
$ scl enable python27 'python --version' # シングルクォート等で囲みます
Python 2.7.8
 ```

以降は手法を問わずPython2.7.8の環境で動作されていることを予めここに記しておきます。

## 80, 443ポートを開けておく
これを呼んでいるということはおそらくHTTPで何かしらのコンテンツをサーバに置いて公開している方だと思うので、80番は大丈夫だと思いますが、443(HTTPSで使用する)番があいてない場合がありますので、開けておきます。  

```bash
$ sudo emacs /etc/sysconfig/iptables # emacsを使ってますがvimでもnanoでもなんでもいいです 要するにエディタで開いてください

# 以下の記述をする
---------- 省略 ----------
-A RH-Firewall-1-INPUT -m state　NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A RH-Firewall-1-INPUT -m state　NEW -m tcp -p tcp --dport 443 -j ACCEPT
---------- 省略 ----------

$ sudo service iptables restart
```

## 証明書を取得する
今回はCertbotクライアントを使用してSSL/SSL/TLSサーバ証明書を取得します。
Certbotをgitからcloneするのでgitがインストールされていない場合はgitをインストールし、Certbotのリポジトリをcloneします。

```bash
$ sudo yum install git
$ git clone https://github.com/certbot/certbot
$ cd certbot
```

これでCertbotの準備はできました。  
それでは証明書を取得してみましょう

``` bash
# Apacheが動いていると途中で怒られるので予め停止しておく
$ sudo service httpd stop

# 自分のドメインやメールアドレスに適時置き換えてください
# 今回は同一サーバでホストしている3ドメインに対して証明書をリクエストします。
$ sudo ./certbot-auto certonly --standalone --email mail@example.com -d exmaple.com -d blog.example.com -d diary.example.com
```

お疲れ様でした！これで証明書の取得は完了です。簡単ですね。素晴らしい世界です。  
本当に存在するのか確かめてみましょう

```bash
$ sudo ls -l /etc/letsencrypt/live/example.com
合計 0
lrwxrwxrwx 1 root root 33  8月 28 04:29 2016 cert.pem -> ../../archive/example.com/cert1.pem
lrwxrwxrwx 1 root root 34  8月 28 04:29 2016 chain.pem -> ../../archive/example.com/chain1.pem
lrwxrwxrwx 1 root root 38  8月 28 04:29 2016 fullchain.pem -> ../../archive/example.com/fullchain1.pem
lrwxrwxrwx 1 root root 36  8月 28 04:29 2016 privkey.pem -> ../../archive/example.com/privkey1.pem
```

同じようにありましたか？上からそれぞれ、「サーバ証明書（公開鍵）」「中間証明書」「サーバ証明書と中間証明書が統合されたファイル」「秘密鍵」です。

## HTTPS通信を有効にする
今回は自分が複数のバーチャルホスト毎にconfigファイルを作り分けているので、そのケースで書きます。  
参考： [複数のバーチャルホストでSSL通信の設定を行う｜CMS構築の現場から｜CMS比較.com](http://cmshikaku.com/feature/?p=1429)

```bash
# ssl.confの編集（自分の場合 /etc/httpd/conf.d/ssl.conf でした）
$ sudo emacs /etc/httpd/conf.d/ssl.conf

# <VirtualHost _default_:443>と</VirtualHost> 及びその挟まれている部分を削除する（コメントアウト可）
----------省略----------
<VirtualHost _default_:443>
  === ここの中身も削除 ===
</VirtualHost>

# 以下を追記する
NameVirtualHost *:443
```

``` bash
# 各バーチャルホストの設定ファイルを編集する
$ sudo emacs /etc/httpd/conf.d/virtualhost-example.com.conf

# 証明書の指定とSSLエンジンを有効にする （今回は実際のconfigファイルを以下に記載します）
<VirtualHost *:443>
    ServerName example.com
    DocumentRoot [コンテンツのパス]
    ErrorLog logs/virtual-error_log
    CustomLog logs/virtual-access_log combined env=!no_log

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/example.com/chain.pem
</VirtualHost>
```

これで example.com はSSLに対応しました。  
Apacheを再起動して確認してみましょう。  

```bash
$ sudo service httpd restart
```

ブラウザで開いてみるとちゃんとHTTPS通信されていることがわかりますね！  
これで完了です！ おめでとうございます。
複数バーチャルホストをしている場合は、適時その分コンフィグを書いてあげてください。

## 証明書を更新する
Let's Encryptで取得した証明書の期限は90日になっています。よって定期的に自分で更新して上げる必要があります。  
なぜ90日なのかは[Why ninety-day lifetimes for certificates? - Let's Encrypt](https://letsencrypt.org/2015/11/09/why-90-days.html)こちらをどうぞ。セキュリティの為と証明書更新の促進みたいですね。  

更新は簡単です。

```bash
$ sudo service httpd stop
$ ./certbot-auto renew
$ sudo service httpd start
```

以上です。  
簡単でしょ！ということで、自動的に更新するスクリプトを書いてcron等で定期的に更新してあげましょう。  
ファイル名は encrypt-renew-script.sh とします

```bash
#! /bin/bash

/etc/rc.d/init.d/httpd stop
/usr/bin/scl enable python27 '/home/user/certbot/certbot-auto renew > /home/user/certbot/logs/renew.log 2>&1'
/etc/rc.d/init.d/httpd start
```

``` bash
# cronの編集
$ sudo crontab -u root -e  # サービスの停止/開始のためrootで

# 以下を書く 毎月25日6次の設定
00 06 25 * * /home/user/certbot/scripts/encrypt-renew-script.sh
```

これで自動更新の設定は完了です。（僕自信まだ導入してから次の25日が来ていないので動くかは未確認です）  

## おわり
これでLet's Encryptを使って証明書を取得しHTTPS対応、そして証明書の自動更新の設定が完了しました。  
ちょっと長かったですが、これでセキュアなホスティングをすることができますね。  
長くなってしまったため次回になりますが、次回はHTTPにリクエストが来た場合にHTTPSにリダイレクトしたりHSTSを導入したりして、サイトの評価で高ランクを取るセキュアなサイト構築の手順をご紹介します。  

余談ですが 今回適用したyagi2.comは[Qualys SSL Labs](https://www.ssllabs.com/index.html)でA+を取得しています。  

![](2016/08-31-lets-encrypt-001.png)
