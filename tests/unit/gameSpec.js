// Generated by CoffeeScript 1.6.3
(function() {
  describe('The game engine', function() {
    var engine;
    engine = null;
    beforeEach(function() {
      game.engine = engine = new Engine();
      return engine.init();
    });
    it('should have a surface', function() {
      return expect(engine.surface).toBeDefined();
    });
    it('can be initialized', function() {
      expect(engine.init).toBeDefined();
      return expect(typeof engine.init).toBe('function');
    });
    it('has a HUD', function() {
      return expect(engine.hud).toBeDefined();
    });
    it('should be paused by default', function() {
      return expect(engine.isPaused()).toBeTruthy();
    });
    it('can be updated', function() {
      return expect(typeof engine.update).toBe('function');
    });
    describe('when paused', function() {
      beforeEach(function() {
        return engine.pause();
      });
      return it('can be resumed', function() {
        engine.play();
        return expect(engine.isPaused()).toBeFalsy();
      });
    });
    describe('when started', function() {
      beforeEach(function() {
        return engine.play();
      });
      return it('can be paused', function() {
        engine.pause();
        return expect(engine.isPaused()).toBeTruthy();
      });
    });
    return xdescribe('performance counters', function() {
      return it('should work when there is no performance.now()', function() {
        var old;
        old = window.performance;
        window.performance = null;
        engine.init();
        return window.performance = old;
      });
    });
  });

}).call(this);
