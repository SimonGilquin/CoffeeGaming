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
    it('should register mouse movements', function() {
      game.engine.init();
      moveMouseTo(47, 32);
      return expect(game.engine.events).toContain({
        type: 'mousemove',
        x: 47,
        y: 32
      });
    });
    it('should register mouse pressing', function() {
      game.engine.init();
      mouseDownAt(47, 32);
      return expect(game.engine.events).toContain({
        type: 'mousedown',
        x: 47,
        y: 32
      });
    });
    it('should register mouse releasing', function() {
      game.engine.init();
      mouseUpAt(47, 32);
      return expect(game.engine.events).toContain({
        type: 'mouseup',
        x: 47,
        y: 32
      });
    });
    it('should register key pressing', function() {
      game.engine.init();
      pressKey(23);
      expect(game.engine.events[0].type).toBe('keydown');
      return expect(game.engine.events[0].keyCode).toBe(23);
    });
    describe('the key mapping', function() {
      beforeEach(function() {
        return game.engine.init();
      });
      return it('maps up to thrust', function() {
        pressKey(38);
        return expect(game.engine.events[0].action).toBe('thrust');
      });
    });
    return describe('the update loop', function() {
      return it('consumes the events', function() {
        game.engine.init();
        moveMouseTo(47, 32);
        mouseDownAt(47, 32);
        game.engine.update();
        return expect(game.engine.events.length).toBe(0);
      });
    });
  });

}).call(this);

/*
//@ sourceMappingURL=initSpec.map
*/
