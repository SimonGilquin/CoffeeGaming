describe 'The game', ->
  it 'should have a surface', ->
    expect(game.surface).toBeDefined()
  it 'can be initialized', ->
    expect(game.init).toBeDefined()
  it 'has a HUD', ->
    expect(game.hud).toBeDefined()
  it 'should be paused by default', ->
    expect(game.isPaused()).toBeTruthy()
  describe 'when paused', ->
    beforeEach ->
      game.pause()
    it 'can be resumed', ->
      game.play()
      expect(game.isPaused()).toBeFalsy()
  describe 'when started', ->
    beforeEach ->
      game.play()
    it 'can be paused', ->
      game.pause()
      expect(game.isPaused()).toBeTruthy()
