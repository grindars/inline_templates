# Inline Templates

Inline Templates allow you to write HTML markup in your controllers just like arbre, but without its inherent incompatibilities. All helpers - Rails builtin, provided by other gems and yours - are available out of box.

For example:
```ruby
@inline_html = rit do
  ~ form_for(:session) do |f|
    ~ div(class: "fields") do
      ~ div(class: "field") do
        ~ f.label(:email, 'E-Mail')
        ~ f.text_field(:email)
      end
      ~ div(class: "field") do
        ~ f.label(:password, 'Password')
        ~ f.password_field(:password)
      end
    end

    ~ div(class: "actions") do
      ~ f.submit
    end
  end
end



Sponsored by [Evil Martians](http://evilmartians.com/).

## Installation

Add this line to your application's Gemfile:

    gem 'inline_templates'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inline_templates

## Usage

In Rails controllers:
```ruby
class TestController < ApplicationController
  include InlineMarkup::Helpers

  def test
    @inline_html = rit(:list => [ 'a', 'b', 'c' ]) do
      ~ ul do
        list.each do |item|
          ~ li(item)
        end
      end
    end
```

Standalone:
```ruby
view = ActionView::Base.new context, assigns, controller, formats
inline_html = InlineTemplates.render view, details, locals do
  ~ t('foo')
end
````

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
