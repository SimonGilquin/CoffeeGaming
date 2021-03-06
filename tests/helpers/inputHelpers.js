// Generated by CoffeeScript 1.6.2
(function() {
  window.moveMouseTo = function(x, y) {
    return window.getCanvas().onmousemove({
      offsetX: x,
      offsetY: y
    });
  };

  window.mouseUpAt = function(x, y) {
    return window.getCanvas().onmouseup({
      offsetX: x,
      offsetY: y
    });
  };

  window.mouseDownAt = function(x, y) {
    return window.getCanvas().onmousedown({
      offsetX: x,
      offsetY: y
    });
  };

  window.pressKey = function(keyCode) {
    return document.onkeydown({
      keyCode: keyCode
    });
  };

}).call(this);

/*
//@ sourceMappingURL=inputHelpers.map
*/
