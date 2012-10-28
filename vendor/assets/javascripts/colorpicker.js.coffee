class Color

  constructor: (values={}) ->
    if typeof values is 'object'
      if values.r? and values.g? and values.b?
        return @fromRGB values.r, values.g, values.b 
    else if typeof values is 'string'
      return @fromHex values
    @h = values.h || 0
    @s = values.s || 0
    @b = values.b || 0

  toHex: ->
    rgb = @toRGB()
    hex = [
      rgb.r.toString(16)
      rgb.g.toString(16)
      rgb.b.toString(16)
    ]
    for h, i in hex when h.length is 1
      hex[i] = "0#{h}"
    hex.join ''

  toRGB: ->
    rgb = {}
    h = Math.round @h
    s = Math.round @s * 255 / 100
    v = Math.round @b * 255 / 100

    if s is 0
      { r: Math.round(v), g: Math.round(v), b: Math.round(v) }
    else
      t1 = v
      t2 = (255 - s) * v / 255
      t3 = (t1 - t2) * (h % 60) / 60
      h = 0 if h is 360

      return { r: Math.round(t1),      g: Math.round(t2 + t3), b: Math.round(t2) }       if h < 60
      return { r: Math.round(t1 - t3), g: Math.round(t1),      b: Math.round(t2) }       if h < 120
      return { r: Math.round(t2),      g: Math.round(t1),      b: Math.round(t2 + t3) }  if h < 180
      return { r: Math.round(t2),      g: Math.round(t1 - t3), b: Math.round(t1) }       if h < 240
      return { r: Math.round(t2 + t3), g: Math.round(t2),      b: Math.round(t1) }       if h < 300
      return { r: Math.round(t1),      g: Math.round(t2),      b: Math.round(t1 - t3) }  if h < 360
      { r: 0, g: 0, b: 0 }

  fromRGB: (r, g, b) ->
    if typeof r is "object"
      b = r.b
      g = r.g
      r = r.r
    min = Math.min r, g, b
    max = Math.max r, g, b
    delta = max - min
    @h = -1
    @s = 0
    @b = max

    @s = 255 * delta / max if max isnt 0 
    if @s isnt 0
      @h = 4 + (r - g) / delta      
      @h = (g - b) / delta      if r is max
      @h = 2 + (b - r) / delta  if g is max    
    @h *= 60
    @h += 360 if @h < 0
    @s *= 100 / 255
    @b *= 100 / 255
    @

  fromHex: (hex) ->
    hex = if hex[0] is "#" then hex.slice 1 else hex
    hex = parseInt hex, 16
    rgb = 
      r: hex >> 16
      g: (hex & 0x00FF00) >> 8
      b: hex & 0x0000FF
    @fromRGB rgb

window.Color = Color

class ColorPicker
  
  ColorPicker.tmpl = """
    <div class="colorpicker">
      <div class="colorpicker_color">
        <div/>
      </div>
      <div class="colorpicker_hue">
        <div/>
      </div>
    </div>
  """

  constructor: (@elem, @options={}) ->
    @color = new Color @options.color
    @view = $(ColorPicker.tmpl)

    @elems = 
      frame:        @view
      color:        $(".colorpicker_color", @view)
      hue:          $(".colorpicker_hue", @view)
      color_cursor: $(".colorpicker_color>div", @view)
      hue_cursor:   $(".colorpicker_hue>div", @view)

    _this = @
    $(document).bind "click", (e) => @hide()
    $(@elem).click ->
      _this.show() if $(this).html() is ""
      false
    

    @update()

  show: ->
    @elem.html @view
    @elems["color"].bind "mousedown", (e) => @selectorEdition = yes
    @elems["color"].bind "mousemove", (e) => @selectorMove e
    @elems["color"].bind "mouseup",   (e) => @selectorMove(e); @selectorEdition = no

    @elems["hue"].bind "mousedown",   (e) => @hueEdition = yes
    @elems["hue"].bind "mousemove",   (e) => @hueMove e
    @elems["hue"].bind "mouseup",     (e) => @hueMove(e); @hueEdition = no

    @canvas ||= {}

    @size = @elems["color"].height()
    @initializeColor()
    @initializeHue()
    @update()

    false

  hide: ->
    @elem.html ""

  initializeHue: ->
    @canvas["hue"] ||= @createCanvas 20, @size, @elems["hue"]
    ctx = @canvas["hue"]
    c = new Color h: null, s: 100, b: 100
    for i in [0..@size] by 1
      h = parseInt(360 * (@size - i) / @size)
      c.h = h
      ctx.fillStyle = "##{c.toHex()}"
      ctx.fillRect 0, i, 20, 1

  initializeColor: ->
    @canvas["color"] ||= @createCanvas @size, @size, @elems["color"]
    @img = @canvas["color"].createImageData @size, @size
    @updateColor()    

  updateColor: ->
    color = new Color h: @color.h
    for y in [0..@size] by 1
      for x in [0..@size] by 1
        i = (@size * y + x) * 4
        s = 100 * x / @size
        b = 100 * (@size - y) / @size
        color.s = s
        color.b = b
        rgb = color.toRGB()
        @img.data[i]   = rgb.r
        @img.data[i+1] = rgb.g
        @img.data[i+2] = rgb.b
        @img.data[i+3] = 255
    @canvas["color"].putImageData @img, 0, 0

  createCanvas: (width, height, container) ->
    canvas = $("<canvas/>")
    canvas.attr
      height: height
      width: width
    container.append canvas
    canvas[0].getContext "2d"


  update: ->
    @elems["color_cursor"].css
      left: parseInt @size * @color.s / 100, 10
      top:  parseInt @size * (100 - @color.b) / 100, 10
    @elems["hue_cursor"].css
      top: parseInt @size - @size * @color.h / 360, 10
    
    @options.onChange @color if @options.onChange
    
  selectorMove: (e) ->
    return unless @selectorEdition
    x = e.pageX - @elems["color"].offset().left
    y = e.pageY - @elems["color"].offset().top

    @color.b = parseInt 100 * (@size - y) / @size, 10
    @color.s = parseInt 100 * x / @size, 10
    @update()

  hueMove: (e) ->
    return unless @hueEdition
    y = e.pageY - @elems["color"].offset().top

    @color.h = parseInt 360 * (@size - Math.max(0, Math.min(@size, y))) / @size, 10
    @updateColor()
    @update()



window.ColorPicker = ColorPicker