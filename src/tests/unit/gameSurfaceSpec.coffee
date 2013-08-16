describe 'The game surface', ->
  surface = null

  beforeEach ->
    game.load()
    game.engine.init()
    surface = game.engine.surface

  it 'should be 4000 x 3000', ->
    expect(surface.width).toBe 4000
    expect(surface.height).toBe 3000
