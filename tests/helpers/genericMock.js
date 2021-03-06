// Generated by CoffeeScript 1.6.3
(function() {
  window.createMockFor = function(type) {
    var id, mock, prop;
    mock = type.prototype;
    for (id in mock) {
      prop = mock[id];
      if (typeof prop === 'function') {
        spyOn(mock, id);
      }
    }
    return mock;
  };

}).call(this);
