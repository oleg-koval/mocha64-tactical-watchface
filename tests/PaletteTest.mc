import Toybox.Lang;
import Toybox.Test;

module PaletteTest {

    (:test)
    function everyPaletteColorIsLatticeExact(logger as Logger) as Boolean {
        var colors = [
            Palette.BG, Palette.PANEL, Palette.RULE, Palette.LABEL,
            Palette.VALUE, Palette.READY, Palette.CAUTION,
            Palette.STRAIN, Palette.DATA
        ];
        for (var i = 0; i < colors.size(); i += 1) {
            if (!Palette.isLatticeExact(colors[i])) {
                logger.debug("not lattice-exact: " + colors[i].format("%06X"));
                return false;
            }
        }
        return true;
    }

    (:test)
    function catppuccinTextShiftsToCyan(logger as Logger) as Boolean {
        return Palette.quantize(0xCDD6F4) == 0xAAFFFF;
    }

    (:test)
    function catppuccinRedGoesPastel(logger as Logger) as Boolean {
        return Palette.quantize(0xF38BA8) == 0xFFAAAA;
    }

    (:test)
    function quantizeIsIdempotent(logger as Logger) as Boolean {
        var once = Palette.quantize(0x1E1E2E);
        return Palette.quantize(once) == once;
    }
}
