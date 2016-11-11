# activerecord-oracle_enhanced-adapter-monky_patch_755 [![Gem Version](https://badge.fury.io/rb/activerecord-oracle_enhanced-adapter-monky_patch_755.svg)](http://badge.fury.io/rb/activerecord-oracle_enhanced-adapter-monky_patch_755)

A monkey patch for oracle-enhanced ISSUE [#755](https://github.com/rsim/oracle-enhanced/issues/755).

**ISSUE #755 has been resolved at activerecord-oracle_enhanced-adapter 1.7.3.**

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'activerecord-oracle_enhanced-adapter-monky_patch_755'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install activerecord-oracle_enhanced-adapter-monky_patch_755
```

## Target

* 'activerecord', '>= 4.2.1'
* 'activerecord-oracle_enhanced-adapter', '>= 1.6.0'

## Motivation

This library is bound to solve this problem in Rails 4.2.x with Oracle.

```ruby
> created_at = Model.first.created_at
> Model.where(created_at: created_at)
  => []
```

Above is not expected. This library will apply a patch as a following behavior.

```ruby
> created_at = Model.first.created_at
> Model.where(created_at: created_at)
  => [#<Model id: ***snip***>]
```

To explain this a little further: oracle-enhanced ISSUE [#755](https://github.com/rsim/oracle-enhanced/issues/755).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

activerecord-oracle_enhanced-adapter-monky_patch_755 is released under the [MIT License](http://www.opensource.org/licenses/MIT).
