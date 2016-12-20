require 'json'

class Session

  def initialize(req)
    cookie = req.cookies['_rails_lite_app']
    @session = cookie ? JSON.parse(cookie) : {}
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  def store_session(res)
    res.set_cookie('_rails_lite_app', value: @session.to_json, path: '/')
  end
end
