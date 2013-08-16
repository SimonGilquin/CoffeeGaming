// Generated by CoffeeScript 1.6.3
(function() {
  describe('Asteroids', function() {
    var engine, oldImage;
    engine = null;
    oldImage = null;
    beforeEach(function() {
      oldImage = window.Image;
      window.Image = ImageHelper;
      game.load();
      window.Image.loadAll();
      return engine = game.engine;
    });
    afterEach(function() {
      return window.Image = oldImage;
    });
    it('when playing updates asteroids on game ticks', function() {
      spyOn(engine, 'updateAsteroids');
      engine.play();
      engine.update();
      return expect(engine.updateAsteroids).toHaveBeenCalled();
    });
    it('does not update while paused', function() {
      spyOn(engine, 'updateAsteroids');
      engine.pause();
      engine.update();
      return expect(engine.updateAsteroids).not.toHaveBeenCalled();
    });
    it('has some asteroids', function() {
      return expect(engine.asteroids.length > 0).toBeTruthy();
    });
    it('have no default vector', function() {
      var asteroid;
      asteroid = engine.asteroids.create();
      return expect(asteroid.vector).toBeEqualTo({
        x: 0,
        y: 0
      });
    });
    it('have a vector of 1:0', function() {
      var asteroid;
      asteroid = engine.asteroids.create();
      expect(asteroid.direction.x).toBe(1);
      return expect(asteroid.direction.y).toBe(0);
    });
    it('have a position of 100, 40', function() {
      var asteroid;
      asteroid = engine.asteroids.create();
      expect(asteroid.position.x).toBe(100);
      return expect(asteroid.position.y).toBe(40);
    });
    describe('when exiting the game surface', function() {
      it('by the right side is moved to the left', function() {
        var asteroid;
        asteroid = engine.asteroids.create(engine.surface.width + 1, 100);
        engine.updateAsteroids();
        return expect(asteroid.position).toBeEqualTo({
          x: 0,
          y: 100
        });
      });
      it('by the bottom side is moved to the top', function() {
        var asteroid;
        asteroid = engine.asteroids.create(100, engine.surface.height + 1);
        engine.updateAsteroids();
        return expect(asteroid.position).toBeEqualTo({
          x: 100,
          y: 0
        });
      });
      it('by the left side is moved to the right', function() {
        var asteroid;
        asteroid = engine.asteroids.create(-1, 100);
        engine.updateAsteroids();
        return expect(asteroid.position).toBeEqualTo({
          x: engine.surface.width,
          y: 100
        });
      });
      return it('by the top side is moved to the bottom', function() {
        var asteroid;
        asteroid = engine.asteroids.create(100, -1);
        engine.updateAsteroids();
        return expect(asteroid.position).toBeEqualTo({
          x: 100,
          y: engine.surface.height
        });
      });
    });
    return describe('update logic', function() {
      return it('moves the asteroid by its speed and direction', function() {
        var asteroid;
        asteroid = engine.asteroids.create(100, 40, {
          x: 1,
          y: 0
        });
        engine.updateAsteroids();
        expect(asteroid.position.x).toBe(101);
        return expect(asteroid.position.y).toBe(40);
      });
    });
  });

}).call(this);
