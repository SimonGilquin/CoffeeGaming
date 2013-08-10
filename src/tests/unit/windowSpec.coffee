describe 'The main window', ->
  describe 'upon startup', ->
    it 'should have one canvas', ->
      canvas = document.getElementsByTagName('canvas')
      expect(canvas.length).toEqual 1
  it 'should have a game', ->
    expect(game).not.toBeNull()