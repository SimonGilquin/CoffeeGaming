describe 'The HUD', ->
  hud = null
  beforeEach ->
    hud = game.hud
  it 'can be drawn', ->
    expect(typeof hud.draw).toBe 'function'
  it 'has a pause screen', ->
    expect(hud.pauseScreen).toBeDefined()
  describe 'when the game is paused', ->
    beforeEach ->
      game.pause()
    describe 'the pause screen', ->
      screen = null
      beforeEach ->
        screen = hud.pauseScreen
      it 'should be visible', ->
        expect(screen.visible).toBeTruthy()
      it 'should display "Game paused"', ->
        expect(screen.text.text).toBe 'Game paused'
        expect(screen.text.style).toBe 'black'
        expect(screen.text.font).toBe '48px sans-serif'
      describe 'when drawn', ->
        contextMock = null
        beforeEach ->
          contextMock = createMockFor CanvasRenderingContext2D
        it 'should have the correct elements', ->
          hud.draw()
          expect(contextMock.fillText).toHaveBeenCalledWith('Game paused', 500.5, 280)
          expect(contextMock.fillText).toHaveBeenCalledWith('Resume...', 500, 340)

      describe 'when the mouse is over the resume button', ->
        it 'should be highlighted', ->
          moveMouseTo 430, 330
          game.update()
  #        expect(hud.pauseScreen.resumeButton.color).toBe '00dddd'