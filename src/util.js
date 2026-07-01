// Small shared helpers.

// Inset a Phaser.Geom.Rectangle towards its centre by factor f (0..1).
function inset(rect, f) {
  if (f >= 1) return rect;
  const dw = (rect.width * (1 - f)) / 2;
  const dh = (rect.height * (1 - f)) / 2;
  rect.x += dw;
  rect.y += dh;
  rect.width -= dw * 2;
  rect.height -= dh * 2;
  return rect;
}

// Axis-aligned bounding-box overlap test between two display objects.
// `shrink` tightens both hitboxes a little so collisions feel fair (default 0.7).
export function overlap(a, b, shrink = 0.7) {
  const ra = inset(a.getBounds(), shrink);
  const rb = inset(b.getBounds(), shrink);
  return Phaser.Geom.Intersects.RectangleToRectangle(ra, rb);
}
