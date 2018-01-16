---
title: Let's Split（レツプリ）を組み立てた
date: 2018-01-16 13:30 JST
tags: キーボード
---

## レツプリとは  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ドンッ <a href="https://t.co/F9HvHQxgqR">pic.twitter.com/F9HvHQxgqR</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/950911003822190598?ref_src=twsrc%5Etfw">2018年1月10日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>  

見慣れない形かもしれませんが。キーボードです。  
格子配列で、左右分離型のコンパクトなキーボードです。  
全部で48キーしか無く、いわゆる40％キーボードというやつになります。  
  
おなじ40％キーボードだとPlanckというやつが有名ですが、それを左右分離型にしよう！といった感じでWootpatoo氏によって開発されたPCB（プリント基板）のことです。  
  
もちろんプリント基板なので、普通の売ってるキーボードではなく、その基板に自分でダイオードやキースイッチ、Pro Microなど必要なパーツをはんだ付けする必要があります。  
ただ（個人の感想ですが）、電子工作としてはかなり初歩で難しくもないので誰でも始めることができると思います。  

## 必要なもの
Let's Splitの組み立てガイドはGitHubに公開されています。 → [nicinabox/lets-split-guide assembly.md](https://github.com/nicinabox/lets-split-guide/blob/master/assembly.md)  

基本はここの必要パーツ類を買えば組み立てることができます。  
自分が用意したのは以下のモノたちです。  
  
| パーツ | 購入先 | 値段 |
|:------|:------|----:|
| PCB x2 | [MEHKEE](https://mehkee.com/products/lets-split-pcb?variant=46050392207) | $8.99	|
| Pro Micro x2 | [ebay](https://www.ebay.com/itm/New-Pro-Micro-ATmega32U4-5V-16MHz-Replace-ATmega328-Arduino-Pro-Mini/221891843710?hash=item33a9c8d67e:g:D70AAOSwVL1V~1dn) | $10.18 |
| ダイオード x48 (100) | [MEHKEE](https://mehkee.com/products/diodes-1n4148tr?variant=38125832015) | $3.29 |
| TRRSジャック x2 | [MEHKEE](https://mehkee.com/products/trrs-jacks?variant=44914458511) | $3.29 |
| プレート＆ケース | [Ponoko - Acrylic - Pink 3.0mm P](https://www.ponoko.com/) [sandwich-split.eps](https://github.com/nooges/lets-split-v2-case/blob/master/sandwich-split.eps) | $46.27 |
| M2 12mm スペーサー x8 & 5mm M2 ネジ x16 | [ウィルコ](http://wilco.jp/products/index_kei.html) | ¥3,186 |
| キースイッチ x48 (Cherry MX Gray Liner x50) | [MechanicalKeyboards.com](https://mechanicalkeyboards.com/shop/index.php?l=product_detail&p=2088) | $37.50 |
| キーキャップ x48 (50) | [TALP KEYBOARD](https://talpkeyboard.stores.jp/?page=1&scroll_target=59cce95ff22a5b48ed001e29&category_id=59e2acfaed05e644fd004008) | ¥2,700 |
| TRRSケーブル | [MEHKEE](https://mehkee.com/products/trrs-cable?variant=47187517711) | $5.49 |
| タクトスイッチ | [Amazon.co.jp](http://amzn.asia/hIbItyM) | ¥491 |
| microUSBケーブル（マグネットケーブル） | [Amazon.co.jp](http://amzn.asia/6me4mQo) | ¥2,463	|
| クッションゴム | [Amazon.co.jp](http://amzn.asia/7dGjiCD) | ¥373	|
<br>  

| USD合計 | JPY合計 | 合計 |
|:------:|:------:|:----:|
| $115.01 | ¥9,213 | 約22,150円 |  
  
こんな感じです。  
  
基本は上記のビルドガイドに準拠していますが、ケースが[nooges/lets-split-v2-case](https://github.com/nooges/lets-split-v2-case)を使っています。  
このケースがM2ネジを使っているので、それに合わせたサイズのネジ・スペーサーを買いました。  
  
タクトスイッチはProMicroのRSTとGNDにつけて、ファームウェアを焼く際に使います。（が、無くてもピンセットとかペンチでショートさせればいいので無くてもいいです）（自分はつけたスイッチが数回折れたのでもう使ってないです）  
  
新しいバージョンのPCBを購入した場合はProMicroの近くにタクトスイッチを付ける場所が存在するのでそこにつけると安全だと思います。  
  
クッションゴムはケースのボトムプレートにつけて滑り止めと高さをつけるのと机にタイプ音が響かないようにしています。  
  
microUSBケーブルはProMicroのmicroUSBコネクタが非常にもげやすいのでなるべく抜き差ししなくてもいいマグネットタイプを使用しています。どんだけもげやすいかは「レツプリ」あたりでググるとめちゃくちゃもげ例が出てきます。（対策も後述します）  
  
大体2万ちょいですが、送料含めると3万弱になりました。  
  
知見ですが、Ponokoはニュージーランドとアメリカ両方に工場があるらしく、オーダーできるプレートの種類は変わるもののニュージーランドにしておけば送料がちょっと安くなるそうです。（アメリカだと送料で50USD取られました）  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Ponoko、USだと送料お高めですがNZだとちょっと安いですよ</p>&mdash; .🅽🅸🅻🅻🅿🅾.🆂🆆🅿🐶 (@nillpo) <a href="https://twitter.com/nillpo/status/949335788071698432?ref_src=twsrc%5Etfw">2018年1月5日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>  

nillpoさんより教えていただきました……。非常に感謝です。次はNZにします。  
  
自分のレツプリはちょっと高めですが、キースイッチをCherryにしていたりするので最悪いらないキーボードから剥いだりすると1万円くらいで作ることができると思います。
  
最後に購入するショップですが、Mehkeeだとたまにスイッチ以外（スイッチもオプションで選べる）がセットになったものを売ったりしているのでそれが1番楽だと思います。  
  
TALPは国内なので安心+めちゃくちゃ早いのでかなりおすすめです。ProMicroとかも入荷してたりします。ただ品切れ早かったりするのでウォッチすることが大切です。  

## 組み立て  
意外と順序を間違えると詰んで材料調達からになるので気をつけてください。  
基本はGitHubのビルドガイドどおりにやれば間違いないです。  
 
### ProMicroの下処理  
上記で上げたようにProMicroのUSBコネクタ部は非常にもげやすいです。はんだ付けした後とか使ってる時にもげる例もめちゃくちゃあってそうなるとかなりつらいので予めもげないように補強しましょう。  
  
今回はエポキシ系の接着剤で上から補強してあげました。  
写真を撮り忘れていましたがこちらを参考にさせていただきました。  
[Let's Split Build Log - log.fstn](http://fstn.hateblo.jp/entry/2017/12/13/041215)  

### ダイオードの取り付け  
全部で96個のダイオードを取り付けます。  
この時に極性に注意しましょう。PCBのダイオードを取り付ける場所（Dxxと書いてある）の■側がダイオードの黒いラインが来るように取り付けます。  
  
取り付けの際はツールクリッパーなどがあると便利です。  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ダイオードだけつけておこう <a href="https://t.co/c7a4GgPFRm">pic.twitter.com/c7a4GgPFRm</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/949619723964002304?ref_src=twsrc%5Etfw">2018年1月6日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">とりあえずダイオードつけた <a href="https://t.co/hWSEvWpd1b">pic.twitter.com/hWSEvWpd1b</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/949634532117917696?ref_src=twsrc%5Etfw">2018年1月6日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

うーん、実に中学生以来のはんだ付けっぷり。  

### TRRSジャックの取り付け  
キーボードの左右を繋ぐTRRSケーブルを挿すジャックを取り付けます。  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ジャックをとりつけました <a href="https://t.co/dC9LDGlfUa">pic.twitter.com/dC9LDGlfUa</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/949636678091620352?ref_src=twsrc%5Etfw">2018年1月6日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
画像を見てもらうとわかりますが、この時右側はVccとその真下、左側はGNDとその真上をはんだでジャンプさせる必要があります。  
  
新しいバージョンのPCBだとここの部分が違ってるらしいですが、ジャンプさせるのは同じです。わかりやすくなったとか。  

### Pro Microのピンヘッダの取り付け  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ProMicroのピンヘッダまで取り付けました <a href="https://t.co/IVuBJje4Gf">pic.twitter.com/IVuBJje4Gf</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/949641474194329600?ref_src=twsrc%5Etfw">2018年1月6日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
注意ですが、このときはまだピンヘッダだけ取り付けます。  
ここでProMicroを取り付けると、スイッチが取り付けられなくなり詰みます。  
  
### キースイッチの取り付け  
ピンヘッダをつけたらキースイッチを取り付けましょう。ProMicroの上に来るのだけさきにやってもいいですが、自分は最初に全部つけました。  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">とりあえず片方 <a href="https://t.co/WUaGzf89Fd">pic.twitter.com/WUaGzf89Fd</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/950185713424715776?ref_src=twsrc%5Etfw">2018年1月8日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
裏側の写真を撮り忘れていますが、ピンをはんだで付けるだけです。  
トッププレートが存在するケースを使う際は、PCBとスイッチでトッププレートをはさみましょう。  
  
この時スイッチの取付がゆるいとがたがたになるので、PCBにしっかり取り付けてあげます。  

### Pro Microの取り付け  
ここまで来るともうほぼ完成です。  
  
最後に大事なProMicroをつけてあげましょう。左右でオモテウラが逆になるので注意して取り付けます。  
（もう動作確認しちゃってますが、こんな感じです。）  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">動作確認 <a href="https://t.co/pW3TSmud0j">pic.twitter.com/pW3TSmud0j</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/950199676724068353?ref_src=twsrc%5Etfw">2018年1月8日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
ProMicro取り付けで注意する点は、一部のProMicroは購入時にUSBコネクタ近くにあるJ1が既にブリッジされているものがあります。  
そこがブリッジされていると動作しないので、もし買ったものが該当する場合ハンダ吸い取りとかを使ってブリッジを外してください。  
  
自分が片方だけそうなっていて気づかずに「やっちまったか！？」となりました。  
これに関してはGitHubのビルドガイドの一番下にあるトラブルシューティングの欄に  
> One side isn't working  
> - Make sure J1 on the Pro Micro is not bridged.  
  
という記載があります。  
  
## ファームウェアの書き込みと動作確認  
[qmk/qmk_firmware](https://github.com/qmk/qmk_firmware)を書き込みます。  
自分がMacをつかっているので、Macでの書き込み方になります。  
Windowsも公式ドキュメントに導入方法が書いてあるので参考にしてみてください。  
[Install Build Tools · QMK Firmware](https://docs.qmk.fm/getting_started_build_tools.html)  
  
brewを使って必要なものをインストールします。  
  
```shell
$ brew tap osx-cross/avr
$ brew update
$ brew install avr-gcc
$ brew install avrdude
```  

これで書き込みに必要なツールは入りました。  
次にプロジェクトをcloneしておきましょう。  
  
```shell
$ git clone https://github.com/qmk/qmk_firmware.git
```
  
.hexファイルの作成と書き込みは以下です。  
  
```shell
$ make lets_split/rev2:<キーマップ名> # .hex作成
$ make lets_split/rev2:<キーマップ名>:avrdude # 書き込み
# 例
$ make lets_split/rev2:yagi2-qwerty
$ make lets_split/rev2:yagi2-qwerty:avrdude
```  

書き込みの方のコマンドを打つと、ProMicroのリセットを求められるので取り付けたタクトスイッチ、またはRSTとGNDをショートさせてください。  
（RESETがキーマップに存在するキーマップを書き込むと、タクトスイッチの操作もショート操作も要らないので楽です。自分はタクトスイッチもげたので適当なレイヤーにResetをいれてます。）  
  
初期のままだと左手側がマスタになっているので、そっちのProMicroにさえ書き込めば大丈夫です。  
  
書き込みが無事終了したら、キーを適当に押してみて動作確認をしましょう！  

## 仕上げ
用意したケースやキーキャップをつけてあげて完成させましょう。  
<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">ボトムプレートちゃんとつけました <a href="https://t.co/k6Xa3QkVs0">pic.twitter.com/k6Xa3QkVs0</a></p>&mdash; やぎにいちゃん＠残機:334人 (@yaginier) <a href="https://twitter.com/yaginier/status/952697943164768256?ref_src=twsrc%5Etfw">2018年1月15日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  
クッションゴム等も買った場合は取り付けておきましょう。  
  
## 自分のキーマップ  
かなり悩みましたが[Planckキーボードのキーマップ。 - leopardgeckoのブログ](http://leopardgecko.hatenablog.com/entry/2017/10/11/231150)こちらを参考にさせていただきました。  
[qmk_firmware/keymap.c at master · yagi2/qmk_firmware](https://github.com/yagi2/qmk_firmware/blob/master/keyboards/lets_split/keymaps/yagi2-qwerty/keymap.c)  
<script src="https://gist.github.com/yagi2/12197733cd65db71447d53cf4385931c.js"></script>

これはQwerty配列ですが、別配列としてゆかりさん（[@eucalyn_](https://twitter.com/eucalyn_)）が[ぼくのかんがえるさいきょうのインターフェイス - ゆかりメモ](http://eucalyn.hatenadiary.jp/entry/saikyo-interface)で考案された、所謂Eucalyn配列版も作って利用しています。  
  
配列に関しては昨年の[自作キーボード Advent Calendar 2017](https://adventar.org/calendars/2114)の記事の1つのないんさん（[@pluis9](https://twitter.com/pluis9)）の記事である[キー配列頂上決戦！さいつよなレイアウトはどれだ！ | 遊舎工房](https://yushakobo.jp/pluis9/2017/12/thinkkeylayout/)でいろんな配列が検証されています。 
     
自分自身はQwertyとDvorakしか使ったことがありませんでしたが、スコアから見てEucalyn配列がとても良さそうだったので使用しています。 
[qmk_firmware/keymap.c at master · yagi2/qmk_firmware](https://github.com/yagi2/qmk_firmware/blob/master/keyboards/lets_split/keymaps/yagi2-eucalyn/keymap.c)
<script src="https://gist.github.com/yagi2/1f9b468660da846581bb0a6437aa6df7.js"></script>
  
慣れるまでのコストはありますが、かなり打鍵していて気持ちいい配列だと感じます。  
  
キーマップではないですが、クリックで英数・かな、長押し（ホールド）でRaise/Lowerの長押しの時間を調節したい場合は`tmk_core/common/action_tapping.h`の中にある`TAPPING_TERM`を調節してあげれば大丈夫です。自分は60台後半です。  
  
## 今回作ろうと思った理由  
元々キーボードは好きで初めてメカニカルキーボードを触ったのは中3の頃のMajestouch茶軸でした（そしてこのキーボードはこのレツプリを作るまでは現役でした！）。そこから青軸や、HHKB Liteなどを触りセブンイレブンのATMのテンキーは無駄に連打してしまう人間でした（あのテンキーは東プレのキーボードの技術が使われています）。  
仕事が仕事だったり、自宅でもキーボードをよく触っているので自分の手に馴染む武器が欲しかったという理由が第一です。  
  
キースイッチを何色にしようかは最初から実は決まっていて、ヨドバシカメラでだいぶ昔にレア軸としてそこで売ってあったGray軸（Liner）を触った時に凄く感動したことをずっと覚えていて、このスイッチを使って自分の手に馴染むようなキーボードを作りたいという理由から今回レツプリを作りました。  
  
結果としてはスイッチは結構重めなんですが（80g Liner）別に一番下まで打鍵する必要がないのと、自分自身手が男性の割に小さいということもあり40％キーボードは手に収まって非常に気持ちがいいです。（慣れるまでは脳を酷使してる感じはありますが）  
  
## さいごに  
今回は自分の使う道具を自分の馴染む形で作るお話でした。  
  
もう1度いいますが、作るハードルは本当に意外と低いので興味があったら是非作ってみてください。オススメです。  
  
わからないことがあったら自分でも、Twitterにいっぱいいらっしゃる自作キーボードの凄い方たちや、自作キーボードの日本コミュニティDiscordもあるのでそこで聞いてみてください。  
[Self Made Keyboard in Japan Discord Server を開設した話 - たのしい人生](http://biacco42.hatenablog.com/entry/2017/11/17/093000)  
  
<br>
このブログの記事はLet's Splitを使ってEucalyn配列で書かれました！