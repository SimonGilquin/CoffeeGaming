// Generated by CoffeeScript 1.6.2
(function() {
  jasmine.Matchers.prototype.toBeEqualTo = function(expected) {
    var id, ok, prop;

    ok = true;
    for (id in expected) {
      prop = expected[id];
      ok = ok && this.actual[id] === prop;
    }
    return ok;
  };

}).call(this);

/*
//@ sourceMappingURL=matchers.map
*/