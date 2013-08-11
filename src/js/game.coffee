debug = false #or true
enableLog = (object) ->
  overload = (name, instance) ->
    old = instance[name]
    instance[name] = (args...) =>
      console.log "#{name}(#{args})"
      old.apply instance, args

  for id, prop of object when typeof prop == 'function'
    overload id, object
  true

canvas = document.createElement 'canvas'
canvas.width = 1001
canvas.height = 601
document.body.appendChild canvas
context = canvas.getContext '2d'
enableLog(context) if debug

createSurface = (width, height) ->
  surface =
      width: width
      height: height
      drawLine: (x1, y1, x2, y2, width = 1) ->
        context.beginPath()
        context.lineWidth = width
        context.moveTo x1+width/2, y1+width/2
        context.lineTo x2+width/2, y2+width/2
        context.stroke()
      context: context
      draw: ->
        context.clearRect 0, 0, canvas.width, canvas.height
        game.engine.hud.draw()

class Drawable
  visible: true
  isInElement: (x, y) ->
    @x <= x <= @x+@w and @y <= y <= @y+@h
  drawFrom: (x, y) ->
    if @visible
      @drawElement? x, y
      @drawChildrenFrom @x+x, @y+y
  drawChildrenFrom: (x, y) ->
    for id, elem of @
      elem?.drawFrom? x, y

class Text extends Drawable
  constructor: (@text, @style = 'black', size = 12, @x=0, @y=0) ->
    @font = "#{size}px sans-serif"
  drawElement: (x, y)->
    context.textBaseline = 'middle'
    context.textAlign = 'center'
    context.fillStyle = @style
    context.font = @font
    context.fillText @text, @x+x, @y+y

class Image extends Drawable
  constructor: (@x, @y, @url)->
    game.images[@url] = null
  drawElement: (x, y) ->
    context.drawImage game.images[@url], @x+x, @y+y if game.images[@url]?

class Button extends Drawable
  color: '#0aa'
  activecolor: '#088'
  hovercolor: '#099'
  getStateColor: ->
    switch @state
      when 'active' then @activecolor
      when 'hover' then @hovercolor
      else @color
  constructor: (@x, @y, @w, @h) ->
    game.buttons.push @
  drawElement: (x, y)->
    context.fillStyle = @getStateColor()
    context.fillRect @x+x, @y+y, @w, @h
  withText: (args...) ->
    @content = new Text args...
    @content.x = @w/2
    @content.y = @h/2
    @
  withImage: (url) ->
    @content = new Image 0, 0, 'pause.png'
    @

class Screen extends Drawable
  visible: false
  constructor: (@x, @y, @w, @h, @background) ->
    @text = new Text 'Game paused', 'black', 48, canvas.width/2, 280
    @resumeButton = new Button(420, 320, 160, 40).withText('Resume...', '#fff', 28)
  drawElement: (x, y) ->
    if @background
      context.fillStyle = @background
      context.fillRect x+@x, y+@y, canvas.width, canvas.height
    @drawChildrenFrom @x+x, @y+y
  draw: ->
    @drawFrom @x, @y

class Hud extends Screen
  x: 0
  y: 0
  w: canvas.width
  h: canvas.height
  visible: true
  constructor: ->
    @pauseScreen = new Screen @x, @y, @w, @h, '#eee'
    @pauseButton = new Button(canvas.width-40, 10, 20, 20).withImage('pause.png')
    delete @background

class Engine
  constructor: ->
    @hud = new Hud()
  running: null
  cursor:
    x: null
    y: null
  surface: createSurface 800, 600
  mainLoop: =>
    @update()
    @surface.draw()
  init: ->
    setInterval @mainLoop, 1000/60
    canvas.onmousemove = (e) =>
      @events.push
        type: 'mousemove'
        x: e.offsetX
        y: e.offsetY
    canvas.onmousedown = (e) =>
      @events.push
        type: 'mousedown'
        x: e.offsetX
        y: e.offsetY
    canvas.onmouseup = (e) =>
      @events.push
        type: 'mouseup'
        x: e.offsetX
        y: e.offsetY
    @
  pause: =>
    @running = false
    @hud.pauseScreen.visible = true
    @hud.pauseButton.visible = false
  play: =>
    @running = true
    @hud.pauseScreen.visible = false
    @hud.pauseButton.visible = true
  isPaused: -> return not @running
  events: []
  handleButton: (button, whenActive) ->
    if button.isInElement @cursor.x, @cursor.y
      if @cursor.state == 'down'
        button.state = 'active'
      else if @cursor.state == 'up' and button.state == 'active'
        whenActive()
        delete button.state
      else
        button.state = 'hover'
    else if button.state == 'hover' or @cursor.state == 'up'
      delete button.state

  update: =>
    while @events.length > 0
      event = @events.shift()
      switch event.type
        when 'mousemove'
          @cursor.x = event.x
          @cursor.y = event.y
        when 'mousedown'
          @cursor.state = 'down'
          @cursor.x = event.x
          @cursor.y = event.y
        when 'mouseup'
          @cursor.state = 'up'
          @cursor.x = event.x
          @cursor.y = event.y
      if @isPaused()
        @handleButton @hud.pauseScreen.resumeButton, @play
      else
        @handleButton @hud.pauseButton, @pause

      delete @cursor.type if event.type == 'mouseup'

window.game = game =
  buttons: []
  images: {}
  load: ->
    @engine = new Engine()
    counter = 0
    for url, image of @images
      counter++
      image = new window.Image()
      image.src = "img/#{url}"
      image.onload = =>
        @images[url] = image
        counter--
        if counter == 0
          @engine.init().pause()

game.load()
#game.init().pause()

