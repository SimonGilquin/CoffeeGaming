// Generated by CoffeeScript 1.6.3
(function() {
  describe('Collisions', function() {
    var asteroids, collisions, engine, oldImage, vessel;
    engine = null;
    oldImage = null;
    vessel = null;
    asteroids = null;
    collisions = null;
    beforeEach(function() {
      oldImage = window.Image;
      window.Image = ImageHelper;
      game.load();
      window.Image.loadAll();
      engine = game.engine;
      engine.play();
      vessel = engine.createVessel();
      asteroids = [];
      return collisions = engine.collisions;
    });
    afterEach(function() {
      return window.Image = oldImage;
    });
    describe('first pass', function() {
      it('should be empty when distances are high', function() {
        asteroids.push({
          position: {
            x: vessel.position.x + 40,
            y: vessel.position.y
          }
        });
        asteroids.push({
          position: {
            x: vessel.position.x,
            y: vessel.position.y + 40
          }
        });
        asteroids.push({
          position: {
            x: vessel.position.x + 20,
            y: vessel.position.y + 20
          }
        });
        engine.updateCollisions(vessel, asteroids);
        return expect(engine.collisions.length).toBe(0);
      });
      it('should have any items closer than 30', function() {
        asteroids.push({
          size: 40,
          position: {
            x: vessel.position.x + 30,
            y: vessel.position.y
          }
        });
        asteroids.push({
          size: 40,
          position: {
            x: vessel.position.x,
            y: vessel.position.y + 10
          }
        });
        asteroids.push({
          size: 40,
          position: {
            x: vessel.position.x + 10,
            y: vessel.position.y + 10
          }
        });
        engine.updateCollisions(vessel, asteroids);
        return expect(engine.collisions.length).toBe(2);
      });
      return it('should have a reference to the correct items', function() {
        asteroids.push({
          size: 40,
          position: {
            x: vessel.position.x + 30,
            y: vessel.position.y
          }
        });
        asteroids.push({
          size: 40,
          position: {
            x: vessel.position.x + 10,
            y: vessel.position.y + 10
          }
        });
        asteroids.push({
          size: 40,
          position: {
            x: vessel.position.x,
            y: vessel.position.y + 20
          }
        });
        engine.updateCollisions(vessel, asteroids);
        expect(engine.collisions[0].source).toBe(vessel);
        return expect(engine.collisions[0].target).toBe(asteroids[1]);
      });
    });
    it('should be known be the collided', function() {
      var asteroid;
      asteroids.push(asteroid = {
        size: 40,
        position: {
          x: vessel.position.x + 10,
          y: vessel.position.y + 10
        }
      });
      engine.updateCollisions(vessel, asteroids);
      expect(vessel.collides).toBeTruthy();
      return expect(asteroid.collides).toBeTruthy();
    });
    return it('should be resetted after a collision passes', function() {
      var asteroid;
      asteroids.push(asteroid = {
        position: {
          x: vessel.position.x + 10,
          y: vessel.position.y + 10
        }
      });
      engine.updateCollisions(vessel, asteroids);
      asteroid.position = {
        x: 100,
        y: 100
      };
      engine.updateCollisions(vessel, asteroids);
      expect(vessel.collides).toBeFalsy();
      return expect(asteroid.collides).toBeFalsy();
    });
  });

}).call(this);
