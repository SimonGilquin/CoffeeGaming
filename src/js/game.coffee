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
        game.hud.draw()

class Drawable
  drawFrom: (x, y) ->
    @drawElement? x, y
    @drawChildrenFrom @x+x, @y+y
  drawChildrenFrom: (x, y) ->
    for id, elem of @
      elem.drawFrom? x, y

class Text extends Drawable
  constructor: (@text, @style = 'black', size = 12, @x=0, @y=0) ->
    @font = "#{size}px sans-serif"
  drawElement: (x, y)->
    context.textBaseline = 'middle'
    context.textAlign = 'center'
    context.fillStyle = @style
    context.font = @font
    context.fillText @text, @x+x, @y+y

class Button extends Drawable
  constructor: (@x, @y, @w, @h, @color = 'black') ->
  drawElement: (x, y)->
    context.fillStyle = @color
    context.fillRect @x+x, @y+y, @w, @h
  withText: (args...) ->
    @content = new Text args...
    @content.x = @w/2
    @content.y = @h/2
    @

class Screen extends Drawable
  visible: false
  constructor: (@x, @y, @w, @h, @background) ->
    @text = new Text 'Game paused', 'black', 48, canvas.width/2, 280
    @resumeButton = new Button(420, 320, 160, 40, '#00aaaa').withText('Resume...', '#fff', 28)
  drawElement: (x, y) ->
    if @visible
      context.fillStyle = @background
      context.fillRect x+@x, y+@y, canvas.width, canvas.height
      @drawChildrenFrom @x+x, @y+y
  draw: ->
    @drawElement @x, @y

class Hud extends Screen
  x: 0
  y: 0
  w: canvas.width
  h: canvas.height
  visible: true
  constructor: ->
    @pauseScreen = new Screen @x, @y, @w, @h, '#eee'

createGame = ->
  running = null
  surface: createSurface 800, 600
  hud: new Hud()
  init: ->
    setInterval @surface.draw, 1000/60
    canvas.onmousemove = (e) =>
      @events.push
        type: 'mousemove'
        x: e.offsetX
        y: e.offsetY
    @
  pause: ->
    running = false
    @hud.pauseScreen.visible = true
  play: -> running = true
  isPaused: -> return not running
  events: []
  update: ->
#    if @isPaused()
#      if @hud.pauseScreen.resumeButton

window.game = game = createGame()

game.init().pause()

