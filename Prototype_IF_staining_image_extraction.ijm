// Read directory and open movie stack 



// Get size of movie
getDimensions(width, height, channels, slices, frames);
run("Split Channels");

for (i=1; i<3; i++) { // Iterate over movie list
	
	// select movie based on name and channel suffix: i.e. C1-[movie name]
//	selectWindow("name");
	Stack.setPosition(1,1,round(frames/2);) // Go to middle slice
	
	if (i == 1) {
		// Check intensity values for Channel #1
		run("Brightness/Contrast...");
		waitForUser("Check your intensity thresholds and be ready to input them");
		C1_intensity_min = getNumber("prompt", defaultValue);
		C1_intensity_max = getNumber("prompt", defaultValue);
		close("B&C");
		setMinAndMax(C1_intensity_min, C1_intensity_max);
	}
	else {
		setMinAndMax(C1_intensity_min, C1_intensity_max);
	}
	
//	selectWindow("name");
	Stack.setPosition(1,1,round(frames/2);) // Go to middle slice
	
	if (i == 1) {
		// Check intensity values for Channel #2
		run("Brightness/Contrast...");
		waitForUser("Check your intensity thresholds and be ready to input them");
		C2_intensity_min = getNumber("prompt", defaultValue);
		C2_intensity_max = getNumber("prompt", defaultValue);
		close("B&C");
		setMinAndMax(C2_intensity_min, C2_intensity_max);
	}
	else {
		setMinAndMax(C2_intensity_min, C2_intensity_max);
	}
	
	// Make the number of slices that you cut user definable
	waitForUser("Find a range of in-focus frames");
	frame1 = getNumber("prompt", defaultValue);
	frame2 = getNumber("prompt", defaultValue);
	run("Duplicate...", "duplicate slices="+frame1+"-"+frame2);	
	
	//MIP
	run("Merge Channels...", "c1=C1"+ImageName+" c2=C2"+ImageName+" create");
	run("Z Project...", "projection=[Max Intensity]");
	
}





// save png????

