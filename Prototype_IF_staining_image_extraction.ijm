// Read directory and find movies
setBatchMode("exit and display")
input = getDirectory("Input folder for images"); 
FileList = getFileList(input); // Get list of files

lst = newArray(0); // Getting list of movies within directory (filters out folders)
for (i=0; i < FileList.length; i++) {
	if (endsWith(FileList[i], ".nd2") == true) {
		lst = Array.concat(lst, FileList[i]);
	}
}

Array.print("Found these files: \n", lst);

// make output folder
output_folder = input+"output/";
print(output_folder);
if (File.isDirectory(output_folder)) {
	print("Directory already made, moving on...");
} else {
	File.makeDirectory(output_folder);
}

// Function to prompt Intensity choice
function chooseIntensity() {
	MinIntensity=80; MaxIntensity=1200;
 	Dialog.create("LUT");
  	Dialog.addNumber("MinIntensity:", MinIntensity);
  	Dialog.addNumber("MaxIntensity:", MaxIntensity);
  	Dialog.show();
  	MinIntensity = Dialog.getNumber();
  	MaxIntensity = Dialog.getNumber();
  	return newArray(MinIntensity, MaxIntensity);
}

// Start processing
for (file=0; file<lst.length; file++) { // Iterate over movie list
	
	// Open movie
	print("Opening movie"+lst[file]);
	path = input+lst[file];
	run("Bio-Formats Importer", "open="+path+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	dir = File.getParent(path);
	name = File.getNameWithoutExtension(path);
	print("Starting Maximum Intensity Projection of" + name);
	
	// Get size of movie
	getDimensions(width, height, channels, slices, frames);
	defaultValue = 1; // sets default value to 1
	run("Split Channels");
	
	// select movie based on name and channel suffix: i.e. C1-[movie name]
	selectImage("C1-"+name+".nd2");
	Stack.setPosition(1,1,round(frames/2)); // Go to middle slice
	
	if (i == 1) {
		// Check intensity values for Channel #1
		run("Brightness/Contrast...");
		waitForUser("Check your intensity thresholds and be ready to input them");
		C1_intensity_min = getNumber("Input minimum intensity for channel 1", defaultValue);
		C1_intensity_max = getNumber("Input maximum intensity for channel 2", defaultValue);
		close("B&C");
		selectImage("C1-"+name+".nd2");
		setMinAndMax(C1_intensity_min, C1_intensity_max);
	}
	else {
		selectImage("C1-"+name+".nd2");
		setMinAndMax(C1_intensity_min, C1_intensity_max);
	}
	
	selectImage("C2-"+name+".nd2");
	Stack.setPosition(1,1,round(frames/2);) // Go to middle slice
	
	if (i == 1) {
		// Check intensity values for Channel #2
		run("Brightness/Contrast...");
		waitForUser("Check your intensity thresholds and be ready to input them");
		C2_intensity_min = getNumber("Input minimum intensity for channel 2", defaultValue);
		C2_intensity_max = getNumber("Input maximum intensity for channel 2", defaultValue);
		close("B&C");
		selectImage("C2-"+name+".nd2");
		setMinAndMax(C2_intensity_min, C2_intensity_max);
	}
	else {
		selectImage("C2-"+name+".nd2");
		setMinAndMax(C2_intensity_min, C2_intensity_max);
	}
	
	// Make the number of slices that you cut user definable
	waitForUser("Find a range of in-focus frames: you should use the same frames selected for NIS analysis");
	frame1 = getNumber("prompt", defaultValue);
	frame2 = getNumber("prompt", defaultValue);
	run("Duplicate...", "duplicate slices="+frame1+"-"+frame2);	
	
	//MIP
	run("Merge Channels...", "c1=C1-"+name+" c2=C2-"+name+" create");
	run("Z Project...", "projection=[Max Intensity]");
	
	saveAs("png", output_folder + "/MIP_"+name);
}

