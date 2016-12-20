require 'erb'

class ExceptionsServer

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    app.call(env)    
  rescue => e
    render_exception(e)
  end

  private

  def render_exception(e)
    @error = e
    @source_lines = get_source_code_snippet(e)

    erb = ERB.new(File.read("lib/templates/rescue.html.erb"))
    ['500', { 'Content-type' => 'text/html' }, [erb.result(binding)]]
  end

  def get_source_code_snippet(e)
    first_backtrace_line = e.backtrace[0].split(':')
    source_code = File.readlines(first_backtrace_line[0])
    snippet_index = first_backtrace_line[1].to_i - 5
    snippet_index = 0 if snippet_index < 0
    snippet_end = snippet_index + 11

    source_lines = []
    while (snippet_index < snippet_end) &&
        (snippet_index < source_code.length)
      source_lines << "#{snippet_index}: #{source_code[snippet_index]}"
      snippet_index += 1
    end
    source_lines
  end

end
