# blog
[やぎ小屋](http://blog.yagi2.com)

# memo
## 記事を追加する時
`git checkout -b article/ARTICLE_TITLE`  
`bundle exec middleman article "ARTICLE_TITLE"`

# 書き終わったら
`bundle exec middleman build` 

# サーバへのrsync
`$ rsync -rltgoDvzO --no-p --iconv=UTF8-MAC,UTF-8 --del -e "ssh -p [PORT] -i [PUBLIC_KEY]" build [USER]@[HOST]:/path/to/document/root/` 