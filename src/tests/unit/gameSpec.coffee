describe 'The game engine', ->
  engine = game.engine
  beforeEach ->
    game.load()
    engine.init()
  it 'should have a surface', ->
    expect(engine.surface).toBeDefined()
  it 'can be initialized', ->
    expect(engine.init).toBeDefined()
    expect(typeof engine.init).toBe 'function'
  it 'has a HUD', ->
    expect(engine.hud).toBeDefined()
  it 'should be paused by default', ->
    expect(engine.isPaused()).toBeTruthy()
  it 'can be updated', ->
    expect(typeof engine.update).toBe 'function'
  describe 'when paused', ->
    beforeEach ->
      engine.pause()
    it 'can be resumed', ->
      engine.play()
      expect(engine.isPaused()).toBeFalsy()
  describe 'when started', ->
    beforeEach ->
      engine.play()
    it 'can be paused', ->
      engine.pause()
      expect(engine.isPaused()).toBeTruthy()
  xdescribe 'performance counters', ->
    it 'should work when there is no performance.now()', ->
      old = window.performance
      window.performance = null
      engine.init()
      window.performance = old