# middleman-blog-bootstrap-template

* This is a [middleman](http://middlemanapp.com) template for bootstrap-based blogs.
* This aims at the easy & speedy blog-building for who don't know much about ruby / middleman.
* Select the themes from [Bootswatch](http://bootswatch.com/), then you can easily build bootstrap-based blogs!
* And it encourages asset management with [Bower](http://github.com/twitter/bower). 

##Features:
* Rendering engine
 - [Markdown](http://daringfireball.net/projects/markdown/) in posts
 - [Slim](http://slim-lang.com/) in layout
* Middleman plugins
 - [middleman-blog](http://github.com/middleman/middleman-blog/)
 - [middleman-livereload](http://github.com/middleman/middleman-livereload)
 - [middleman-target](http://github.com/xunker/middleman-target) 
 - [middleman-deploy](http://github.com/tvaughan/middleman-deploy) config snippet to ease FTP/SFTP deployment
* [Bower](http://github.com/twitter/bower) package management
 - [Normalize.css](http://necolas.github.com/normalize.css) 
 - [Modernizr](http://modernizr.com)
 - [Bootswatch](http://bootswatch.com/)
 - [Font-awesome](http://fontawesome.io/)
 - [jQuery](http://jquery.com/)
 - [Respond.js](http://github.com/scottjehl/Respond)
* [SCSS](http://sass-lang.com)
* [Coffeescript](http://coffeescript.org/)

[Preview](source/images/sample-theme-flatly.png) the sample image which is made in Bootswatch "flatly" theme.

##Installation

1. If you're just getting started, install the `middleman` gem and generate a new project:
1. Download/clone to `.middleman/blog-bootstrap`: 
1. Create your new Middleman project with thie template:
1. Install the assets in the `bower_components/` directory.

```shell
gem install middleman
git clone https://github.com/biblichor/middleman-blog-bootstrap-template.git ~/.middleman/blog-bootstrap
middleman init my_new_project --template=blog-bootstrap
cd my_new_project
bower install
```

##Configuration

###Blog configuration

* Edit `config.rb` as you like.
 - Don't forget to add the site url, author, title, and subtitle(used as description too).
 - To get analytics inclusion, simply add your account name to the appropriate places.
 - To get bootswatch inclusion, simply change `theme_name` to your favorite bootswatch theme.

```ruby:config.rb
set :site_url, 'http://blog.url.com'
set :site_author, 'Blog author'
set :site_title, 'Blog title'
set :site_subtitle, 'Blog subtitle'
# Select the theme from bootswatch.com.
# If false, you can get plain bootstrap style.
# set :theme_name, 'flatly'
set :theme_name, false
# set @analytics_account, like 'XX-12345678-9'
@analytics_account = false
```

###Bower configuration

* With bower, you can prevent unnecessary files being copied over to ```build/```.
* All bower packages are put in the ```bower_components/``` directory outside of the source. 
* By default, these assets are included:
 - [Normalize.css](http://necolas.github.com/normalize.css) 
 - [Modernizr](http://modernizr.com)
 - [Bootswatch](http://bootswatch.com/)
 - [Font-awesome](http://fontawesome.io/)
 - [jQuery](http://jquery.com/)
 - [Respond.js](http://github.com/scottjehl/Respond)
* If you want another assets, edit `bower.json` as you like, and simply ```bower install``` and include it like you would any other file in sprockets.

###SCSS configuration

By default, bootstrap or bootswatch is installed.
You can edit `_settings.scss`, `_imports.scss` as you like.

* any variables (like colors and such) go into _settings.scss
* any packages/imports go into _imports.scss

##Requirements
Confirmed in ruby 2.0.0p247, rubygem 2.0.3, middleman 3.2.2

###Helpers configuration, etc.

* In ```helpers/```, a few helpers are inclueded to help out with organizing the following information on your site.
 - title
 - meta keywords
 - meta description
* ```feed.xml``` and ```sitemap.xml``` enables you to tell your readers / search engines the update of articles.

##Misc
This project is forked from [headcanon's middleman-bower-template](https://github.com/headcanon/middleman-bower-template)  (Big thanks to headcanon). 

All the problems or questions are welcome. And of cource if you have a better idea, give it a fork! 
Thanks!
