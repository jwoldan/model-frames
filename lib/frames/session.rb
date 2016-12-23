require 'json'

class Session

  def initialize(req)
    cookie = req.cookies['_model_frames']
    @session = cookie ? JSON.parse(cookie) : {}
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  def store_session(res)
    res.set_cookie('_model_frames', value: @session.to_json, path: '/')
  end
end
