define ['game'], (game) ->
  describe 'Asteroids', ->
    engine = null
    beforeEach ->
      game.engine = engine = new Engine()
      engine.init()

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

    it 'has some asteroids', ->
      expect(engine.asteroids.length > 0).toBeTruthy()

    it 'have no default vector', ->
      asteroid = engine.asteroids.create()
      expect(asteroid.vector).toBeEqualTo
        x: 0
        y: 0
    it 'have a vector of 1:0', ->
      asteroid = engine.asteroids.create()
      expect(asteroid.direction.x).toBe 1
      expect(asteroid.direction.y).toBe 0
    it 'have a position of 100, 40', ->
      asteroid = engine.asteroids.create()
      expect(asteroid.position.x).toBe 100
      expect(asteroid.position.y).toBe 40

    describe 'when exiting the game surface', ->
      it 'by the right side is moved to the left', ->
        asteroid = engine.asteroids.create(engine.surface.width + 1, 100)
        engine.updateAsteroids()
        expect(asteroid.position).toBeEqualTo
          x: 0
          y: 100
      it 'by the bottom side is moved to the top', ->
        asteroid = engine.asteroids.create(100, engine.surface.height + 1)
        engine.updateAsteroids()
        expect(asteroid.position).toBeEqualTo
          x: 100
          y: 0
      it 'by the left side is moved to the right', ->
        asteroid = engine.asteroids.create(-1, 100)
        engine.updateAsteroids()
        expect(asteroid.position).toBeEqualTo
          x: engine.surface.width
          y: 100
      it 'by the top side is moved to the bottom', ->
        asteroid = engine.asteroids.create(100, -1)
        engine.updateAsteroids()
        expect(asteroid.position).toBeEqualTo
          x: 100
          y: engine.surface.height

    describe 'update logic', ->
      it 'moves the asteroid by its speed and direction', ->
        asteroid = engine.asteroids.create(100, 40, {x: 1, y: 0})
        engine.updateAsteroids()
        expect(asteroid.position.x).toBe 101
        expect(asteroid.position.y).toBe 40
