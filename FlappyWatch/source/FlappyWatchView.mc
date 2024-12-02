import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Timer;
import Toybox.Application.Storage;

var ds = System.getDeviceSettings();
var sw = ds.screenWidth;
var sh = ds.screenHeight;
var timer;
var watchup = WatchUi.loadResource(Rez.Drawables.watchUp);
var watchdown = WatchUi.loadResource(Rez.Drawables.watchDown);
var watchflat = WatchUi.loadResource(Rez.Drawables.watchFlat);
var ww = watchup.getWidth();
var wh = watchup.getHeight();
var armtop = WatchUi.loadResource(Rez.Drawables.armTop);
var armbot = WatchUi.loadResource(Rez.Drawables.armBottom);
var armtopwat = WatchUi.loadResource(Rez.Drawables.armTopWatch);
var armbotwat = WatchUi.loadResource(Rez.Drawables.armBottomWatch);
var armholetopback = WatchUi.loadResource(Rez.Drawables.armHoleTopBack);
var armholetopfront = WatchUi.loadResource(Rez.Drawables.armHoleTopFront);
var armholebotback = WatchUi.loadResource(Rez.Drawables.armHoleBottomBack);
var armholebotfront = WatchUi.loadResource(Rez.Drawables.armHoleBottomFront);
var aw = armtop.getWidth();
var ah = armtop.getHeight();
var dy = 0.0;
var iy = sh*85/100;
var x = sw/3;
var y = iy;
var dym = sh*7/100;
var flapping = 0;
var minarmy = sh*30/100;
var maxarmy = sh*60/100;
var armdx = sw*2/100;
var arms = [];
var hit = false;
var hittime = 0;
var checking = false;
var score = 0;
var scorex = sw*15/100;
var scorey = sh*30/100;
var diff = 0;
var highscores = [0,0,0];
var hscorex = sw*60/100;
var hscorey = scorey;
var newgame = true;
var startx = sw/3;
var starty = sw*60/100;
var holeyt = -1*sw*5/100;
var holeyb = sw*90/100;

class FlappyWatchView extends WatchUi.View {

    function initialize() {
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        diff = Storage.getValue("diff");
        if (diff == null) { diff = 0; }
        highscores = Storage.getValue("highscores");
        if (highscores == null) { highscores = [0,0,0]; }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        if ((y != iy or dy != 0 or flapping > 0) and !hit) {
            timer = new Timer.Timer();
            timer.start(method(:onTimer), 50, false);
        }
        dc.setColor(0,0xd0dce0);
        dc.clear();

        dc.setColor(0x646f73,-1);
        dc.fillRectangle(0,0,sw,sh*10/100);
        dc.fillRectangle(0,sh*80/100,sw,sh*20/100);

        y += dy;
        if (y > iy) {
            y = iy;
            dy = 0.0;
        }

        var gap = wh*200/100 - wh*25*diff/100;
        var highscore = highscores[diff];

        if (newgame) {
            arms = [[sw*75/100,sh/2]];
        }
        if (arms[0][0] < 0-aw) {
            arms = arms.slice(1,null);
        }
        if (arms[arms.size()-1][0] < sw/2) {
            arms.add([sw+aw,Math.rand() % (maxarmy-minarmy) + minarmy]);
        }
        var inrange = false;
        for (var i=0;i<arms.size();i++) {
            var topy = arms[i][1]-ah-gap/2;
            var boty = arms[i][1]+gap/2;
            var topimg = armtop;
            var botimg = armbot;
            arms[i][0] -= armdx;
            var armx = arms[i][0];
            var army = arms[i][1];
            if ((armx-x).abs() <= ww/3) {
                inrange = true;
                checking = true;
                if (y-wh/3 < army-gap/2 or y+wh/3 > army+gap/2) {
/*
System.println("armx / army = "+armx+" / "+army);
System.println("watx / waty = "+x+" / "+y.toNumber());
System.println("watw / wath = "+ww+" / "+wh);
System.println("gap = "+gap);
System.println("gap range  = "+(army-gap/2)+" to "+(army+gap/2));
System.println("watch area = "+(y-wh/3)+" to "+(y+wh/3));
*/
                    hit = true;
                    timer.stop();
                    hittime = Time.now().value();
                    if (y > arms[i][1]) {
                        botimg = armbotwat;
                    } else {
                        topimg = armtopwat;
                    }
                }
            }
            dc.drawBitmap(arms[i][0]-aw/2,holeyt,armholetopback);
            dc.drawBitmap(arms[i][0]-aw/2,holeyb,armholebotback);
            dc.drawBitmap(arms[i][0]-aw/2,topy,topimg);
            dc.drawBitmap(arms[i][0]-aw/2,boty,botimg);
            dc.drawBitmap(arms[i][0]-aw/2,holeyt,armholetopfront);
            dc.drawBitmap(arms[i][0]-aw/2,holeyb,armholebotfront);
        }
        if (checking and !inrange) {
            score++;
            checking = false;
        }

        dc.setColor(0,-1);
        if (newgame) {
            dc.drawText(scorex, scorey, Graphics.FONT_SMALL, "High: "+highscore, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(startx, starty, Graphics.FONT_SMALL, "Tap to\nFlap", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            var tmp;
            if (diff == 0) { tmp = "Easy"; }
            else if (diff == 1) { tmp = "Medium"; }
            else { tmp = "Hard"; }
            dc.drawText(sw*74/100, sh/2, Graphics.FONT_XTINY, tmp+"\n(tap)", Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(scorex, scorey, Graphics.FONT_SMALL, score, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if (hit) {
            if (score > highscore) {
                highscore = score;
                highscores[diff] = highscore;
                Storage.setValue("highscores",highscores);
            }
        } else {
            if (dy > 0) { dy += dy*.4; }
            if (dy > -3 and dy <= 0 and y < iy) { dy = 1.0; }
            if (dy < 0) { dy -= dy*.4; }
            if (dy > dym) { dy = dym; }

            if (flapping > 0) {
                dc.drawBitmap(x, y, watchup);
                flapping--;
                if (flapping == 0) {
                    dy = 0-dym;
                }
            } else if (y == iy) {
                dc.drawBitmap(x-ww/2, y-wh/2, watchflat);
            } else if (dy > -4 and dy < 4) {
                dc.drawBitmap(x-ww/2, y-wh/2, watchflat);
            } else if (dy > 0) {
                dc.drawBitmap(x-ww/2, y-wh/2, watchup);
            } else {
                dc.drawBitmap(x-ww/2, y-wh/2, watchdown);
            }
        }
    }

    function onTimer() as Void {
        WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
