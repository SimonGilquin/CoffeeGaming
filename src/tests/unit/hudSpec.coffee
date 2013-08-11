describe 'The HUD', ->
  hud = null
  engine = null
  beforeEach ->
    game.load()
    game.engine.init()
    engine = game.engine
    hud = engine.hud
  it 'can be drawn', ->
    expect(typeof hud.draw).toBe 'function'
  it 'has a pause screen', ->
    expect(hud.pauseScreen).toBeDefined()
  describe 'when the game is paused', ->
    beforeEach ->
      engine.pause()
    it 'clicking on the resume button resumes the game', ->
      mouseDownAt 430, 330
      mouseUpAt 430, 330
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
      it 'should be hovered', ->
        moveMouseTo 430, 330
        engine.update()
        expect(hud.pauseScreen.resumeButton.isInElement 430, 330).toBeTruthy()
        expect(hud.pauseScreen.resumeButton.state).toBe 'hover'
      it 'when clicking it is active', ->
        mouseDownAt 430, 330
        engine.update()
        expect(hud.pauseScreen.resumeButton.state).toBe 'active'
      it 'is not active after leaving', ->
        moveMouseTo 430, 330
        moveMouseTo 230, 130
        engine.update()
        expect(hud.pauseScreen.resumeButton.isInElement 230, 130).toBeFalsy()
        expect(hud.pauseScreen.resumeButton.state).not.toBe 'hover'

  describe 'when the game is running', ->
    beforeEach ->
      engine.play()
    it 'has a pause button', ->
      expect(hud.pauseButton).toBeDefined()
      expect(hud.pauseButton.visible).toBeTruthy()
