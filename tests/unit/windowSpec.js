// Generated by CoffeeScript 1.6.3
(function() {
  require(['game'], function(game) {
    return describe('The main window', function() {
      it('should have one canvas', function() {
        var canvas;
        canvas = getCanvas();
        return expect(canvas).toBeDefined();
      });
      return it('should have a game', function() {
        return expect(game).toBeDefined();
      });
    });
  });

}).call(this);
