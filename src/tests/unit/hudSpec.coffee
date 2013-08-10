describe 'The HUD', ->
  hud = null
  beforeEach ->
    hud = game.hud
  it 'can be drawn', ->
    expect(typeof hud.draw).toBe 'function'
  describe 'when the game is paused', ->
    contextMock = null
    beforeEach ->
      game.pause()
      contextMock = createMockFor CanvasRenderingContext2D
    it 'should display "Game paused"', ->
      hud.draw()
      expect(contextMock.fillText).toHaveBeenCalledWith('Game paused', 500.5, 280)
      expect(contextMock.fillText).toHaveBeenCalledWith('Resume...', 500.5, 340)
