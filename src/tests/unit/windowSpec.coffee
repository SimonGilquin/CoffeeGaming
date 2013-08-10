describe 'The main window', ->
  it 'should have one canvas', ->
    canvas = getCanvas()
    expect(canvas).toBeDefined()
  it 'should have a game', ->
    expect(game).toBeDefined()