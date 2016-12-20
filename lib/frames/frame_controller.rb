require 'active_support'
require 'active_support/core_ext'
require 'erb'

require_relative 'session'
require_relative 'flash'

class FrameController
  attr_reader :req, :res, :params

  @@protect_from_forgery = false

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = req.params.merge(params)
    @session = Session.new(req)
    @flash = Flash.new(req)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    try_prep_response!
    res.location = url
    res.status = 302
  end

  def render_content(content, content_type)
    try_prep_response!
    res.write(content)
    res.set_header("Content-Type", content_type)
  end

  def render(template_name)
    template_path = "views/#{self.class.to_s.underscore}"
    erb = ERB.new(File.read("#{template_path}/#{template_name}.html.erb"))
    render_content(erb.result(binding), "text/html")
  end

  def session
    @session
  end

  def flash
    @flash
  end

  def invoke_action(name)
    check_authenticity_token if @req.request_method != 'GET'
    send(name)
    render(name) unless already_built_response?
  end

  def form_authenticity_token
    @auth_token ||= SecureRandom::urlsafe_base64
    res.set_cookie(
      'authenticity_token', value: @auth_token, path: "/"
    )
    @auth_token
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    if !@params['authenticity_token'] ||
        @params['authenticity_token'] != @req.cookies['authenticity_token']
      raise "Invalid authenticity token"
    end
  end

  private

  def try_prep_response!
    raise "Error: already built response!" if already_built_response?

    session.store_session(res)
    flash.store_flash(res)
    @already_built_response = true
  end

end
