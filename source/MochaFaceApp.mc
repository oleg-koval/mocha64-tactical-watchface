import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MochaFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        Settings.load();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new MochaFaceView()];
    }

    // Fired when settings are pushed from the Connect app. Without this the
    // face keeps its old rows until the watch face is reselected.
    function onSettingsChanged() as Void {
        Settings.load();
        WatchUi.requestUpdate();
    }

    // On-device settings. The signature must match AppBase exactly, "or Null"
    // included -- the compiler rejects an override returning a narrower type.
    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [new SettingsMenu(), new SettingsMenuDelegate()];
    }
}
