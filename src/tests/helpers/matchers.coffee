jasmine.Matchers.prototype.toBeEqualTo = (expected) ->
  ok = true
  for id, prop of expected
    ok = ok and @actual[id] == prop
  ok