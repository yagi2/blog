---
title: Ruby on RailsでつくってみるAPI（まとめと考察）
date: 2016-12-23 12:12 JST
tags: やぎすけAdventCalendar2016,Rails
---

こんにちは、やぎにいです！
[やぎすけ Advent Calendar 2016](http://www.adventar.org/calendars/1800)の23日目です。  
残すところ今日含めあと3日……！年の瀬ですね……。

昨日は僕が[Ruby on RailsでつくってみるAPI（2日目）](https://blog.yagi2.com/2016/12/22/rails-api-day2.html)を書きました。  
  
今日は昨日一昨日とやって出てきた問題点を解決したりRailsの気づきをまとめます
## searchメソッドでの処理が甘い
昨日一昨日の記事を前提に、アイマスAPIでの話をします。  
  
Charactersコントローラーでのアイドルの絞り込み検索であるsearchメソッドはこういう実装をしていました。  

```rb
# GET /characters/search
# 必須パラメータ name:string
def search
  if params[:name].blank?
    render json: [{"error": "100", "msg": "必須パラメーターがありません", "required": {"key": "name"}}]
  else 
    @result = Character.where("name like ?", "%" + params[:name] + "%")

    if @result.empty?
      @result = Character.where("phonetic like ?", "%" + params[:name] + "%")
    end

    render json: @result
  end
end
```

実装としては

* 必須パラメータがない場合はエラーのjsonを返却する  
* 受け取ったパラメータをまず名前で検索する  
* もし名前で一致しないならふりがなで検索する  

といった内容です。  
まずいケースとしては`天海春香`と`天海はるか`というアイドルが別に同時に存在した場合です。  
両方のふりがなは`あまみはるか`だとして、もし`/characters/search=name?はるか`を叩いたらどうなるでしょうか。  
  
まず名前で検索され、`天海はるか`がヒットします。  
この時点で一致した物があるため、ふりがなでの検索は行いません。  
結果`天海はるか`1件だけ返ってきます。  
欲しい理想の結果は`天海春香`がふりがな検索で一致して、`天海はるか`が名前検索で一致する2つが返ってくることです。  

以下のように変更しました  

```rb
# GET /characters/search
# 必須パラメータ name:string
def search
  if params[:name].blank?
    render json: [{"error": "100", "msg": "必須パラメーターがありません", "required": {"key": "name"}}]
  else 
    @result = Character.where("name like ?", "%" + params[:name] + "%")
    @result += Character.where("phonetic like ?", "%" + params[:name] + "%")
    

    render json: @result
  end
end
```

単に名前検索の結果にふりがな検索の結果を足しています。  
これで両方ヒットして返ってくるように成りました。  
  
が、次の問題が発生しました。  
`天海はるか`は`?name=はるか`を渡すと名前でもふりがなでもヒットしてしまい、これでは`天海はるか`と`天海春香`と`天海はるか`の3件がjsonで返ってきました。  
重複は要らないので`render`の行を`render json: @result.uniq!`に変更しました。  
これで`?name=はるか`で叩いたときは`天海春香`と`天海はるか`が返ってきました。よさそうです。  
  
が、また次の問題が発生しました。  
今度は`?name=天海春香`で検索したときに`null`が返ってくるのです。  
これには悩まされましたが、うなすけの力を借り、[class Array (Ruby 2.3.0) #uniq](https://docs.ruby-lang.org/ja/2.3.0/class/Array.html#I_UNIQ)にたどり着きました。  

> uniq! は削除を破壊的に行い、削除が行われた場合は self を、 そうでなければnil を返します。  

つまり、もし重複していない場合`render json: result.uniq!`をするとnilが返ってそれが`null`として表示されていました。  
なるほど……。  
  
そして最終的に以下のようになりました

```rb
# GET /characters/search
# 必須パラメータ name:string
def search
  if params[:name].blank?
    render json: [{"error": "100", "msg": "必須パラメーターがありません", "required": {"key": "name"}}]
  else 
    tmp = Character.where("name like ?", "%" + params[:name] + "%")
    tmp += Character.where("phonetic like ?", "%" + params[:name] + "%")
    
    result = tmp.uniq
    render json: @result
  end
end
```

ついでに@付きの変数の意味を調べ、[【まとめ】インスタンス変数、クラス変数、クラスインスタンス変数](http://qiita.com/mogulla3/items/cd4d6e188c34c6819709)を参考に、このケースでは必要ないな、と思い消しています。  
これで無事理想の絞り込み検索メソッドが出来上がりました。よかったよかった。  
<br><br>
## /characters で仕様をHTMLで表示したい
これも昨日の記事で返したいが、できなかったので`head 404`としてとりあえず404エラーを返して居たところです。  

これに関してはホントにコードをぼーっと眺めていて「もしや？！」という気付きからだったのですが、現在`CharactersController`は`ApplicationController`を継承しています  
`application_controller.rb`を覗いてみると、これは`ActionController::API`を継承していました。  
この`ApplicationController < ActionController::API`を見たときに「もしかして」と思って、GitHubにある適当なRailsアプリのソースを読みました。  
すると大体のアプリがApplicationControllerは`ActionController::Base`を継承していたことがわかりました。  
  
「もしかして」が当たっているかもという感じになり、このアプリでも`ActionController::Base`を継承すると、無事に/charactersでもcharacters/index.html.erbが表示されるように成りました。  
  
`ActionController::API`はrailsアプリを作成する際に`--api`を指定してRails5からのAPIモードで作成するとそうなるようですが、極力viewに関する処理を取り除いたAPI特化なモードがAPIモードになっているので、こういうような形になっているようです。  
  
今回はAPIモードでつくるという形でやってきたので、なるべくそのままでやりたかったのですが今のところ「とりあえず」という形で`ActionController::Base`を継承しています。  
  
ついでにwelcomeページも自分で表示させるようにしました。  
  
コードについては掲載すると長くなるので[このコミット](https://github.com/yagi2/imas_api_rails/commit/66560e2efc080d6fdcd3d1a0600870b9a1304ccb)を参照してください。  
  
なんとか::APIのままでもhtmlを返せるように模索していくつもりです。
<br><br>
## おわりに
これで3日間のRailsでやってみる記事は一旦終了となります。  
が、これからもこのAPIはちょこちょこ作っていくつもりなので、適宜何かアウトプットしていきたいと思います。  
今考えている今後やりたいのは  

* 今回のsearchメソッドのような事が起きないためにもテストをちゃんと書いてCIで回す  
* VPSでこのアプリを動かす  

の2つは脳内高層で存在します。  
前者はこのアプリにテストコードを追加してくれたうなすけが居なかったらそもそもテストという発想にはいたらなかったと思います。  
  
それでは 以上、やぎにいでした。

