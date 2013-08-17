describe 'Collisions', ->
  vessel = null
  asteroids = null
  engine = null
  beforeEach ->
    game.engine = engine = new Engine()
    engine.init()
    engine.play()
    vessel = engine.createVessel()
    asteroids = []

  describe 'on first pass', ->
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
    it 'should have any items closer than 30', ->
      asteroids.push new Asteroid vessel.position.x + 25, vessel.position.y
      asteroids.push new Asteroid vessel.position.x - 25, vessel.position.y
      asteroids.push new Asteroid vessel.position.x, vessel.position.y + 40
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 2
    it 'should have a reference to the correct items', ->
      asteroids.push new Asteroid vessel.position.x - 40, vessel.position.y
      asteroids.push new Asteroid vessel.position.x + 10, vessel.position.y
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions[0].source).toBe vessel
      expect(engine.collisions[0].target).toBe asteroids[1]

  describe 'between asteroids', ->
    it 'can happen', ->
      asteroids.push new Asteroid 100, 100
      asteroids.push new Asteroid 120, 120
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 1
    it 'happens when on the surface limit', ->
      asteroids.push new Asteroid 10, 10
      asteroids.push new Asteroid -10, -10
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 1

  it 'should be known as collided', ->
    asteroids.push asteroid = new Asteroid vessel.position.x + 10, vessel.position.y + 10
    engine.updateCollisions vessel, asteroids
    expect(vessel.collides).toBeTruthy()
    expect(asteroid.collides).toBeTruthy()
  it 'should be resetted after a collision passes', ->
    asteroids.push asteroid = new Asteroid vessel.position.x + 10, vessel.position.y + 10
    engine.updateCollisions vessel, asteroids
    asteroid.position =
      x: 100
      y: 100
    engine.updateCollisions vessel, asteroids
    expect(vessel.collides).toBeFalsy()
    expect(asteroid.collides).toBeFalsy()

  describe 'head on between asteroids', ->
    it 'should invert their X vector', ->
      asteroids.push first = new Asteroid 80, 0, {x: 1, y: 0}
      asteroids.push second = new Asteroid 120, 0, {x: -1, y: 0}
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 1
      expect(first.vector).toBeEqualTo
        x: -1
        y: 0
      expect(second.vector).toBeEqualTo
        x: 1
        y: 0
    it 'should invert their Y vector', ->
      asteroids.push first = new Asteroid 0, 80, {x: 0, y: 1}
      asteroids.push second = new Asteroid 0, 120, {x: 0, y: -1}
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 1
      expect(first.vector).toBeEqualTo
        x: 0
        y: -1
      expect(second.vector).toBeEqualTo
        x: 0
        y: 1
    it 'at 45° should invert both vectors', ->
      asteroids.push first = new Asteroid 90, 90, {x: 1, y: 1}
      asteroids.push second = new Asteroid 110, 110, {x: -1, y: -1}
      engine.updateCollisions vessel, asteroids
      expect(engine.collisions.length).toBe 1
      expect(first.vector).toBeEqualTo
        x: -1
        y: -1
      expect(second.vector).toBeEqualTo
        x: 1
        y: 1
  xit 'should rebound in a 2D plane', ->
    asteroids.push first = new Asteroid 0, 0, {x: 0, y: 0}
    asteroids.push second = new Asteroid -25, -25, {x: 1, y: 1}
    engine.updateCollisions vessel, asteroids
    expect(engine.collisions.length).toBe 1
    expect(second.vector).toBeEqualTo
      x: 1
      y: 1
