import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class FlappyWatchDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new FlappyWatchMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onTap(clickEvent) as Boolean {
        if (hit) {
            if (Time.now().value() - hittime > 0) {
                dy = 0.0;
                y = iy;
                flapping = 0;
                arms = [[sw+aw,(minarmy+maxarmy)/2]];
                hit = false;
                checking = false;
                score = 0;
                newgame = true;
                WatchUi.requestUpdate();
            }
        } else {
            if (newgame) {
                var xy = clickEvent.getCoordinates();
                if (xy[0] > sw*60/100) {
                    diff = (diff+1) % 3;
                    Storage.setValue("diff",diff);
                    WatchUi.requestUpdate();
                    return false;
                }
            }
            newgame = false;
            if (dy >= 0) { flapping = 1; }
            else { flapping = 3; }
            if (y == iy and dy == 0) {
                WatchUi.requestUpdate();
            }
        }
        return false;
    }

}