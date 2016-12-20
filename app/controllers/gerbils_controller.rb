require_relative '../../lib/frames/frames_controller'
require_relative '../models/gerbil'

class GerbilsController < FramesController

  def new
    render :new
  end

  def create
    @gerbil = Gerbil.new(
      name: params['gerbil']['name'],
      color: params['gerbil']['color'],
      sound: params['gerbil']['sound']
    )

    @gerbil.save
    redirect_to "/gerbils/#{@gerbil.id}"
  end

  def index
    @gerbils = Gerbil.all

    render :index
  end

  def show
    @gerbil = Gerbil.find(params['gerbil_id'])

    render :show
  end

  def destroy
    @gerbil = Gerbil.find(params['gerbil_id'])
    @gerbil.destroy

    redirect_to '/'
  end

end
