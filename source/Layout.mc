import Toybox.Lang;
import Toybox.Math;

module Layout {

    const SCREEN = 260;
    const CENTER = 130;

    const MARGIN = 14;

    // At y=30 the usable half-width is ~86px (x 44..216), so the status row is
    // inset well clear of the bezel curve rather than hugging the square edge.
    const STATUS_Y = 30;
    const STATUS_DATE_X = 48;
    const STATUS_BATTERY_X = 212;

    const DIVIDER_X = 116;
    const DIVIDER_TOP = 46;

    // Time is left-aligned to the same x as the date so the left column has one
    // hard edge; centring the digits left the two rows visibly out of step.
    const TIME_X = STATUS_DATE_X;
    const TIME_HH_Y = 74;
    const TIME_MM_Y = 122;

    const COL_LABEL_X = 130;
    const COL_VALUE_X = 200;
    const COL_TOP_Y = 54;
    const COL_STEP_Y = 25;
    const COL_ROWS = 4;

    const BB_BAR_X = 212;
    const BB_BAR_W = 30;
    const BB_BAR_H = 6;

    const RULE_Y = 158;

    const STEP_LABEL_X = 26;
    const STEP_Y = 170;
    const STEP_BAR_X = 78;
    const STEP_BAR_W = 100;
    const STEP_BAR_H = 7;
    const STEP_VALUE_X = 234;

    // The footer sits on one baseline: sparkline left, KCAL label and value
    // right. Y values are kept inside the circular boundary -- at y=202 the
    // usable half-width is ~92px, so content must stay within x 38..222.
    const FOOTER_Y = 200;
    const SPARK_X = 44;
    const SPARK_W = 68;
    const SPARK_H = 14;
    const SPARK_BUCKETS = 10;

    // "HR" hugs the sparkline it labels; a tick then separates it from the
    // calorie pair, so the two stop reading as one "HR KCAL" label.
    const FOOTER_HR_X = 116;
    const FOOTER_TICK_X = 146;
    const FOOTER_LABEL_X = 156;
    const FOOTER_VALUE_X = 214;

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

    function columnY(row as Number) as Number {
        return COL_TOP_Y + (row * COL_STEP_Y);
    }

    function barWidth(percent as Number, total as Number) as Number {
        if (percent <= 0) {
            return 0;
        }
        var w = (total * percent) / 100;
        return w > total ? total : w;
    }
}
