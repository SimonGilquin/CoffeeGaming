describe 'The main window', ->
  it 'should have one canvas', ->
    canvas = document.getElementsByTagName('canvas')
    expect(canvas.length).toEqual 1
  it 'should have a game', ->
    expect(game).toBeDefined()