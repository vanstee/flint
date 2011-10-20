Flint
=====

A simple Campfire client heavily inspired by the blather gem [https://github.com/sprsquish/blather](https://github.com/sprsquish/blather).

Example
=======

You'll need your campfire token, an account name and a room id. They should look something like this.

```
Token: 92e7c01a6de100b1d4cab81d7fbfa8a2536939ab

Account: tasty-taco-talk

Room ID: 100000
```

Now write this up and run it.

```ruby
require 'rubygems'
require 'flint'

setup '92e7c01a6de100b1d4cab81d7fbfa8a2536939ab', 'tasty-taco-talk', '100000'

ready do
  say 'All hail your taco robot overlord!!!'
end

message :body => /tacos/ do
  say 'BOOM!!! TACOTIME!!!'
end

friday_tacos = lambda do |message|
  message =~ /tacos/ and Date.today.friday?
end

message :body => friday_tacos do
  say 'WOO! TAQUERIA DEL SOL!'
end
```

Reference
=========

Campfire [http://campfirenow.com/](http://campfirenow.com/)

Campfire API [http://developer.37signals.com/campfire/](http://developer.37signals.com/campfire/)

Blather [https://github.com/sprsquish/blather](https://github.com/sprsquish/blather)