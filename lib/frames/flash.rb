require 'json'

class Flash

  def initialize(req)
    flash = req.cookies['_model_frames_flash']
    @flash_now = flash ? JSON.parse(flash) : {}
    @flash = {}
  end

  def [](key)
    # handle both strings and symbols in flash.now,
    # since we can't do an internal conversion to
    # string in the now setter (because we don't have one)
    @flash_now[key.to_s] ||
      @flash_now[key.to_sym] ||
      @flash[key.to_s]
  end

  def []=(key, val)
    @flash[key.to_s] = val
  end

  def now
    @flash_now
  end

  def store_flash(res)
    res.set_cookie('_model_frames_flash', value: @flash.to_json, path: '/')
  end

end
