using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;
using Toybox.Lang;

function toPace(speed) {
	var pace = 0.0;
	pace = 1000.0 / speed;
	return pace;
}


class negativepaceView extends WatchUi.DataField {

    hidden var mValue;
    hidden var mDisplayItem = 0;
    hidden var mNegativePaces = [ 4.25f, 4.20f, 4.15f, 4.0f ];
    hidden var mLapStartTime; // in seconds
    hidden var mCurrentLap;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        mLapStartTime = 0;
        mCurrentLap = 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    	var lap;
    	var kilometer;
    	var lapDistance;
    	var lapPace;
    	var currentPace = 0.0;

		lapPace = 4.22;
        // See Activity.Info in the documentation for available information.
        if(info has :elapsedDistance){
            if(info.elapsedDistance != null){
                var activityDistance = info.elapsedDistance;
                var activityTime = info.elapsedTime;
                
                //mValue = info.elapsedDistance / 1000.0f;
                kilometer = Math.floor(info.elapsedDistance / 1000);
                lap = kilometer.toNumber();
                lapDistance = activityDistance - mCurrentLap * 1000;
                currentPace = toPace(info.currentSpeed);
                if(lap > mCurrentLap){
                	System.println("old LAP " + mCurrentLap);
                	mCurrentLap = lap;
                	mLapStartTime = info.elapsedTime;
                	System.println("new LAP " + mCurrentLap + " dist " + activityDistance + " at " + mLapStartTime);
                }
                System.println("dist " + activityDistance + " time " + activityTime + " speed " + info.currentSpeed);
                //System.println(mNegativePaces[mCurrentLap] + " " + lapPace);
            }
        }
        mValue = currentPace;
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    
    	var currentPaceString = "0:00";
    	
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_GREEN);
        	if(mValue > 363) {
            	value.setColor(Graphics.COLOR_RED);
            }
            if(mValue < 357) {
            	value.setColor(Graphics.COLOR_RED);
            }
        }

        var paceMinutes = (mValue / 60).toNumber();
        var paceSeconds = (mValue - (paceMinutes * 60)).toNumber();
        currentPaceString = Lang.format("$1$:$2$", [paceMinutes.format("%d"), paceSeconds.format("%02d")]); 

        value.setText(currentPaceString);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
    
    function onTimerLap() {
    	mCurrentLap++;
    	System.println("LAP " + mCurrentLap);
    }
}
