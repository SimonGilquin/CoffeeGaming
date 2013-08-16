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
canvas.width = window.innerWidth
canvas.height = window.innerHeight
document.body.appendChild canvas
context = canvas.getContext '2d'
enableLog(context) if debug
surface = null

createSurface = ->
  surface =
      width: 4000
      height: 3000
      context: context

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
    @resumeButton = new Button(canvas.width / 2 - 80, 320, 160, 40).withText('Resume...', '#fff', 28)
  drawElement: (x, y) ->
    if @background?
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
    @pauseScreen = new Screen @x, @y, @w, @h, 'rgba(0,0,0,0.05)' #'#eee'
    @pauseButton = new Button(canvas.width-40, 10, 20, 20).withImage('pause.png')
    delete @background

class Asteroid
  constructor: (posX = 100, posY = 40, @vector) ->
    unless @vector?
      @vector =
        x: 0
        y: 0
    @position =
      x: posX
      y: posY
  @image: (->
    tempCanvas = document.createElement 'canvas'
    tempCanvas.width = 20
    tempCanvas.height = 20
    tempContext = tempCanvas.getContext '2d'
    tempContext.translate(10, 10)
    tempContext.beginPath()
    tempContext.fillStyle = '#ccc'
    tempContext.moveTo -10, -10
    tempContext.lineTo -5, -5
    tempContext.lineTo 0, -10
    tempContext.lineTo +5, -10
    tempContext.lineTo +10, -5
    tempContext.lineTo +5, +5
    tempContext.lineTo +10, +10
    tempContext.lineTo +5, +10
    tempContext.lineTo 0, +5
    tempContext.lineTo -5, +10
    tempContext.lineTo -10, 0
    tempContext.lineTo -5, -5
    tempContext.lineTo -10, -10
    tempContext.fill()
    tempContext.getImageData(-10, -10, 20, 20)
    url = tempCanvas.toDataURL()
    image = new window.Image()
    image.src = url
    image)()
  direction:
    x: 1
    y: 0
  position:
    x: 100
    y: 40
  drawAt: (x, y)->
    drawnAt =
      x: @position.x - x
      y: @position.y - y
    #context.drawImage game.images['asteroid.png'], @position.x, @position.y
    #if 0 < @position.x < canvas.width and 0 < @position.y < canvas.height
    context.drawImage Asteroid.image, drawnAt.x, drawnAt.y
  xdraw: ->
    context.beginPath()
    context.fillStyle = '#ccc'
    context.moveTo @position.x-10, @position.y-10
    context.lineTo @position.x-5, @position.y-5
    context.lineTo @position.x, @position.y-10
    context.lineTo @position.x+5, @position.y-10
    context.lineTo @position.x+10, @position.y-5
    context.lineTo @position.x+5, @position.y+5
    context.lineTo @position.x+10, @position.y+10
    context.lineTo @position.x+5, @position.y+10
    context.lineTo @position.x, @position.y+5
    context.lineTo @position.x-5, @position.y+10
    context.lineTo @position.x-10, @position.y
    context.lineTo @position.x-5, @position.y-5
    context.lineTo @position.x-10, @position.y-10
    context.fill()

createAsteroidStore = ->
  asteroids = []
  asteroids.create = (args...) ->
    asteroid = new Asteroid args...
    @push asteroid
    asteroid
  asteroids.randomFill = ->

    for i in [0...16]
      for j in [0...12] when not ((i == 7 or i == 8) and (j == 5 or j == 6))
        orientation = 2*Math.random()*Math.PI
        speed = Math.random() + 1
        vector =
          x: Math.cos(orientation) * speed
          y: Math.sin(orientation) * speed
        pos =
          x: (i + Math.random()) * game.engine.surface.width / 16
          y: (j + Math.random()) * game.engine.surface.height / 12
        asteroids.create pos.x, pos.y, vector
    asteroids

  asteroids
translate = (rad, x, y) ->
  x: Math.cos(rad) * x - Math.sin(rad) * y
  y: Math.sin(rad) * x + Math.cos(rad) * y
class Vessel
  constructor: (x, y) ->
    @acceleration = .1
    @position =
      x: x or surface.width / 2
      y: y or surface.height / 2
    @rotationalSpeed = .1
    @orientation = 0
    @vector =
      x: 0
      y: 0
  drawAt: (x, y)->
    context.beginPath()
    context.fillStyle = '#f00'
    points = []
    points.push x:5 , y:0
    points.push x:-5, y:5
    points.push x:-2, y:0
    points.push x:-5, y:-5
    points.push x:5 , y:0
    for point in points
      t = translate @orientation, point.x, point.y
      point.x = t.x + @position.x - x
      point.y = t.y + @position.y - y
    context.moveTo points[0].x, points[0].y
    context.lineTo(point.x, point.y) for point in points[1..]
    context.fill()

keymap =
  37: 'left'
  38: 'thrust'
  39: 'right'
  27: 'escape'

class Engine
  constructor: ->
    @hud = new Hud()
    @asteroids = createAsteroidStore()
    @vessel = new Vessel()
    keyboard = {}
    for code, key of keymap
      keyboard[key] = false
    @keyboard = keyboard
    @viewport =
      x: @surface.width / 2 - canvas.width / 2
      y: @surface.height / 2 - canvas.height / 2
      width: canvas.width
      height: canvas.height
      draw: ->
        context.clearRect 0, 0, canvas.width, canvas.height
        @x = game.engine.vessel.position.x - canvas.width / 2
        @y = game.engine.vessel.position.y - canvas.height / 2
        context.drawImage game.images['space.jpg'], @x, @y, @width, @height, 0, 0, surface.width, surface.height

        asteroid.drawAt(@x, @y) for asteroid in game.engine.asteroids
        game.engine.vessel.drawAt @x, @y
        game.engine.hud.draw()

  running: null
  counters:
    start: Date.now()
    frames: 0
    add: ->
      countersElement = document.createElement 'div'
      countersElement.setAttribute 'class', 'counters'
      fps = document.createElement 'p'
      fps.innerHTML = 'FPS: '
      fpsValue = document.createElement 'span'
      fpsValue.setAttribute 'class', 'fps'
      fps.appendChild fpsValue
      countersElement.appendChild fps
      updateTime = document.createElement 'p'
      updateTime.innerHTML = 'Update: '
      updateTimeValue = document.createElement 'span'
      updateTimeValue.setAttribute 'class', 'time'
      updateTime.appendChild updateTimeValue
      countersElement.appendChild updateTime
      drawTime = document.createElement 'p'
      drawTime.innerHTML = 'Draw: '
      drawTimeValue = document.createElement 'span'
      drawTimeValue.setAttribute 'class', 'time'
      drawTime.appendChild drawTimeValue
      countersElement.appendChild drawTime
      document.body.appendChild countersElement

      fpsValue.lastUpdate = performance.now()
      fpsValue.lastFrameCount = 0
      oldUpdate = game.engine.update
      oldDraw = game.engine.draw
      game.engine.update = =>
        updateStart = performance.now()
        oldUpdate()
        updateTimeValue.innerHTML = Math.round performance.now() - updateStart
      game.engine.draw = =>
        drawStart = performance.now()
        oldDraw()
        endLoop = performance.now()
        drawTimeValue.innerHTML = Math.round endLoop - drawStart
        @frames++
        if endLoop - fpsValue.lastUpdate > 250
          fpsValue.innerHTML = @fps = Math.round((@frames - fpsValue.lastFrameCount) * 1000 / (endLoop - fpsValue.lastUpdate))
          fpsValue.lastUpdate = endLoop
          fpsValue.lastFrameCount = @frames
        @lastUpdate = endLoop
  cursor:
    x: null
    y: null
  createVessel: (args...)->
    new Vessel args...
  surface: createSurface()
  mainLoop: =>
    @update()
    @draw()
    #@counters.update?()
  draw: => @viewport.draw()
  init: ->
    @counters.add() if performance?.now?
    #setInterval @mainLoop, 1000/60
    animFrame = window.requestAnimationFrame
    window.webkitRequestAnimationFrame unless animFrame?
    window.mozRequestAnimationFrame unless animFrame?
    window.oRequestAnimationFrame unless animFrame?
    window.msRequestAnimationFrame unless animFrame?
    if animFrame?
      recursive = =>
        @mainLoop()
        animFrame recursive, canvas
      recursive()
    else
      setInterval @mainLoop, 1000/60
    document.onkeydown = (e) =>
      @events.push
        type: 'keydown'
        keyCode: e.keyCode
        action: keymap[e.keyCode]
    document.onkeyup = (e) =>
      @events.push
        type: 'keyup'
        keyCode: e.keyCode
        action: keymap[e.keyCode]
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

    @asteroids.randomFill()
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
        when 'keydown'
          @keyboard[event.action] = true
        when 'keyup'
          @keyboard[event.action] = false
      if @isPaused()
        @play() if @keyboard.escape
        @handleButton @hud.pauseScreen.resumeButton, @play
      else
        @pause() if @keyboard.escape
        @handleButton @hud.pauseButton, @pause
      delete @cursor.type if event.type == 'mouseup'
    unless @isPaused()
      @updateAsteroids()
      @updateVessel @vessel

  updateVessel: (vessel) ->
    vessel.position.x += vessel.vector.x
    vessel.position.x = 0 if vessel.position.x > game.engine.surface.width
    vessel.position.x = game.engine.surface.width if vessel.position.x < 0
    vessel.position.y += vessel.vector.y
    vessel.position.y = 0 if vessel.position.y > game.engine.surface.height
    vessel.position.y = game.engine.surface.height if vessel.position.y < 0
    vessel.thrust = @keyboard['thrust']
    if vessel.thrust
      vessel.vector.x += Math.cos(vessel.orientation) * vessel.acceleration
      vessel.vector.y += Math.sin(vessel.orientation) * vessel.acceleration
    vessel.orientation -= vessel.rotationalSpeed if @keyboard['left']
    vessel.orientation += vessel.rotationalSpeed if @keyboard['right']
    vessel.orientation = vessel.orientation % (2 * Math.PI)

  updateAsteroids: ->
    for asteroid in @asteroids
      asteroid.position.x += asteroid.vector.x
      asteroid.position.x = 0 if asteroid.position.x > game.engine.surface.width
      asteroid.position.x = game.engine.surface.width if asteroid.position.x < 0
      asteroid.position.y += asteroid.vector.y
      asteroid.position.y = 0 if asteroid.position.y > game.engine.surface.height
      asteroid.position.y = game.engine.surface.height if asteroid.position.y < 0

window.game = game =
  buttons: []
  images:
    'asteroid.png': null
    'space.jpg' : null
  load: ->
    @engine = new Engine()
    counter = 0
    loadImage = (url) =>
      image = new window.Image()
      image.src = "img/#{url}"
      image.onload = =>
        @images[url] = image
        counter--
        if counter == 0
          @engine.init().pause()

    for url of @images
      counter++
      loadImage url
  reset: ->
    delete @engine

game.load()
#game.init().pause()

