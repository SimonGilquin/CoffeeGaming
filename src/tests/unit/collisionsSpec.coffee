describe 'Collisions', ->
  engine = null
  oldImage = null
  vessel = null
  asteroids = null
  collisions = null
  beforeEach ->
    oldImage = window.Image
    window.Image = ImageHelper
    game.load()
    window.Image.loadAll()
    engine = game.engine
    engine.play()
    vessel = engine.createVessel()
    asteroids = []
    collisions = engine.collisions
  afterEach ->
    window.Image = oldImage

  describe 'first pass', ->
    it 'should be empty when distances are high', ->
      asteroids.push
        position:
          x: vessel.position.x + 40
          y: vessel.position.y
      asteroids.push
        position:
          x: vessel.position.x
          y: vessel.position.y + 40
      asteroids.push
        position:
          x: vessel.position.x + 20
          y: vessel.position.y + 20
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 0
    it 'should have any items closer than 20', ->
      asteroids.push
        position:
          x: vessel.position.x + 20
          y: vessel.position.y
      asteroids.push
        position:
          x: vessel.position.x
          y: vessel.position.y + 10
      asteroids.push
        position:
          x: vessel.position.x + 10
          y: vessel.position.y + 10
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 2
    it 'should have a reference to the correct items', ->
      asteroids.push
        position:
          x: vessel.position.x + 20
          y: vessel.position.y
      asteroids.push
        position:
          x: vessel.position.x + 10
          y: vessel.position.y + 10
      asteroids.push
        position:
          x: vessel.position.x
          y: vessel.position.y + 20
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions[0].source).toBe vessel
      expect(engine.collisions[0].target).toBe asteroids[1]
  it 'should be known be the collided', ->
    asteroids.push asteroid =
      position:
        x: vessel.position.x + 10
        y: vessel.position.y + 10
    engine.updateCollisions vessel, asteroids
    expect(vessel.collides).toBeTruthy()
    expect(asteroid.collides).toBeTruthy()
  it 'should be resetted after a collision passes', ->
    asteroids.push asteroid =
      position:
        x: vessel.position.x + 10
        y: vessel.position.y + 10
    engine.updateCollisions vessel, asteroids
    asteroid.position =
      x: 100
      y: 100
    engine.updateCollisions vessel, asteroids
    expect(vessel.collides).toBeFalsy()
    expect(asteroid.collides).toBeFalsy()

