define ['game'], (game) ->
  describe 'The main canvas', ->
    it 'has the size of the browser window', ->
      canvas = getCanvas()
      expect(canvas.width).toBe window.innerWidth
      expect(canvas.height).toBe window.innerHeight

  describe 'The game viewport', ->
    engine = null
    viewport = null
    contextMock = null
    canvas = null
    beforeEach ->
      engine = game.engine
      viewport = engine.viewport
      contextMock = createMockFor CanvasRenderingContext2D
      canvas = getCanvas()
    it 'exists', ->
      expect(engine.viewport).toBeDefined()
    it 'has the same size as the canvas', ->
      expect(engine.viewport.width).toBe canvas.width
      expect(engine.viewport.height).toBe canvas.height

    it 'is positioned on center of the game surface', ->
      expect(viewport.x).toBe(engine.surface.width / 2 - canvas.width / 2)
      expect(viewport.y).toBe(engine.surface.height / 2 - canvas.height / 2)

    it 'can be drawn', ->
      expect(viewport.draw).toBeDefined()
      expect(typeof viewport.draw).toBe 'function'

    describe 'when drawing', ->
      beforeEach ->
        spyOn game.engine.hud, 'draw'
        viewport.draw()
      it 'should clear the screen', ->
        expect(contextMock.clearRect).toHaveBeenCalledWith 0, 0, canvas.width, canvas.height
      it 'should draw the HUD', ->
        expect(game.engine.hud.draw).toHaveBeenCalled()