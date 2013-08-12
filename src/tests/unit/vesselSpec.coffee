describe 'The vessel', ->
  engine = null
  oldImage = null
  beforeEach ->
    oldImage = window.Image
    window.Image = ImageHelper
    game.load()
    window.Image.loadAll()
    engine = game.engine
  afterEach ->
    window.Image = oldImage

  it 'when playing updates on game ticks', ->
    spyOn engine, 'updateVessel'
    engine.play()
    engine.update()
    expect(engine.updateVessel).toHaveBeenCalled()

  it 'does not update while paused', ->
    spyOn engine, 'updateVessel'
    engine.pause()
    engine.update()
    expect(engine.updateVessel).not.toHaveBeenCalled()

  it 'exists', ->
    expect(engine.vessel).toBeDefined()

  it 'has an acceleration of .1px/s', ->
    vessel = engine.createVessel()
    expect(vessel.acceleration).toBe .1

  it 'is stopped', ->
    vessel = engine.createVessel()
    expect(vessel.speed).toBe 0

  it 'is in the center of the screen', ->
    vessel = engine.createVessel()
    expect(vessel.position.x).toBe canvas.width/2
    expect(vessel.position.y).toBe canvas.height/2

  it 'moves horizontally when having speed', ->
    vessel = engine.createVessel()
    vessel.speed = 3
    x = vessel.position.x
    y = vessel.position.y
    engine.updateVessel vessel
    expect(vessel.position.x).toBe x + 3
    expect(vessel.position.y).toBe y
    engine.updateVessel vessel
    expect(vessel.position.x).toBe x + 6
    expect(vessel.position.y).toBe y

  it 'has a vector of 0', ->
    vessel = engine.createVessel()
    expect(vessel.vector).toBe 0

  it 'has a rotational speed of 0.01', ->
    vessel = engine.createVessel()
    expect(vessel.rotationalSpeed).toBe 0.01

  describe 'pressing the thrust key', ->
    beforeEach ->
      engine.play()
      engine.events.push
        type: 'keydown'
        action: 'thrust'
      engine.update()
    it 'thrusts the vessel', ->
      expect(engine.vessel.thrust).toBeTruthy()
    it 'increases the vessel speed', ->
      oldSpeed = engine.vessel.speed
      engine.update()
      expect(engine.vessel.speed).toBeGreaterThan oldSpeed
  describe 'pressing the left key', ->
    beforeEach ->
      engine.play()
      engine.events.push
        type: 'keydown'
        action: 'left'
      engine.update()
    it 'increases the vessel speed', ->
      oldVector = engine.vessel.vector
      engine.update()
      expect(engine.vessel.vector).toBeGreaterThan oldVector
  describe 'releasing the thrust', ->
    vessel = null
    beforeEach ->
      engine.keyboard.thrust = true
      engine.update()
    it 'does not thrusts', ->
      engine.keyboard.thrust = false
      engine.update()
      expect(engine.vessel.thrust).toBeFalsy()
    it 'keeps its speed', ->
      oldSpeed = engine.vessel.speed
      engine.keyboard.thrust = false
      engine.update()
      expect(engine.vessel.speed).toBe oldSpeed
