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
    it('have a speed of 1px/s', function() {
      var asteroid;
      asteroid = engine.asteroids.create();
      return expect(asteroid.speed).toBe(1);
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
    return describe('update logic', function() {
      it('moves the asteroid by its speed and direction', function() {
        var asteroid;
        asteroid = engine.asteroids.create();
        engine.updateAsteroids();
        expect(asteroid.position.x).toBe(101);
        return expect(asteroid.position.y).toBe(40);
      });
      return xit('creates an asteroid when there is none', function() {
        engine.updateAsteroids();
        return expect(engine.asteroids.length).toBe(1);
      });
    });
  });

}).call(this);
