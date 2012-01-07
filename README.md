muzang-plugins
==============

Official plugins for [muzang](http://github.com/LTe/muzang)

[![BuildStatus](http://travis-ci.org/LTe/muzang-plugins.png)](http://github.com/LTe/muzang-plugins)

Helpers
=======

You can use helpers. Just include module.

```ruby
class PluginClass
  include Muzang::Plugins::Helpers
end
```

After that you can use methods **on_channel**, **on_join**, **match**.

* on_join(connnection, message)
* on_channel(message)
* match(message, regexp)

```ruby
class PluginsClass
 include Muzang::Plugins::Helpers

  def initialize(bot)
    @bot = bot
  end

  def call(connnection, message)
    on_join(connnection, message) do
      connnection.msg(message.channel, "Hello guys!")
    end

    on_channel(message) do
      connnection.msg(message.channel, "Pong: #{message.message}")

      match(message, /^bot/) do |match|
        contributed.msg(message.channel, "Match! #{match[0]}"
      end
    end
  end
```


Plugins
=======

## Eval
Eval ruby code directly on IRC channel (with safe mode)

```
<LTe> % 2+2
<Muzang> 4
```

## LiveReload
Reload plugins without reset bot

```
<LTe> !reload
<Muzang> Reloading: PluginClass
```

## Meme
Create meme from IRC channel

```
<LTe> meme
<Muzang> Type 'meme [name of meme] "Text0" "Text1"'
<Muzang> Available memes: idont yuno orly suc all
<LTe> meme yuno "Y U no" "Something"
<Muzang> http://memegenerator/image/directly/link
```

## Motd
Send message on join

```
* muzangs has joined to #test
<Muzang> Muzang | Version: 1.0.1 | Plugins: *Motd*
```

## Nerdpursuit
Frontend for [nerdpursuit](https://github.com/Nerds/NerdPursuit)

```
<LTe> !quiz
<Muzang> Quiz time!
<Muzang> Category: css
<Muzang> Question: What is the hexadecimal code for red?
<Muzang> Answer 1: ff0000
<Muzang> Answer 2: 00ff00
<Muzang> Answer 3: 0000ff
<Muzang> Answer 4: f0000f
<LTe> 1
<Muzang> Right answer: 1
<Muzang> The winner is... LTe
```

## Plusone
Fight for +1 on the channel

```
<LTe> other_user: +1 for something
<Muzang> LTe gave +1 for *other_user*
<LTe> !stats
<Muzang> *LTe* 5 | *other_user* 1
```

## Reddit
Fetch rss for ruby stuff and print to channel

```
<Muzang> GemStats.org - help the community by sharing your gem data | http://www.reddit.com/r/ruby/comments/kt7sq/gemstatsorg_help_the_community_by_sharing_your/
```

## RubyGems
Watch the gems and notify when new version comes out

```
<LTe> watch! rails
<Muzang> I added gem rails to watchlist
<Muzang> Current version: 3.1.1
...
<Muzang> New version of rails (4.0.0)
````

Contributing to muzang-plugins
==============================
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2011 Piotr Niełacny. See LICENSE.txt for
further details.

