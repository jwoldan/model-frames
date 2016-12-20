require 'byebug'

class Static

  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    @path_info = env["PATH_INFO"]
    match = @path_info.match(/^\/public\/(.*)$/)
    if match
      begin
        static_file_content = File.read("public/#{match[1]}")
        extension = match[1].match(/\..*$/)

        case extension
        when '.jpg', '.jpeg'
          content_type = 'image/jpeg'
        when '.png'
          content_type = 'image/png'
        when '.gif'
          content_type = 'image/gif'
        when '.htm', '.html'
          content_type = 'text/html'
        else
          content_type = 'text/plain'
        end

        ['200', { 'Content-type' => content_type }, static_file_content]
      rescue Errno::ENOENT => e
        erb = ERB.new(File.read("lib/templates/file_not_found.html.erb"))
        ['404', { 'Content-type' => 'text/html' }, [erb.result(binding)]]
      end
    else
      app.call(env)
    end
  end
end
