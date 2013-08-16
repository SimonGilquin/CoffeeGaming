// Generated by CoffeeScript 1.6.3
(function() {
  xdescribe('Collisions', function() {
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
    return describe('first pass', function() {
      return it('should be empty when distances are high', function() {
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
    });
  });

}).call(this);
