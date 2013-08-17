debug = true
showconsole = false
enableLog = (object, name) ->
  overload = (instance, name) ->
    old = instance[name]
    instance[name] = (args...) =>
      console.log "#{name}(#{args})"
      old.apply instance, args

  if name?
    overload object, name
  else
    for id, prop of object when typeof prop == 'function'
      overload object, id
  true

distanceBetween = (pointA, pointB) ->
  Math.sqrt(Math.pow(pointA.x - pointB.x, 2) + Math.pow(pointA.y - pointB.y, 2))

log = (text) ->
  console.log text

canvas = document.createElement 'canvas'
canvas.width = window.innerWidth
canvas.height = window.innerHeight
document.body.appendChild canvas
context = canvas.getContext '2d'

surface = null
if showconsole
  canvas.width = window.innerWidth - 200
  inDocumentConsole = document.createElement 'div'
  inDocumentConsole.setAttribute 'class', 'console'
  inDocumentConsole.append = (text) ->
    element = document.createElement 'p'
    element.innerText = text
    @appendChild element
  document.body.appendChild inDocumentConsole
  oldLog = console.log
  console.log = (args...) ->
    inDocumentConsole.append args...
    oldLog.apply console, args

log "Window is (#{window.innerWidth}, #{window.innerHeight})"
log "Canvas created with (#{canvas.width}, #{canvas.height})"

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
    @text = new Text 'Game paused', 'white', 48, canvas.width/2, 280
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
    @image = (=>
      tempCanvas = document.createElement 'canvas'
      tempCanvas.width = @size
      tempCanvas.height = @size
      tempContext = tempCanvas.getContext '2d'
      tempContext.translate(@size/2, @size/2)
      tempContext.beginPath()
      tempContext.fillStyle = '#ccc'

      initialAngle = (Math.random() + 3) * Math.PI / @facets
      angle = initialAngle
      until closed
        if angle - initialAngle >= 2* Math.PI
          context.lineTo firstPoint.x, firstPoint.y
          closed = true
        else
          distance = (Math.random() + 4) * @size / 10
          point =
            x: Math.cos(angle) * distance
            y: Math.sin(angle) * distance
          if firstPoint?
            tempContext.lineTo point.x, point.y
          else
            firstPoint = point
            tempContext.moveTo point.x, point.y
        angle += (Math.random() + 3) * Math.PI / @facets

      tempContext.fill()
      tempContext.getImageData(@size * -.5, @size * -.5, @size, @size)
      url = tempCanvas.toDataURL()
      image = new window.Image()
      image.src = url
      image)()
  size: 40
  speed: 1
  facets: 32
  direction:
    x: 1
    y: 0
  position:
    x: 100
    y: 40
  drawAt: (x, y)->
  #  if 0 <= drawnAt.x + @size / 2 <= canvas.width + @size and 0 <= drawnAt.y + @size / 2 <= canvas.height + @size
    context.drawImage @image, x, y

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
  size: 20
  drawAt: (x, y)->
    context.beginPath()
    context.fillStyle = if @collides then '#0ff' else '#f00'
    points = []
    points.push x:10 , y:0
    points.push x:-10, y:10
    points.push x:-5, y:0
    points.push x:-10, y:-10
    points.push x:10 , y:0
    for point in points
      t = translate @orientation, point.x, point.y
      point.x = t.x + @position.x - x
      point.y = t.y + @position.y - y
    context.moveTo points[0].x, points[0].y
    context.lineTo(point.x, point.y) for point in points[1..]
    context.fill()

  distanceFrom : (object) ->
    Math.sqrt(Math.pow(object.position.x - @position.x, 2) + Math.pow(object.position.y - @position.y, 2))

keymap =
  37: 'left'
  38: 'thrust'
  39: 'right'
  40: 'reverse'
  27: 'escape'
  32: 'stop'

class Engine
  constructor: ->
    @hud = new Hud()
    @asteroids = createAsteroidStore()
    @vessel = new Vessel()
    keyboard = {}
    for code, key of keymap
      keyboard[key] = false
    @keyboard = keyboard
    @collisions = []
    @viewport = (=>
      x = @surface.width / 2 - canvas.width / 2
      y = @surface.height / 2 - canvas.height / 2
      width = canvas.width
      height = canvas.height
      log "Viewport is at (#{x}, #{y}) with (#{width}, #{height})"
      background = game.images['space.jpg']
      x: x
      y: y
      width: width
      height: height
      draw: ->
        context.clearRect 0, 0, canvas.width, canvas.height
        @x = game.engine.vessel.position.x - canvas.width / 2
        @y = game.engine.vessel.position.y - canvas.height / 2
#        if debug
#          logText = "Space.jpg(#{@x}, #{@y}, #{@width}, #{@height}) drawn at 0, 0"
#          unless logText is oldLogText
#            console.log logText
#            oldLogText = logText
        if background.width < @width + @x
          xOffset = background.width - @x
        else if @x < 0
          xOffset = -@x
        if background.height < @height + @y
          yOffset = background.height - @y
        else if @y < 0
          yOffset = -@y

        if xOffset? and yOffset?
          context.drawImage background, background.width - xOffset, background.height - yOffset, xOffset, yOffset, 0, 0, xOffset, yOffset  #topleft
          context.drawImage background, 0, background.height - yOffset, @width - xOffset, yOffset, xOffset, 0, @width - xOffset, yOffset #topright
          context.drawImage background, background.width - xOffset, 0, xOffset, @height - yOffset, 0, yOffset, xOffset, @height - yOffset  #bottomleft
          context.drawImage background, 0, 0, @width - xOffset, @height - yOffset, xOffset, yOffset, @width - xOffset, @height - yOffset #bottomright
        else if xOffset?
          context.drawImage background, background.width - xOffset, @y, xOffset, @height, 0, 0, xOffset, @height  #left
          context.drawImage background, 0, @y, @width - xOffset, @height, xOffset, 0, @width - xOffset, @height #right
        else if yOffset?
          context.drawImage background, @x, background.height - yOffset, @width, yOffset, 0, 0, @width, yOffset  #top
          context.drawImage background, @x, 0, @width, @height - yOffset, 0, yOffset, @width, @height - yOffset #bottom
        else
          context.drawImage background, @x, @y, @width, @height, 0, 0, @width, @height

        for asteroid in game.engine.asteroids
          drawnAt =
            x: asteroid.position.x - @x - asteroid.size / 2
            y: asteroid.position.y - @y - asteroid.size / 2
          drawnAt.x -= surface.width if drawnAt.x > surface.width
          drawnAt.y -= surface.height if drawnAt.y > surface.height
          drawnAt.x += surface.width if drawnAt.x + surface.width < @width
          drawnAt.y += surface.height if drawnAt.y + surface.height < @height
          asteroid.drawAt(drawnAt.x, drawnAt.y) if -asteroid.size <= drawnAt.x <= @width and -asteroid.size <= drawnAt.y <= @height
        game.engine.vessel.drawAt @x, @y
        game.engine.hud.draw()
    )()

  running: null
  counters:
    start: Date.now()
    frames: 0
    add: ->
      timing = -> performance?.now?() or window.Date.now()
      countersElement = document.createElement 'div'
      countersElement.setAttribute 'class', 'counters'

      createCounter = (title) ->
        counter = document.createElement 'p'
        counter.innerHTML = title + ': '
        counterValue = document.createElement 'span'
        counterValue.setAttribute 'class', title.replace(' ', '-').toLowerCase()
        counter.appendChild counterValue
        countersElement.appendChild counter
        counterValue

      fps = createCounter('FPS')
      updateTime = createCounter('Update')
      drawTime = createCounter('Draw')
      collisions = createCounter('Collisions')
      camera = createCounter('Camera')
      ship = createCounter('Ship')

      document.body.appendChild countersElement

      fps.lastUpdate = timing()
      fps.lastFrameCount = 0
      oldUpdate = game.engine.update
      oldDraw = game.engine.draw
      collisions.total = 0
      game.engine.update = =>
        updateStart = timing()
        oldUpdate()
        collisions.innerHTML = "#{game.engine.collisions.length} (total: #{collisions.total += game.engine.collisions.length})"
        updateTime.innerHTML = Math.round timing() - updateStart
        camera.innerHTML = "#{Math.floor(game.engine.viewport.x)}, #{Math.floor(game.engine.viewport.y)}"
        ship.innerHTML = "#{Math.floor(game.engine.vessel.position.x)}, #{Math.floor(game.engine.vessel.position.y)}, (#{game.engine.vessel.vector.x}, #{game.engine.vessel.vector.y})"
      game.engine.draw = =>
        drawStart = timing()
        oldDraw()
        endLoop = timing()
        drawTime.innerHTML = Math.round endLoop - drawStart
        @frames++
        if endLoop - fps.lastUpdate > 250
          fps.innerHTML = @fps = Math.round((@frames - fps.lastFrameCount) * 1000 / (endLoop - fps.lastUpdate))
          fps.lastUpdate = endLoop
          fps.lastFrameCount = @frames
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
  draw: => @viewport.draw()
  init: ->
    @counters.add() if debug
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
      @updateCollisions @vessel, @asteroids
      @updateAsteroids()
      @updateVessel @vessel

  updateCollisions: (vessel, asteroids) ->
    # reset old collisions
    for collision in @collisions
      collision.source.collides = false
      collision.target.collides = false

    firstpass = []
    for asteroid in asteroids when vessel.distanceFrom(asteroid) < (asteroid.size + vessel.size) / 2
      firstpass.push
        source: vessel
        target: asteroid
    @collisions = firstpass
    for collision in @collisions
      collision.source.collides = true
      collision.target.collides = true
  #game.engine.collisions.push 'Vessel crashed into asteroid!' if collisions.length > 0

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
    if @keyboard.reverse
      vessel.vector.x -= Math.cos(vessel.orientation) * vessel.acceleration * .2
      vessel.vector.y -= Math.sin(vessel.orientation) * vessel.acceleration * .2
    if @keyboard.stop
      if vessel.vector.x > 0
        vessel.vector.x -= Math.min(vessel.acceleration * .2, vessel.vector.x * vessel.acceleration)
      else
        vessel.vector.x += Math.min(vessel.acceleration * .2, -vessel.vector.x * vessel.acceleration)
      if vessel.vector.y > 0
        vessel.vector.y -= Math.min(vessel.acceleration * .2, vessel.vector.y * vessel.acceleration)
      else
        vessel.vector.y += Math.min(vessel.acceleration * .2, -vessel.vector.y * vessel.acceleration)
      vessel.vector.x = 0 if -.01 < vessel.vector.x < .01
      vessel.vector.y = 0 if -.01 < vessel.vector.y < .01
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
    'space.jpg' : null
  debug: debug
  load: ->
    counter = 0
    loadImage = (url) =>
      image = new window.Image()
      image.src = "img/#{url}"
      image.onload = =>
        @images[url] = image
        counter--
        if counter == 0
          @engine = new Engine()
          @engine.init().pause()
          window.vessel = game.engine.vessel
          window.asteroids = game.engine.asteroids
          vessel.position.x = 3900
          vessel.position.y = 2900

    for url of @images
          counter++
          loadImage url
  reset: ->
    delete @engine

game.load()
#game.init().pause()


