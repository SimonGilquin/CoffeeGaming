// Generated by CoffeeScript 1.6.3
(function() {
  var file, tests,
    __hasProp = {}.hasOwnProperty;

  tests = (function() {
    var _ref, _results;
    _ref = window.__karma__.files;
    _results = [];
    for (file in _ref) {
      if (!__hasProp.call(_ref, file)) continue;
      if (/Spec\.js$/.test(file)) {
        _results.push(file);
      }
    }
    return _results;
  })();

  requirejs.config({
    baseUrl: '/base/js',
    deps: tests,
    callback: window.__karma__.start
  });

}).call(this);
