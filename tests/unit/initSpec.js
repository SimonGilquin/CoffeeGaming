// Generated by CoffeeScript 1.6.2
(function() {
  describe('Upon initialization', function() {
    var canvas;

    canvas = null;
    beforeEach(function() {
      spyOn(window, 'setInterval');
      return game.load();
    });
    xit('should update 60 times / s', function() {
      game.engine.init();
      return expect(window.setInterval).toHaveBeenCalledWith(game.engine.mainLoop, 1000 / 60);
    });
    it('should loop on the chrome animation frame', function() {
      spyOn(window, 'requestAnimationFrame');
      game.engine.init();
      return expect(window.requestAnimationFrame).toHaveBeenCalled();
    });
    it('should loop on the chrome animation frame', function() {
      spyOn(game.engine, 'mainLoop');
      game.engine.init();
      return expect(game.engine.mainLoop).toHaveBeenCalled();
    });
    return it('should track mouse events', function() {
      game.engine.init();
      moveMouseTo(47, 32);
      return expect(game.engine.events).toContain({
        type: 'mousemove',
        x: 47,
        y: 32
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=initSpec.map
*/
