// Generated by CoffeeScript 1.6.3
(function() {
  describe('The main canvas', function() {
    return it('has the size of the browser window', function() {
      expect(canvas.width).toBe(window.innerWidth);
      return expect(canvas.height).toBe(window.innerHeight);
    });
  });

  describe('The game viewport', function() {
    var engine;
    engine = null;
    beforeEach(function() {
      return engine = game.engine;
    });
    it('exists', function() {
      return expect(engine.viewport).toBeDefined();
    });
    return it('has the same size as the canvas', function() {
      expect(engine.viewport.width).toBe(canvas.width);
      return expect(engine.viewport.height).toBe(canvas.height);
    });
  });

}).call(this);
