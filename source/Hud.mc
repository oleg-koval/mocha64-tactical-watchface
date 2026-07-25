import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

module Hud {

    const TICK = 9;

    function cornerTicks(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var inset = 34;

        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        dc.drawLine(inset, inset + TICK, inset, inset);
        dc.drawLine(inset, inset, inset + TICK, inset);

        dc.drawLine(w - inset - TICK, inset, w - inset, inset);
        dc.drawLine(w - inset, inset, w - inset, inset + TICK);

        dc.drawLine(inset, h - inset - TICK, inset, h - inset);
        dc.drawLine(inset, h - inset, inset + TICK, h - inset);

        dc.drawLine(w - inset - TICK, h - inset, w - inset, h - inset);
        dc.drawLine(w - inset, h - inset, w - inset, h - inset - TICK);

        dc.setPenWidth(1);
    }

    function verticalRule(dc as Dc, x as Number, top as Number, bottom as Number) as Void {
        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, top, x, bottom);
    }

    function horizontalRule(dc as Dc, y as Number, from as Number, to as Number) as Void {
        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(from, y, to, y);
    }

    function bar(
        dc as Dc,
        x as Number,
        y as Number,
        width as Number,
        height as Number,
        percent as Number,
        fill as Number
    ) as Void {
        dc.setColor(Palette.RULE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, width, height);

        var filled = Layout.barWidth(percent, width - 2);
        if (filled > 0) {
            dc.setColor(fill, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x + 1, y + 1, filled, height - 2);
        }
    }

    function sparkline(
        dc as Dc,
        x as Number,
        y as Number,
        width as Number,
        height as Number,
        samples as Array<Number>
    ) as Void {
        if (samples.size() < 2) {
            return;
        }

        var low = samples[0];
        var high = samples[0];
        for (var i = 1; i < samples.size(); i += 1) {
            if (samples[i] < low) { low = samples[i]; }
            if (samples[i] > high) { high = samples[i]; }
        }

        var span = high - low;
        if (span <= 0) {
            span = 1;
        }

        var step = width / (samples.size() - 1);
        dc.setColor(Palette.DATA, Graphics.COLOR_TRANSPARENT);

        for (var i = 0; i < samples.size() - 1; i += 1) {
            var y1 = y + height - (((samples[i] - low) * height) / span);
            var y2 = y + height - (((samples[i + 1] - low) * height) / span);
            dc.drawLine(x + (i * step), y1, x + ((i + 1) * step), y2);
        }
    }

    function labelValue(
        dc as Dc,
        labelX as Number,
        valueX as Number,
        y as Number,
        label as String,
        value as String,
        valueColor as Number
    ) as Void {
        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(valueX, y, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
