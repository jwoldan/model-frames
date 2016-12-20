require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = req.params.merge(params)
    @session = Session.new(req)
    @flash = Flash.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    try_prep_response!
    res.location = url
    res.status = 302
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    try_prep_response!
    res.write(content)
    res.set_header("Content-Type", content_type)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template_path = "views/#{self.class.to_s.underscore}"
    erb = ERB.new(File.read("#{template_path}/#{template_name.to_s}.html.erb"))
    render_content(erb.result(binding), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session
  end

  def flash
    @flash
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end

  private

  def try_prep_response!
    raise "Error: already built response!" if already_built_response?
    session.store_session(res)
    flash.store_flash(res)
    @already_built_response = true
  end

end
