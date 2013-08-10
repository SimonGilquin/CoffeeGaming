canvas = getCanvas()
window.moveMouseTo = (x, y) ->
  canvas.onmousemove
    offsetX: x
    offsetY: y