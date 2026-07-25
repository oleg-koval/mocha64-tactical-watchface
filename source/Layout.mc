import Toybox.Lang;
import Toybox.Math;

module Layout {

    const SCREEN = 260;
    const CENTER = 130;

    const STATUS_Y = 26;
    const STATUS_DATE_X = 46;
    const STATUS_BATTERY_X = 214;

    const TIME_X = STATUS_DATE_X;
    const TIME_HH_Y = 78;
    const TIME_MM_Y = 126;

    const DIVIDER_X = 112;
    const DIVIDER_TOP = 50;
    const DIVIDER_BOTTOM = 162;   // meets RULE_Y so the two rules form one frame

    // Status colour rides a chip beside the label, never the value itself:
    // a coloured pixel on a transflective panel reflects only its own channel,
    // so colouring a number makes the thing you read the dimmest thing on screen.
    const CHIP_X = 120;
    const CHIP_W = 5;
    const CHIP_H = 13;
    const CHIP_INSET_Y = 4;

    const COL_LABEL_X = 132;
    const COL_VALUE_X = 228;
    const COL_TOP_Y = 54;
    const COL_STEP_Y = 27;
    const COL_ROWS = 4;

    const RULE_Y = 162;
    const RULE_FROM = 30;
    const RULE_TO = 230;

    const STEP_LABEL_X = 34;
    const STEP_LABEL_Y = 176;
    const STEP_VALUE_X = 226;
    const STEP_VALUE_Y = 170;
    const STEP_BAR_X = 34;
    const STEP_BAR_Y = 192;
    const STEP_BAR_W = 192;
    const STEP_BAR_H = 7;

    const KCAL_LABEL_X = 40;
    const KCAL_LABEL_Y = 210;
    const KCAL_VALUE_X = 220;
    const KCAL_VALUE_Y = 204;

    function columnY(row as Number) as Number {
        return COL_TOP_Y + (row * COL_STEP_Y);
    }

    // Widest half-chord of the round screen at a given y, so a row can be
    // checked against the bezel curve instead of the 260x260 square.
    function halfWidthAt(y as Number) as Number {
        var dy = y - CENTER;
        var inside = (CENTER * CENTER) - (dy * dy);
        if (inside <= 0) {
            return 0;
        }
        return Math.sqrt(inside).toNumber();
    }

    function barWidth(percent as Number, total as Number) as Number {
        if (percent <= 0) {
            return 0;
        }
        var w = (total * percent) / 100;
        return w > total ? total : w;
    }
}
