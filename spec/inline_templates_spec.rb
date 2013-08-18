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
  end
end
