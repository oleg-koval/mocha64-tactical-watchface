import Toybox.Graphics;
import Toybox.Lang;

// Always-on display, for AMOLED products only.
//
// A MIP panel costs nothing to leave lit -- it reflects ambient light and holds
// its last frame with no backlight. An AMOLED panel emits, so every lit pixel
// burns current and, held in one place, burns the pixel. Garmin requires
// burn-in-protected devices to show a restricted frame between wrist raises,
// and rejects faces that ignore it.
//
// The frame is a DIFFERENT DRAWING, not a dimmed one. This face is a HUD: two
// rules, a divider, four recovery rows, two footer rows, a goal bar and a date
// block, all of it in fixed positions. Every one of those is static furniture
// -- the exact shape that burns in -- and none of it is what a wearer wants
// from a wrist they have not raised.
//
// So the always-on frame is the time and nothing else. The rules go, the
// columns go, the readings go.
//
// The time keeps its two-line block and its font. It could be made smaller,
// and that would be a mistake: a font tier is not a pixel budget, and an
// always-on frame that reads as a different watch defeats the point of
// glancing at it. Two lines of digits is roughly five percent of the panel,
// comfortably inside Garmin's guidance, and it moves.
module Aod {

    // Coprime shift periods. Horizontal cycles over 7 minutes and vertical
    // over 5, so the pair visits 35 positions before repeating rather than
    // parking a glyph edge on the same pixels every seventh minute.
    const SHIFT_PERIOD = 7;
    const SHIFT_PERIOD_Y = 5;

    // One lattice step above black. Legible in a dark room without lighting
    // the panel, which is the whole point of the mode.
    const DIM = 0x555555;

    function shiftX(minute as Number) as Number {
        return (minute % SHIFT_PERIOD) - (SHIFT_PERIOD / 2);
    }

    function shiftY(minute as Number) as Number {
        return (minute % SHIFT_PERIOD_Y) - (SHIFT_PERIOD_Y / 2);
    }

    function draw(dc as Graphics.Dc, hour as Number, minute as Number) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Derived from the real glyph height, exactly as the lit face does it.
        // A hardcoded Y here would be the same bug that once put this face's
        // goal bar through its STEPS label, except invisible -- it would only
        // ever be wrong on a screen nobody is looking at.
        var timeH = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
        var pitch = Layout.timeLinePitch(timeH);

        // The lit face's time block starts below the date rows. With the date
        // gone the block would sit oddly high against an otherwise empty
        // screen, so it is centred on the dial instead -- the one deliberate
        // difference in position, and the reason this does not just reuse the
        // view's Y derivation.
        var blockH = pitch + timeH;
        var top = Layout.CENTER - (blockH / 2) + shiftY(minute);
        var x = Layout.TIME_X + shiftX(minute);
        var firstCenter = top + (timeH / 2);

        dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, firstCenter, Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatHour(hour),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x, firstCenter + pitch, Graphics.FONT_NUMBER_MEDIUM,
            Fields.formatMinute(minute),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
