---
title: KotlinとSpring Bootを使ってサクッと叩けるAPIを作る
date: 2017-10-04 20:13 JST
tags: Kotlin,Spring,SpringBoot
---

以前から大分アツいAndroidでのKotlin話であるが、今回はKotlinとSpring Bootを使って簡単にjsonを吐くAPIアプリケーションを作ってみたいと思う。  
  
KotlinについてとSpring Framework,Spring Bootに関しては特記しないので各々よしなに。
  
## プロジェクトの作成  
[Spring Initializer](http://start.spring.io)という素晴らしいものがあるのでこれを使っていく。  
今回は  

- Gradle Procjet  
- with Kotlin 1.1.4-3  
- and Spring Boot 1.5.6  

で作成。  
依存には`web`と`jpa`を追加している。

```groovy
compile('org.springframework.boot:spring-boot-starter-data-jpa')  
compile('org.springframework.boot:spring-boot-starter-web')  
```

がbuild.gradleに追加される形になる。  

## RESTの基本
クラスに`@RestController`アノテーションを付けるとそのクラスがいい感じにコントローラーとして認識される。
リクエストに対するメソッドのbindは`@RequestMapping(PATH, REQUEST_METHOD)`というアノテーションをメソッドに対して付与する。  

```kotlin
@RestController
class IndexController {
  @RequestMapping("/", arrayOf(RequestMethod.GET))
  fun index(): String = "Hello Spring with Kotlin!"
}
```

このクラスを作った状態で`./gradlew bootRun`をしてあげると`localhost:8080`で`Hello Wpring with Kotlin!`を表示される。

## DBとの接続
単に静的なものを返してもアレなので、DBに保存してあるデータをAPIが叩かれたらjsonで吐くみたいなことをしたい。  
Postgresqlで行っていく。  
  
Spring Initializerで依存追加したSpring Data JPAというのがとりあえず強いのでそれを使う。  
postgresqlを使うときは更に依存に `runtime('org.postgresql:postgresql')` を追加してあげるといい。  

そしてKotlinを使う場合、EntityとかのモデルクラスをDataClassとしてそのまま作成するとデフォルトコンストラクターが〜みたいなエラーを吐くのでbuild.gradleに以下を追加してあげる。  

```groovy
classpath ("org.jetbrains.kotlin:kotlin-noarg:${kotlinVersion}")
apply plugin: "kotlin-jpa"
```

該当のstackoverflowは[ここ](https://stackoverflow.com/questions/32038177/kotlin-with-jpa-default-constructor-hell)
  
更にDataSourceの設定として、`src/main/resource`の下に`config`ディレクトリを作成し、`application.yml`を追加してそこにDBへの接続情報を書き込む。  

```yml
spring:
  datasource:
    url: jdbc:postgresql://localhost/[データベース名]
    username: username
    password: password
    driverClassName: org.postgresql.Driver
```

これでDBに接続する準備は完了。次に必要なクラスとインターフェースを作っていく。  
  
### Entity
まずサンプルを見てもらったほうが理解しやすいのでサンプルコード  

```kotlin
@Entity
@Table(name = "テーブル名")
data class User (
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  val id: Int,
  
  @Column(name = "name")
  val name: String,
  
  @Column(name = "post_code")
  val postCode: String
)
```

`@Column`アノテーションをつけてあげると、スネークケースとキャメルケースの変換をしてくれる（Androidでよく使うところとしてはMoshiとかgsonとかのあんな感じ）。  
`@GeneratedValue`を付与すると、値を指定しなくても自動される。`@Id`をつけるとプライマリーキーとして指定することができる。  

### Repository
これがSpring Data JPAの強さ（？）

```kotlin
interface UserRepository : JpaRepository<User, Int> {}
```

これだけ書いておけばOK。`JpaRepository`を継承していればSQLを書かずにメソッド名からいい感じにSQL文を作ってくれてよしなにしてくれるらしい。
例えば名前からselectしたいメソッドが欲しい場合は  

```kotlin
interface UserRepository : JpaRepository<User, Int> {
  fun findByName(name: String): List<User>
}
```

と`findBy〜`とか書いておけばいい感じに勝手にしてくれる。もちろんASCとかDESCとかでの並び替え等々や複雑なものも書ける。[参考](http://dev.classmethod.jp/server-side/java/use_spring-boot-jpa-jpql/)  
あまりに複雑にするとメソッド名が長くなりすぎると思うのでそこはいい感じにしてほしい。  

### Service
RepositoryとControllerを繋ぐ。  

```kotlin
@Service
@Transactional
class UserService {
  @Autowired
  lateinit var repository: UserRepository
  
  fun selectAll(): Lise<User> = repository.findAll(Sort(Sort.Direction.ASC, "id"))
  
  fun selectFromName(name: String): List<User> = repository.findByName(name)
}
```

こんな感じで書いてあげる。`findAll()`メソッドは`JpaRepository`に最初から何も書かずとも生えてるので追加しなくてもOK。  
このサービスでの`selectAll()`は`findAll()`したものをid昇順でソートしてControllerに渡すように書いている。  
`@Autowired`を書いておけば依存注入を勝手にいい感じにやってくれる。あまりにもいい感じにやってくれすぎててこわい。  
  
### Controller
最後にこれを作るとjsonを吐くAPIの完成
上で書いたようなControllerを作ってあげればよい。  

```kotlin
@RestController
@RequestMapping("/user")
class UserController {
  
  @Autowired
  lateinit var service: UserService
  
  @RequestMapping("/all", arrayOf(RequestMethod.GET))
  fun selectAll(): List<User> = service.selectAll()
  
  @RequestMapping("/name", arrayOf(RequestMethod.GET))
  fun selectFronName(@RequestParam("name")name: String): List<User> = service.selectFromName(name)
}
```

こんな感じ。  
最初のサンプルでは使わなかったが、クラスに`@RequestMapping`アノテーションを付けると、そのクラスがそのパスにマッピングされる。  
なので`/user/all`が`fun selectAll()`にマッピングされていることになる。  
  
GETでのリクエストパラメータを受け取りたいときは、メソッドの引数に`@RequestParam("パラメータ名")変数名: 型`を書いてあげればOK。  

上記のコントローラーを作れば   

`localhost:8080/user/all`  
`localhost:8080/user/name?name="なまえ"` 

でGETするといい感じにDBに入っているデータが適切に取れる。  

## まとめ
さくっととは言い難いかもしれないが、Kotlinを使っていい感じにAPIアプリケーションを作ることが出来た。  
Androidアプリを業務趣味問わずKotlinで書いてる人でAPIが欲しい！って思ったらさくっと作れるのではなかろうか。試してみて欲しい（自分はやってる）。  
  
さくっと作るというと[Kotlin/ktor](https://github.com/Kotlin/ktor)のほうが適していると思うので、こちらもそのうちやってみてまとめようと思う。