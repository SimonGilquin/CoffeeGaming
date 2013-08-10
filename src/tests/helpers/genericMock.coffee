window.createMockFor = (type) ->
  mock = type.prototype
  for id, prop of mock when typeof prop == 'function'
    spyOn mock, id
  mock