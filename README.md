# ModelFrames

ModelFrames is a basic ORM (Object Relational Management) / MVC (Model View Controller) framework written in Ruby and inspired by Ruby on Rails.  `ModelObject` provides the ORM functionality, `FramesController` provides a base controller class, and `Router` provides basic routing capabilities.  

## ModelObject

### Key Features

Custom classes that extend `ModelObject` inherit a number of ORM features:

- parameters can be passed in a params hash (e.g. `gerbil = Gerbil.new(name: 'Buki', color: 'striped', sound: 'squeak')`).  The keys must correspond to columns in the corresponding database table.  By default, the table name is created by applying the [`ActiveSupport::Inflector::tableize`](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-tableize) method to the class name.
- the `ModelObject#save` method will intelligently insert or update the related row in the database based on whether or not the `id` primary key is define.  
- the `ModelObject#destroy` method will delete the related row from the database.
- By calling `self.finalize!` at the end of your custom class definition, attribute accessors are created which correspond to the columns in the associated database table.

### Example Usage

In the example application, gerbil.rb is located in the `app/models` folder:

```ruby
require_relative '../../lib/model/model_object'

class Gerbil < ModelObject
  # no custom methods
  finalize!
end
```

## FramesController

### Key Features

Custom classes that extend `FramesController` can use the following methods:

- `render(template_name)`: Render a template located in the `app/views/<controller_name>` directory.
- `render_content(content, content_type)`: Render custom content with the specified content_type.
- `redirect_to(url)`: Redirect to the passed URL.
- `session`: key/value pairs saved to this hash are saved as cookies.
- `flash` and `flash.now`: key/values pairs saved to this hash will persist through the next session and the current session only, respectively.
- By adding `protect_from_forgery` to your custom controller, Frames will check for an authenticity token in any submitted data.  This token can be added to the forms in your views as follows:

```html
<input
  type="hidden"
  name="authenticity_token"
  value="<%= form_authenticity_token %>" />
```

### Example Usage

In the example application, gerbils_controller.rb is located in the `app/controllers` folder:

```ruby
require_relative '../../lib/frames/frames_controller'
require_relative '../models/gerbil'

class GerbilsController < FramesController

  protect_from_forgery

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

  ...

end
```

## Router

The `Router` allows the mapping of routes to your custom controllers.  For example:

```ruby
require_relative '../lib/frames/router'

router = Router.new
router.draw do
  get Regexp.new("^/gerbils/new$"), GerbilsController, :new
  post Regexp.new("^/gerbils$"), GerbilsController, :create
  get Regexp.new("^/gerbils/(?<gerbil_id>\\d+)$"), GerbilsController, :show
  delete Regexp.new("^/gerbils/(?<gerbil_id>\\d+)$"),
         GerbilsController, :destroy
  get Regexp.new("^/$"), GerbilsController, :index
end
```

## Additional Rack Middleware

- `Exceptions` provides a detailed error message for any Ruby errors, which is useful for development enviroments.

- `StaticAssets` allows the serving of static assets from the `/public` folder.  Currently supported extensions are .jpg, .png, .gif, and .htm/.html.  All other extensions are served as plain text.

## Putting it All Together

See [app/gerbilville.rb](app/gerbilville.rb) for an example application entry file.


## Running the Example app

### Prerequisites

Up-to-date versions of [Ruby](https://www.ruby-lang.org/en/) and [Bundler](http://bundler.io)

1. `git clone https://github.com/jwoldan/model-frames.git`
2. `cd model-frames`
3. `bundle install`
4. `ruby app/gerbilville.rb`
4. Visit `http://localhost:3000`
