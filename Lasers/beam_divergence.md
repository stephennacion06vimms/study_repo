# Beam Divergence

Imagine a beam of light as a stream of water coming out of a hose. **Beam divergence is simply how much that beam spreads out as it travels away from its source.**

The word "diverge" just means to spread apart or separate.

## The Everyday Example

*   **High Divergence (Spreads out quickly):** Think of a regular **flashlight**. When you shine it at a wall close to you, the circle of light is small. But if you shine it at a wall across the yard, the circle becomes huge and much dimmer. The beam is spreading out a lot.
*   **Low Divergence (Stays tight):** Think of a **laser pointer**. You can point it at a wall across the room, and the little red dot stays almost exactly the same size as when it left the pointer. The beam spreads out very slowly.

## Why does it matter?

*   **Sending information:** If you want to shoot a laser to the moon to measure the distance (which scientists actually do!), you need a laser with extremely *low* divergence. Otherwise, by the time the light reaches the moon, the beam would be so spread out and weak that you couldn't see it.
*   **Cutting things:** Industrial lasers used to cut metal need very low divergence to keep all their energy focused onto a tiny, super-hot spot.

**In summary:** Beam divergence is just the measure of how quickly a light beam goes from being a tight spotlight to a wide floodlight as it travels forward.

## Parallel vs. Perpendicular Divergence

In many common lasers (especially **laser diodes** found in electronics), the light doesn't come out as a perfectly round beam. Instead, the tiny "window" the light exits from is shaped like a very thin, flat rectangle.

Because of the physics of light (a property called diffraction), the beam spreads out differently depending on the direction:

*   **Parallel Divergence (Slow Axis):** This is the spread of the beam *parallel* to the flat, wide layer of the laser chip. The beam spreads out relatively slowly here, resulting in a **smaller angle**.
*   **Perpendicular Divergence (Fast Axis):** This is the spread of the beam *perpendicular* to that flat layer. Counter-intuitively, because the exit window is thinnest in this direction, the light spreads out very quickly, resulting in a **much larger angle**.

Because the beam spreads fast in one direction and slow in the other, it creates an **oval or elliptical shape** when shone on a surface, rather than a perfect circle.

### Understanding Your Parameters

When looking at laser specifications, you often see numbers grouped together, like the ones you provided:

*   10° / 45°
*   14° / 44°
*   14° / 44°
*   9° / 19°
*   16° / 35°
*   7-13° / 12-19° (This one just gives a range, depending on operating conditions)

These numbers represent the **Parallel (smaller angle) / Perpendicular (larger angle)** divergence.

**Taking "10° / 45°" as an example:**
*   **10°:** On its "slow" side, the beam spreads outward by 10 degrees.
*   **45°:** On its "fast" side, the beam spreads outward by a massive 45 degrees.

If you are building something that requires a tight, perfectly round laser beam, seeing a high perpendicular divergence (like 45°) means you will need to add special glass lenses to "squish" the beam back into a circle!
