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
      scale: 1
      draw: ->
        context.clearRect 0, 0, canvas.width, canvas.height
        asteroid.draw() for asteroid in game.engine.asteroids
        game.engine.vessel.draw()
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
  constructor: (posX = 100, posY = 40, vectorX = 1, vectorY = 0, @speed = 1) ->
    @direction =
      x: vectorX
      y: vectorY
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
  speed: 1
  direction:
    x: 1
    y: 0
  position:
    x: 100
    y: 40
  draw: ->
    #context.drawImage game.images['asteroid.png'], @position.x, @position.y
    if 0 < @position.x < canvas.width and 0 < @position.y < canvas.height
      context.drawImage Asteroid.image, @position.x, @position.y
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

    for i in [0...20]
      for j in [0...15] when not ((i == 9 or i == 10) and j == 7)
        vector = 2*Math.random()*Math.PI
        pos =
          x: (i + Math.random()) * canvas.width / 4 - 2 * canvas.width
          y: (j + Math.random()) * canvas.height / 3 - 2 * canvas.height
        asteroids.create pos.x, pos.y, Math.cos(vector), Math.sin(vector), Math.random() + 1
    asteroids

  asteroids
translate = (rad, x, y) ->
  x: Math.cos(rad) * x - Math.sin(rad) * y
  y: Math.sin(rad) * x + Math.cos(rad) * y
class Vessel
  constructor: ->
    @acceleration = .1
    @position =
      x: canvas.width/2
      y: canvas.height/2
    @rotationalSpeed = .1
    @orientation = 0
    @vector =
      x: 0
      y: 0
  draw: ->
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
      point.x = t.x + @position.x
      point.y = t.y + @position.y
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
  createVessel: ->
    new Vessel()
  surface: createSurface 800, 600
  mainLoop: =>
    @update()
    @draw()
    #@counters.update?()
  draw: => @surface.draw()
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
    vessel.position.y += vessel.vector.y
    vessel.thrust = @keyboard['thrust']
    if vessel.thrust
      vessel.vector.x += Math.cos(vessel.orientation) * vessel.acceleration
      vessel.vector.y += Math.sin(vessel.orientation) * vessel.acceleration
    vessel.orientation -= vessel.rotationalSpeed if @keyboard['left']
    vessel.orientation += vessel.rotationalSpeed if @keyboard['right']
    vessel.orientation = vessel.orientation % (2 * Math.PI)

  updateAsteroids: ->
    for asteroid in @asteroids
      asteroid.position.x += asteroid.direction.x * asteroid.speed
      asteroid.position.y += asteroid.direction.y * asteroid.speed

window.game = game =
  buttons: []
  images:
    'asteroid.png': null
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

