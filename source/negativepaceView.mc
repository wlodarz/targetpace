using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;
using Toybox.Lang;

function speedToPace(speed) {
	var pace = 0.0;
	pace = 1000.0 / speed;
	return pace;
}


class negativepaceView extends WatchUi.DataField {

    hidden var mValue;
    hidden var mDisplayItem = 0;
    hidden var mNegativePaces = [ 4*60+25, 4*60+20, 4*60+15, 4*60 ];
    hidden var mLapStartTime; // in seconds
    hidden var mCurrentLap;
    hidden var mElapsedTime;
    hidden var mTargetPace;
    hidden var mCurrentPace;

    function initialize() {
        DataField.initialize();
        mValue = 0.0f;
        mLapStartTime = 0;
        mCurrentLap = 0;
        mElapsedTime = 0;
        mTargetPace = 0;
        mCurrentPace = 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));
            System.println("Layout1");

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));
            System.println("Layout2");

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));
            System.println("Layout3");

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));
            System.println("Layout4");

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 32;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY;
            System.println("Layout5");
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

		lapPace = 4*60+22;
        // See Activity.Info in the documentation for available information.
        if(info has :elapsedDistance 
        && info has :averageSpeed
        && info has :currentSpeed
        && info has :elapsedTime){
            if(info.elapsedDistance != null 
            && info.currentSpeed != null
            && info.averageSpeed != null
            && info.elapsedTime != null){
                var elapsedDistance = info.elapsedDistance;
                var elapsedTime = info.elapsedTime;
                var currentSpeed = info.averageSpeed; // currentSpeed;
                
                //mValue = info.elapsedDistance / 1000.0f;
                kilometer = Math.floor(elapsedDistance / 1000);
                lap = kilometer.toNumber();
                lapDistance = elapsedDistance - mCurrentLap * 1000;
                if (currentSpeed > 0) {
                	currentPace = speedToPace(currentSpeed);
                } else {
                	currentPace = 0;
                }
                if(lap > mCurrentLap){
                	System.println("old LAP " + mCurrentLap);
                	mCurrentLap = lap;
                	mLapStartTime = elapsedTime;
                	System.println("new LAP " + mCurrentLap + " dist " + elapsedDistance + " at " + mLapStartTime);
                }
                System.println("dist " + elapsedDistance + " time " + elapsedTime + " speed " + currentSpeed);
                //System.println(mNegativePaces[mCurrentLap] + " " + lapPace);
                mCurrentLap = lap;
                mElapsedTime = elapsedTime;
            }
        }
        if (mCurrentLap < mNegativePaces.size()) {
        	mTargetPace = mNegativePaces[mCurrentLap];
        } else {
        	mTargetPace = 300;
        }
        mCurrentPace = currentPace;
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    	var paceFlag = 1;
    
    	var currentPaceString = "0:00";
    	
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        
        // determine which value display
        var elapsedSeconds = mElapsedTime / 1000;
        paceFlag = elapsedSeconds % 10;
         
        // display proper value
        if (paceFlag >= 5) {
        	// targetPace
        	mValue = mTargetPace;
        	
        	if (getBackgroundColor() == Graphics.COLOR_BLACK) {
	            value.setColor(Graphics.COLOR_WHITE);
        	} else {
	            value.setColor(Graphics.COLOR_BLACK);
	        }
	        View.findDrawableById("label").setText(Rez.Strings.target);
        } else {
        	// currentPace
        	mValue = mCurrentPace;
        	
        	if (getBackgroundColor() == Graphics.COLOR_BLACK) {
	            value.setColor(Graphics.COLOR_WHITE);
        	} else {
	            value.setColor(Graphics.COLOR_BLUE);
        		if(mValue > 363) {
            		value.setColor(Graphics.COLOR_RED);
            	}
            	if(mValue < 357) {
	            	value.setColor(Graphics.COLOR_RED);
            	}
        	}
        	View.findDrawableById("label").setText(Rez.Strings.current);
        }
        
        var paceMinutes = (mValue / 60).toNumber();
        var paceSeconds = (mValue - (paceMinutes * 60)).toNumber();
        var paceString = "";
        
        paceString = Lang.format("$1$:$2$", [paceMinutes.format("%d"), paceSeconds.format("%02d")]);
        value.setText(paceString);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
}
