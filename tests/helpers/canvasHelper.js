// Generated by CoffeeScript 1.6.3
(function() {
  var ImageHelper,
    __slice = [].slice;

  window.getCanvas = function() {
    return document.getElementsByTagName('canvas')[0];
  };

  CanvasRenderingContext2D.prototype.drawImage = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  };

  window.requestAnimationFrame = window.webkitRequestAnimationFrame = function() {};

  ImageHelper = (function() {
    function ImageHelper() {
      ImageHelper.items.push(this);
    }

    ImageHelper.items = [];

    ImageHelper.loadAll = function() {
      var item, _i, _len, _ref, _results;
      _ref = ImageHelper.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(item.onload());
      }
      return _results;
    };

    return ImageHelper;

  })();

  window.ImageHelper = ImageHelper;

}).call(this);
