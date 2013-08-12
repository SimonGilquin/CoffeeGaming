describe 'Asteroids', ->
  engine = null
  oldImage = null
  beforeEach ->
    oldImage = window.Image
    window.Image = ImageHelper
    game.load()
    window.Image.loadAll()
    engine = game.engine
  afterEach ->
    window.Image = oldImage

  it 'when playing updates asteroids on game ticks', ->
    spyOn engine, 'updateAsteroids'
    engine.play()
    engine.update()
    expect(engine.updateAsteroids).toHaveBeenCalled()

  it 'does not update while paused', ->
    spyOn engine, 'updateAsteroids'
    engine.pause()
    engine.update()
    expect(engine.updateAsteroids).not.toHaveBeenCalled()

  it 'has 12 asteroids', ->
    expect(engine.asteroids.length).toBe 12

  it 'have a speed of 1px/s', ->
    asteroid = engine.asteroids.create()
    expect(asteroid.speed).toBe 1
  it 'have a vector of 1:0', ->
    asteroid = engine.asteroids.create()
    expect(asteroid.direction.x).toBe 1
    expect(asteroid.direction.y).toBe 0
  it 'have a position of 100, 40', ->
    asteroid = engine.asteroids.create()
    expect(asteroid.position.x).toBe 100
    expect(asteroid.position.y).toBe 40

  describe 'update logic', ->
    it 'moves the asteroid by its speed and direction', ->
      asteroid = engine.asteroids.create()
      engine.updateAsteroids()
      expect(asteroid.position.x).toBe 101
      expect(asteroid.position.y).toBe 40
    xit 'creates an asteroid when there is none', ->
      engine.updateAsteroids()
      expect(engine.asteroids.length).toBe 1
