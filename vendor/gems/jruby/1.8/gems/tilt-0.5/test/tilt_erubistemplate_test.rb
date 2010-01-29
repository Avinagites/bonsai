require 'contest'
require 'tilt'

begin
  require 'erubis'
  class ErubisTemplateTest < Test::Unit::TestCase
    test "registered for '.erubis' files" do
      assert_equal Tilt::ErubisTemplate, Tilt['test.erubis']
      assert_equal Tilt::ErubisTemplate, Tilt['test.html.erubis']
    end

    test "compiling and evaluating templates on #render" do
      template = Tilt::ErubisTemplate.new { |t| "Hello World!" }
      assert_equal "Hello World!", template.render
    end

    test "passing locals" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= name %>!' }
      assert_equal "Hey Joe!", template.render(Object.new, :name => 'Joe')
    end

    test "evaluating in an object scope" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= @name %>!' }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "Hey Joe!", template.render(scope)
    end

    test "passing a block for yield" do
      template = Tilt::ErubisTemplate.new { 'Hey <%= yield %>!' }
      assert_equal "Hey Joe!", template.render { 'Joe' }
    end

    test "backtrace file and line reporting without locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?<
      template = Tilt::ErubisTemplate.new('test.erubis', 11) { data }
      begin
        template.render
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of NameError, boom
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        assert_equal 'test.erubis', file
        assert_equal '13', line
      end
    end

    test "backtrace file and line reporting with locals" do
      data = File.read(__FILE__).split("\n__END__\n").last
      fail unless data[0] == ?<
      template = Tilt::ErubisTemplate.new('test.erubis', 1) { data }
      begin
        template.render(nil, :name => 'Joe', :foo => 'bar')
        fail 'should have raised an exception'
      rescue => boom
        assert_kind_of RuntimeError, boom
        line = boom.backtrace.first
        file, line, meth = line.split(":")
        assert_equal 'test.erubis', file
        assert_equal '6', line
      end
    end

    test "erubis template options" do
      template = Tilt::ErubisTemplate.new(nil, :pattern => '\{% %\}') { 'Hey {%= @name %}!' }
      scope = Object.new
      scope.instance_variable_set :@name, 'Joe'
      assert_equal "Hey Joe!", template.render(scope)
    end
  end
rescue LoadError => boom
  warn "Tilt::ErubisTemplate (disabled)\n"
end

__END__
<html>
<body>
  <h1>Hey <%= name %>!</h1>


  <p><% fail %></p>
</body>
</html>
