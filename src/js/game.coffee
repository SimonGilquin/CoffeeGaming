Number.prototype.toDeg = ->
  this * 180 / Math.PI

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
  refA = pointA.position or pointA
  refB = pointB.position or pointB
  Math.sqrt(Math.pow(refA.x - refB.x, 2) + Math.pow(refA.y - refB.y, 2))

speedOf = (object) ->
  Math.sqrt(Math.pow(object.vector.x, 2) + Math.pow(object.vector.y, 2))

directionOf = (object) ->
  Math.atan2 object.vector.y, object.vector.x

willCollide = (objectA, objectB) ->
  futurePositionA =
    x: objectA.position.x + objectA.vector.x
    y: objectA.position.y + objectA.vector.y
  futurePositionB =
    x: objectB.position.x + objectB.vector.x
    y: objectB.position.y + objectB.vector.y
  distanceBetween(futurePositionA, futurePositionB) <= (objectA.size + objectB.size) / 2

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
  @generate: (size, facets) ->
    initialAngle = (Math.random() + 3) * Math.PI / facets
    angle = initialAngle
    points = []
    until closed
      if angle - initialAngle >= 2* Math.PI
        points.push firstPoint
        closed = true
      else
        distance = (Math.random() + 4) * size / 10
        point =
          x: Math.cos(angle) * distance
          y: Math.sin(angle) * distance
        if firstPoint?
          points.push point
        else
          firstPoint = point
          points.push point
      angle += (Math.random() + 3) * Math.PI / facets
    points
  @createImage: (vertices, size) ->
    tempCanvas = document.createElement 'canvas'
    tempCanvas.width = size * 2
    tempCanvas.height = size
    tempContext = tempCanvas.getContext '2d'
    tempContext.translate(size/2, size/2)
    tempContext.beginPath()
    tempContext.fillStyle = '#ccc'

    tempContext.moveTo vertices[0].x, vertices[0].y
    tempContext.lineTo vertex.x, vertex.y for vertex in vertices[1..]

    tempContext.fill()
    tempContext.translate(size, 0)
    tempContext.beginPath()
    tempContext.fillStyle = '#333'

    tempContext.moveTo vertices[0].x, vertices[0].y
    tempContext.lineTo vertex.x, vertex.y for vertex in vertices[1..]

    tempContext.fill()
    tempContext.getImageData(size * -.5, size * -.5, size, size)
    url = tempCanvas.toDataURL()
    image = new window.Image()
    image.src = url
    image
  constructor: (posX = 100, posY = 40, @vector, @size = 40, @mass) ->
    @mass = @size unless @mass?
    unless @vector?
      @vector =
        x: 0
        y: 0
    @position =
      x: posX
      y: posY
    @vertices = Asteroid.generate @size, @facets
    @image = Asteroid.createImage @vertices, @size
    @resistance = @mass
  speed: 1
  facets: 32
  direction:
    x: 1
    y: 0
  position:
    x: 100
    y: 40
  drawAt: (x, y)->
    if @collides
      context.drawImage @image, @size, 0, @size, @size, x, y, @size, @size
    else
      context.drawImage @image, 0, 0, @size, @size, x, y, @size, @size

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
  constructor: (x, y, @mass = 20) ->
    @acceleration = .1
    @position =
      x: x or surface.width / 2
      y: y or surface.height / 2
    @rotationalSpeed = .1
    @orientation = 0
    @vector =
      x: 0
      y: 0
    @cooldown = 0
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
  createBullet: ->
    position =
      x: Math.cos(@orientation) * @size / 2 + @position.x
      y: Math.sin(@orientation) * @size / 2 + @position.y
    vector =
      x: Math.cos(vessel.orientation) * 5 + vessel.vector.x
      y: Math.sin(vessel.orientation) * 5 + vessel.vector.y
    new Bullet position, vector
  distanceFrom : (object) ->
    Math.sqrt(Math.pow(object.position.x - @position.x, 2) + Math.pow(object.position.y - @position.y, 2))

keymap =
  37: 'left'
  38: 'thrust'
  39: 'right'
  40: 'reverse'
  27: 'escape'
  32: 'stop'
  17: 'shoot'

class Engine
  constructor: ->
    @hud = new Hud()
    @asteroids = createAsteroidStore()
    @vessel = new Vessel()
    @bullets = []
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

        for bullet in game.engine.bullets
          drawnAt =
            x: bullet.position.x - @x
            y: bullet.position.y - @y
          drawnAt.x -= surface.width if drawnAt.x > surface.width
          drawnAt.y -= surface.height if drawnAt.y > surface.height
          drawnAt.x += surface.width if drawnAt.x + surface.width < @width
          drawnAt.y += surface.height if drawnAt.y + surface.height < @height
          bullet.drawAt(drawnAt.x, drawnAt.y) if 0 <= drawnAt.x <= @width and 0 <= drawnAt.y <= @height
          
        if game.engine.debug?
          context.beginPath()
          context.strokeStyle = 'red'
          context.lineWidth = 2
          x = game.engine.debug.contactPoint.x - @x
          y = game.engine.debug.contactPoint.y - @y
          context.arc x, y, 5, 0, 2 * Math.PI
          context.fillText game.engine.debug.angle, x, y
          context.stroke()

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

      lastUpdate = timing()
      fps.lastFrameCount = 0
      oldUpdate = game.engine.update
      oldDraw = game.engine.draw
      collisions.total = 0
      game.engine.update = =>
        updateStart = timing()
        oldUpdate()
        endUpdate = timing()
        if endUpdate - lastUpdate > 250
          collisions.innerHTML = "#{game.engine.collisions.length} (total: #{collisions.total += game.engine.collisions.length})"
          updateTime.innerHTML = Math.round endUpdate - updateStart
          camera.innerHTML = "#{Math.floor(game.engine.viewport.x)}, #{Math.floor(game.engine.viewport.y)}"
          ship.innerHTML = "#{Math.floor(game.engine.vessel.position.x)}, #{Math.floor(game.engine.vessel.position.y)}, (#{game.engine.vessel.vector.x}, #{game.engine.vessel.vector.y})"
      game.engine.draw = =>
        drawStart = timing()
        oldDraw()
        endLoop = timing()
        drawTime.innerHTML = Math.round endLoop - drawStart
        @frames++
        if endLoop - lastUpdate > 250
          fps.innerHTML = @fps = Math.round((@frames - fps.lastFrameCount) * 1000 / (endLoop - lastUpdate))
          lastUpdate = endLoop
          fps.lastFrameCount = @frames
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
  enableCounters = false
  init: ->
    @counters.add() if @enableCounters
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
      @updatePositions @bullets
      @updateVessel @vessel

  updateCollisions: (vessel, asteroids) ->
    # reset old collisions
    #for collision in @collisions
    #  collision.source.collides = false
    #  collision.target.collides = false

    firstpass = []
    for asteroid, id in asteroids
      if willCollide vessel, asteroid
        firstpass.push
          source: vessel
          target: asteroid
      for secondAsteroid in asteroids[id+1..] when willCollide asteroid, secondAsteroid
        firstpass.push
          source: asteroid
          target: secondAsteroid
      for bullet in @bullets when willCollide asteroid, bullet
        firstpass.push
          source: asteroid
          target: bullet

    for collision in @collisions
      collision.active = false
      collision.source.collides = false
      collision.target.collides = false

    newCollisions = []
    for current in firstpass
      alreadyExists = false
      for collision in @collisions
        if current.source == collision.source and current.target == collision.target
          alreadyExists = true
          collision.active = true
      newCollisions.push current unless alreadyExists
    @collisions = (for collision in @collisions when collision.active
      collision.source.collides = true
      collision.target.collides = true
      collision)

    for collision in newCollisions #when not collision.target.collides and not collision.source.collides
      source = collision.source
      target = collision.target
      distance = distanceBetween source, target
      gap = distance - (source.size + target.size) / 2
      sourceGap = speedOf(source) * gap / (speedOf(source) + speedOf(target))
      targetGap = speedOf(target) * gap / (speedOf(source) + speedOf(target))
      source.position.x += Math.cos(directionOf(source)) * sourceGap
      source.position.y += Math.sin(directionOf(source)) * sourceGap
      target.position.x += Math.cos(directionOf(target)) * targetGap
      target.position.y += Math.sin(directionOf(target)) * targetGap
      source.collides = true
      target.collides = true
      collision.contactPoint =
        x: (source.position.x * target.size + target.position.x * source.size) / (source.size + target.size)
        y: (source.position.y * target.size + target.position.y * source.size) / (source.size + target.size)
      collision.angle = Math.atan2(collision.contactPoint.y - source.position.y, collision.contactPoint.x - source.position.x)
      collision.active = true
      sourceSpeed = speedOf source
      targetSpeed = speedOf target
      sourceAngle = Math.atan2(source.vector.y, source.vector.x)
      targetAngle = Math.atan2(target.vector.y, target.vector.x)
      game.engine.debug = collision
      log "Collision: #{sourceAngle.toDeg()}, #{targetAngle.toDeg()}: #{collision.angle.toDeg()}"
      sourceRotatedSpeed = (sourceSpeed * Math.cos(sourceAngle - collision.angle) * (source.mass - target.mass) + 2 * target.mass * targetSpeed * Math.cos(targetAngle - collision.angle)) / (source.mass + target.mass)
      targetRotatedSpeed = (targetSpeed * Math.cos(targetAngle - collision.angle) * (target.mass - source.mass) + 2 * source.mass * sourceSpeed * Math.cos(sourceAngle - collision.angle)) / (source.mass + target.mass)
      source.vector.x = sourceRotatedSpeed * Math.cos(collision.angle) + sourceSpeed * Math.sin(sourceAngle - collision.angle) * Math.cos(collision.angle + 2 * Math.PI)
      source.vector.y = sourceRotatedSpeed * Math.sin(collision.angle) + sourceSpeed * Math.sin(sourceAngle - collision.angle) * Math.sin(collision.angle + 2 * Math.PI)
      target.vector.x = targetRotatedSpeed * Math.cos(collision.angle) + targetSpeed * Math.sin(targetAngle - collision.angle) * Math.cos(collision.angle + 2 * Math.PI)
      target.vector.y = targetRotatedSpeed * Math.sin(collision.angle) + targetSpeed * Math.sin(targetAngle - collision.angle) * Math.sin(collision.angle + 2 * Math.PI)

      if target.damage?
        source.resistance -= target.damage
        collision.active = false
        source.collides = false
        @bullets.splice(@bullets.indexOf(target), 1)
        if source.resistance <= 0
          @asteroids.splice @asteroids.indexOf(source), 1

      @collisions.push collision
    @collisions = (collision for collision in @collisions when collision.active)

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
    vessel.cooldown--
    if @keyboard.shoot and vessel.cooldown <= 0
      vessel.cooldown = 10
      @bullets.push vessel.createBullet()

  updateAsteroids: ->
    @updatePositions @asteroids

  updatePositions: (collection) ->
    for item in collection
      item.position.x += item.vector.x
      item.position.x = 0 if item.position.x > game.engine.surface.width
      item.position.x = game.engine.surface.width if item.position.x < 0
      item.position.y += item.vector.y
      item.position.y = 0 if item.position.y > game.engine.surface.height
      item.position.y = game.engine.surface.height if item.position.y < 0

class Bullet
  constructor: (@position, @vector, @mass = .1, @size = 10) ->
    @damage = 100 * @mass
  drawAt: (x, y) ->
    context.beginPath()
    context.fillStyle = 'orange'
    context.arc x, y, @size / 2, 0, 2 * Math.PI
    context.fill()

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
          @engine.enableCounters = true
          @engine.init().play()
          window.vessel = game.engine.vessel
          window.asteroids = game.engine.asteroids
          if false
            asteroids.pop() for asteroid in window.asteroids
            asteroids.push new Asteroid 1500, 1200, {x: 0, y: 0}, 100
            #asteroids.push new Asteroid 1900, 800, {x: 1, y: 0}
            #asteroids.push new Asteroid 2100, 800, {x: -1, y: 0}
            #asteroids.push new Asteroid 1900, 900, {x: 1, y: 0}
            #asteroids.push new Asteroid 2100, 900, {x: 0, y: 0}, 100
            #asteroids.push new Asteroid 2200, 1200, {x: 0, y: 0}
            #asteroids.push new Asteroid 2200, 1100, {x: 0, y: 1}
            #asteroids.push new Asteroid 2300, 1200, {x: 0, y: -1}
            #asteroids.push new Asteroid 2300, 1100, {x: 0, y: 0}
            #asteroids.push new Asteroid 2400, 1200, {x: 0, y: -1}
            #asteroids.push new Asteroid 2400, 1100, {x: 0, y: 1}

            asteroids.push new Asteroid 2100, 1100, {x: 2, y: 2}, 10
            asteroids.push new Asteroid 1900, 1100, {x: -2, y: 2}, 10
            asteroids.push new Asteroid 1900, 900, {x: -2, y: -2}, 10
            asteroids.push new Asteroid 2100, 900, {x: 2, y: -2}, 10
            asteroids.push new Asteroid 2300, 1300, {x: -2, y: -2}, 100
            asteroids.push new Asteroid 1700, 1300, {x: 2, y: -2}, 100
            asteroids.push new Asteroid 1700, 700, {x: 2, y: 2}, 100
            asteroids.push new Asteroid 2300, 700, {x: -2, y: 2}, 100
            vessel.position =
              x: 2000
              y: 1000

    for url of @images
          counter++
          loadImage url
  reset: ->
    delete @engine

window.Engine = Engine
window.Asteroid = Asteroid

#game.load()
#game.init().pause()

