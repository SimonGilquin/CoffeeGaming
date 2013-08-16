describe 'The game surface', ->
  surface = null
  contextMock = null

  beforeEach ->
    game.load()
    game.engine.init()
    surface = game.engine.surface
    contextMock = createMockFor CanvasRenderingContext2D

  it 'should be 800 x 600', ->
    expect(surface.width).toBe 800
    expect(surface.height).toBe 600

  it 'has an initial scale of 1m/px', ->
    expect(surface.scale).toBe(1)

  it 'can drawLine lines', ->
    surface.drawLine 10, 20, 30, 40
    expect(contextMock.moveTo).toHaveBeenCalledWith 10.5, 20.5
    expect(contextMock.lineTo).toHaveBeenCalledWith 30.5, 40.5
    expect(contextMock.stroke).toHaveBeenCalled()

  it 'can be drawn', ->
    expect(typeof surface.draw).toBe 'function'

  describe 'when drawing', ->
    beforeEach ->
      spyOn game.engine.hud, 'draw'
      surface.draw()
    it 'should clear the screen', ->
      expect(contextMock.clearRect).toHaveBeenCalledWith 0, 0, canvas.width, canvas.height
    it 'should draw the HUD', ->
      expect(game.engine.hud.draw).toHaveBeenCalled()