# Colorpicker

Add a simple canvas color picker for your rails projects

![screen](http://i49.tinypic.com/ekrdjc.png)

## Installation

Add this line to your application's Gemfile:

    gem 'colorpicker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install colorpicker

## Usage

You can simply add the following lines:

in application.js

    //= require colorpicker

and in application.css

    *= require colorpicker

Now you are able to use the colorpicker 

    options = {
        trigger_event: "click",
        color: {
            r: 0,
            g: 0,
            b: 0
        },
        onChange: function(colorHSB) {
            // do stuff with color
            console.log(colorHSB.toRGB());
            console.log(colorHSB.toHex());
        }
    }
    new ColorPicker($("#myElemToClick"), options);

That's all, every times you will click on your elem with id myElemToClick, the color picker will be display bellow.
Of course options are optional and color can be gave with rgb map or hsb map or hex string.

Hope you will enjoy it ;)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
