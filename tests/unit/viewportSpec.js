// Generated by CoffeeScript 1.6.3
(function() {
  describe('The main canvas', function() {
    return it('has the size of the browser window', function() {
      expect(canvas.width).toBe(window.innerWidth);
      return expect(canvas.height).toBe(window.innerHeight);
    });
  });

  describe('The game viewport', function() {
    var contextMock, engine, viewport;
    engine = null;
    viewport = null;
    contextMock = null;
    beforeEach(function() {
      engine = game.engine;
      viewport = engine.viewport;
      return contextMock = createMockFor(CanvasRenderingContext2D);
    });
    it('exists', function() {
      return expect(engine.viewport).toBeDefined();
    });
    it('has the same size as the canvas', function() {
      expect(engine.viewport.width).toBe(canvas.width);
      return expect(engine.viewport.height).toBe(canvas.height);
    });
    it('is positioned on center of the game surface', function() {
      expect(viewport.x).toBe(engine.surface.width / 2);
      return expect(viewport.y).toBe(engine.surface.height / 2);
    });
    it('can be drawn', function() {
      expect(viewport.draw).toBeDefined();
      return expect(typeof viewport.draw).toBe('function');
    });
    return describe('when drawing', function() {
      beforeEach(function() {
        spyOn(game.engine.hud, 'draw');
        return viewport.draw();
      });
      it('should clear the screen', function() {
        return expect(contextMock.clearRect).toHaveBeenCalledWith(0, 0, canvas.width, canvas.height);
      });
      return it('should draw the HUD', function() {
        return expect(game.engine.hud.draw).toHaveBeenCalled();
      });
    });
  });

}).call(this);