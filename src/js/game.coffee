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

createHud = ->
  drawPauseScreen = ->
    context.fillStyle = '#eee'
    context.fillRect 0, 0, canvas.width, canvas.height
    context.fillStyle = 'black'
    context.textBaseline = 'middle'
    context.textAlign = 'center'
    context.font = '48px sans-serif'
    context.fillText 'Game paused', canvas.width / 2, 280
    context.fillStyle = '#00aaaa'
    context.fillRect 420, 320, 160, 40
    context.fillStyle = 'ffffff'
    context.font = '28px sans-serif'
    context.fillText 'Resume...', canvas.width / 2, 340

  draw: ->
    drawPauseScreen() if game.isPaused()

createGame = ->
  running = null
  surface: createSurface 800, 600
  hud: createHud()
  init: ->
    setInterval @surface.draw, 1000/60
  pause: -> running = false
  play: -> running = true
  isPaused: -> return not running

window.game = game = createGame()

game.init()

