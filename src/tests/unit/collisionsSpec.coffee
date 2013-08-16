xdescribe 'Collisions', ->
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
