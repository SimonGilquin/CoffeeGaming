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

drawChildrenFrom = (x, y) ->
  for id, elem of @
    elem.drawFrom? x, y

createText = (text, style = 'black', size = 12, x=0, y=0) ->
  drawFrom = (x, y)->
    context.textBaseline = 'middle'
    context.textAlign = 'center'
    context.fillStyle = @style
    context.font = @font
    context.fillText @text, @x+x, @y+y
  if typeof text == 'object'
    text.drawFrom = drawFrom
  else
    text: text
    style: style
    font: "#{size}px sans-serif"
    x: x
    y: y
    drawFrom: drawFrom

createButton = (x, y, w, h, color = 'black') ->
  drawChildrenFrom: drawChildrenFrom
  drawFrom: (x, y)->
    context.fillStyle = @color
    context.fillRect @x+x, @y+y, @w, @h
    @drawChildrenFrom @x+x, @y+y

  color: color
  x: x
  y: y
  w: w
  h: h
  withText: (args...) ->
    @content = createText args...
    @content.x = w/2
    @content.y = h/2
    @

createHud = ->
  x: 0
  y: 0
  w: canvas.width
  h: canvas.height
  drawChildrenFrom: drawChildrenFrom
  draw: ->
    @drawChildrenFrom @x, @y
  pauseScreen:
    visible: false
    text: createText 'Game paused', 'black', 48, canvas.width/2, 280
    resumeButton: createButton(420, 320, 160, 40, '#00aaaa').withText('Resume...', '#fff', 28)
    drawChildrenFrom: drawChildrenFrom
    x: 0
    y: 0
    drawFrom: (x, y) ->
      if @visible
        context.fillStyle = '#eee'
        context.fillRect x+@x, y+@y, canvas.width, canvas.height
        @drawChildrenFrom @x+x, @y+y

createGame = ->
  running = null
  surface: createSurface 800, 600
  hud: createHud()
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

