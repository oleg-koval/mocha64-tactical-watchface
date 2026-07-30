import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

// On-device settings.
//
// AppBase.getSettingsView() has existed since API 3.2.0 and the SDK documents
// it as "only applicable to watch faces and data fields" -- a watch face CAN
// put a real menu on the watch.
//
// Every item here is a data slot, so unlike the sibling faces there are no
// toggles: the root menu is four rows, each opening the same metric list.
class SettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "MOCHA-64"});
        for (var i = 0; i < Settings.SLOT_COUNT; i += 1) {
            addItem(new WatchUi.MenuItem(
                "Row " + (i + 1).format("%d"),
                Metrics.title(Settings.slots[i]), i, {}));
        }
    }
}

// One list of every metric, reused by all four slots. The id IS the metric
// number, so the delegate needs no parallel table to drift out of step.
class SlotMenu extends WatchUi.Menu2 {
    function initialize(index as Number) {
        Menu2.initialize({:title => "Slot " + (index + 1).format("%d")});
        var current = Settings.slots[index];
        // Item positions are NOT metric ids: unavailable metrics are skipped,
        // so the row to focus has to be counted as the list is built.
        var row = 0;
        var focus = 0;
        for (var m = 0; m < Metrics.COUNT; m += 1) {
            // Sleep score only exists where the Complications API does.
            // Listing it on a fenix 6 offers a choice that can only read blank.
            if (!Metrics.isAvailable(m)) { continue; }
            addItem(new WatchUi.MenuItem(Metrics.title(m), null, m, {}));
            if (m == current) { focus = row; }
            row += 1;
        }
        // Open on the current choice rather than at the top of sixteen items,
        // so the menu answers "what is this slot showing?" without scrolling.
        setFocus(focus);
    }
}

class SlotMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _index as Number;
    private var _parent as WatchUi.MenuItem;

    function initialize(index as Number, parent as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _index = index;
        _parent = parent;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var metric = item.getId() as Number;
        Application.Properties.setValue(Settings.SLOT_KEYS[_index], metric);
        Settings.load();
        _parent.setSubLabel(Metrics.title(Settings.slots[_index]));
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        WatchUi.pushView(new SlotMenu(item.getId() as Number),
                         new SlotMenuDelegate(item.getId() as Number, item),
                         WatchUi.SLIDE_LEFT);
    }
}
