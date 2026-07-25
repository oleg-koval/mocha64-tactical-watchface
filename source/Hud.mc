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

    // Label small and grey, value large and white, status carried by a chip.
    // Luminance does the work the panel can actually deliver.
    function metricRow(
        dc as Dc, row as Number,
        label as String, value as String, chip as Number
    ) as Void {
        var y = Layout.columnY(row);

        dc.setColor(chip, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(
            Layout.CHIP_X, y + Layout.CHIP_INSET_Y,
            Layout.CHIP_W, Layout.CHIP_H
        );

        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.COL_LABEL_X, y + Layout.CHIP_INSET_Y,
            Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            Layout.COL_VALUE_X, y,
            Graphics.FONT_SMALL, value,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function footerRow(
        dc as Dc, label as String, value as String,
        labelY as Number, valueY as Number,
        labelX as Number, valueX as Number
    ) as Void {
        dc.setColor(Palette.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_XTINY, label,
            Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(Palette.VALUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(valueX, valueY, Graphics.FONT_SMALL, value,
            Graphics.TEXT_JUSTIFY_RIGHT);
    }
}
