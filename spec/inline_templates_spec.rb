require 'spec_helper'

describe InlineTemplates do
  describe 'render' do
    it 'builds elements' do
      test_rit do
        ~ span('test')
      end.should == "<span>test</span>"
    end

    it 'builds multiple elements' do
      test_rit do
        ~ span('test 1')
        ~ span('test 2')
      end.should == "<span>test 1</span><span>test 2</span>"
    end

    it 'captures' do
      test_rit do
        ~ div do
          ~ span('test')
        end
      end.should == "<div><span>test</span></div>"
    end

    it 'handles locals and conditionals' do
      locals = {
        :cond => true,
        :a => 'foo',
        :b => 'bar'
      }

      test_block = proc do
        if cond
          ~ a
        else
          ~ b
        end
      end

      test_rit(locals, &test_block).should == "foo"
      locals[:cond] = false
      test_rit(locals, &test_block).should == "bar"
    end

    it 'supports response postprocessing' do
      test_rit do
        e1 = div 'foo'
        e2 = span 'bar'

        ~ (e1 + e2)
      end.should == "<div>foo</div><span>bar</span>"
    end

    it 'properly handles nested blocks' do
      locals = { :list => [ '1', '2', '3', '4' ] }
      test_rit(locals) do
        ~ ul do
          list.each do |item|
            ~ li(item)
          end
        end
      end.should == '<ul><li>1</li><li>2</li><li>3</li><li>4</li></ul>'
    end

    it 'implements t helper' do
      test_rit do
        ~ t('<br />')
      end.should == "&lt;br /&gt;"
    end

    it 'implements h helper' do
      test_rit do
        ~ h('<br />')
      end.should == "<br />"
    end

    it 'passes instance variables' do
      test_rit do
        ~ @virtual_path
      end.should == "(inline)"
    end

    it 'wraps output of builders' do
      test_rit do
        ~ form_for(:foo, :url => "foo", :authenticity_token => false) do |f|
          ~ f.submit
        end
      end.should == "<form accept-charset=\"UTF-8\" action=\"foo\" method=\"post\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div><input name=\"commit\" type=\"submit\" value=\"Save Foo\" /></form>"
    end

    it 'supports instance_exec of blocks' do
      test_class = Class.new do
        def initialize(template, &block)
          @template = template
          @buffer = ""
          instance_exec &block
        end

        def to_s
          @buffer.html_safe
        end

        def foo
          @buffer << "test"
        end

        def bar(&block)
          @buffer << @template.capture('foo', &block)
        end
      end

      test_rit do
        ~ invoke_helper_like_class(test_class) do
          foo
          bar do |arg|
            ~ strong(arg)
          end
        end
      end.to_s.should == 'test<strong>foo</strong>'
    end
  end
end
