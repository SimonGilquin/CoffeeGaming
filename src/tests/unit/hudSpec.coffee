require ['game'], (game) ->
  describe 'The HUD', ->
    hud = null
    inResume = null
    engine = null
    beforeEach ->
      game.engine = engine = new Engine()
      game.engine.init()
      hud = engine.hud
      inResume =
        x: hud.pauseScreen.resumeButton.x + 10
        y: hud.pauseScreen.resumeButton.y + 10
    it 'can be drawn', ->
      expect(typeof hud.draw).toBe 'function'
    it 'has a pause screen', ->
      expect(hud.pauseScreen).toBeDefined()
    describe 'when the game is paused', ->
      beforeEach ->
        engine.pause()
      it 'clicking on the resume button resumes the game', ->
        mouseDownAt inResume.x, inResume.y
        mouseUpAt inResume.x, inResume.y
        engine.update()
        expect(engine.isPaused()).toBeFalsy()

      describe 'the pause screen', ->
        screen = null
        beforeEach ->
          screen = hud.pauseScreen
        it 'should be visible', ->
          expect(screen.visible).toBeTruthy()
        it 'should display "Game paused"', ->
          expect(screen.text.text).toBe 'Game paused'
          expect(screen.text.style).toBe 'white'
          expect(screen.text.font).toBe '48px sans-serif'
        describe 'when drawn', ->
          contextMock = null
          beforeEach ->
            contextMock = createMockFor CanvasRenderingContext2D
          it 'should have the correct elements', ->
            hud.draw()
            expect(contextMock.fillText).toHaveBeenCalledWith('Game paused', canvas.width / 2, 280)
            expect(contextMock.fillText).toHaveBeenCalledWith('Resume...', canvas.width / 2, 340)

      describe 'when the mouse is over the resume button', ->
        it 'should be hovered', ->
          moveMouseTo inResume.x, inResume.y
          engine.update()
          expect(hud.pauseScreen.resumeButton.isInElement inResume.x, inResume.y + 10).toBeTruthy()
          expect(hud.pauseScreen.resumeButton.state).toBe 'hover'
        it 'when clicking it is active', ->
          mouseDownAt inResume.x, inResume.y
          engine.update()
          expect(hud.pauseScreen.resumeButton.state).toBe 'active'
        it 'is not active after leaving', ->
          moveMouseTo inResume.x, inResume.y
          moveMouseTo 10,10
          engine.update()
          expect(hud.pauseScreen.resumeButton.isInElement 10,10).toBeFalsy()
          expect(hud.pauseScreen.resumeButton.state).not.toBe 'hover'

    describe 'when the game is running', ->
      beforeEach ->
        engine.play()
      it 'has a pause button', ->
        expect(hud.pauseButton).toBeDefined()
        expect(hud.pauseButton.visible).toBeTruthy()
