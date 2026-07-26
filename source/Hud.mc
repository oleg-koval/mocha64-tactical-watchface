import Toybox.Graphics;
import Toybox.Lang;

module Hud {

    function verticalRule(dc as Dc, x as Number, top as Number, bottom as Number) as Void {
        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, top, x, bottom);
    }

    function horizontalRule(dc as Dc, y as Number, from as Number, to as Number) as Void {
        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(from, y, to, y);
    }

    function bar(
        dc as Dc, x as Number, y as Number,
        width as Number, height as Number,
        percent as Number, fill as Number
    ) as Void {
        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, width, height);

        var filled = Layout.barWidth(percent, width - 2);
        if (filled > 0) {
            dc.setColor(fill, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x + 1, y + 1, filled, height - 2);
        }
    }

    // Label small and grey, value carrying its own status colour. The label is
    // centred on the value's midline so a shorter label glyph can never sit
    // proud of the number it belongs to.
    function metricRow(
        dc as Dc, y as Number,
        label as String, value as String, valueColor as Number
    ) as Void {
        var valueH = dc.getFontHeight(Graphics.FONT_TINY);
        var labelH = dc.getFontHeight(Graphics.FONT_XTINY);

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.COL_LABEL_X, y + ((valueH - labelH) / 2),
            Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.COL_VALUE_X, y,
            Graphics.FONT_TINY, value,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    // Label and value are centred on one shared midline computed from the real
    // glyph height, so nothing can drift into anything else when the font
    // metrics differ from what a constants table assumed.
    function footerRow(
        dc as Dc, rowTop as Number,
        labelX as Number, valueX as Number,
        label as String, value as String
    ) as Number {
        // Footer values sit at label size. Steps and calories are the least
        // urgent numbers here, and the bottom of a round face is where the
        // bezel curve leaves the least room -- a taller font down here is what
        // pushed this row off the screen entirely.
        var valueH = dc.getFontHeight(Graphics.FONT_XTINY);
        var midline = rowTop + (valueH / 2);

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, rowTop, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(valueX, rowTop, Graphics.FONT_XTINY, value,
            Graphics.TEXT_JUSTIFY_RIGHT);

        return midline;
    }

    // An empty outline track reads as a stray rule, so the track is drawn as a
    // filled recess and the progress sits on top of it.
    function inlineBar(
        dc as Dc, midline as Number,
        x as Number, width as Number, height as Number,
        percent as Number
    ) as Void {
        var y = midline - (height / 2);

        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, width, height);

        var filled = Layout.barWidth(percent, width);
        if (filled > 0) {
            dc.setColor(Fields.goalColor(percent), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, y, filled, height);
        }
    }
}
