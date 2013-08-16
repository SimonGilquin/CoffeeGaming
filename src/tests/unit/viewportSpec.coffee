describe 'The main canvas', ->
  it 'has the size of the browser window', ->
    expect(canvas.width).toBe window.innerWidth
    expect(canvas.height).toBe window.innerHeight

describe 'The game viewport', ->
  engine = null
  beforeEach ->
    engine = game.engine
  it 'exists', ->
    expect(engine.viewport).toBeDefined()
  it 'has the same size as the canvas', ->
    expect(engine.viewport.width).toBe canvas.width
    expect(engine.viewport.height).toBe canvas.height
