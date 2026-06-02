// Read directory and find movies
setBatchMode("exit and display")
input = getDirectory("Input folder for images"); 
FileList = getFileList(input); // Get list of files

// Getting list of movies within directory (filters out folders)
lst = newArray(0); 
for (i=0; i < FileList.length; i++) {
	if (endsWith(FileList[i], ".nd2") == true) {
		lst = Array.concat(lst, FileList[i]);
	}
}
Array.print("Found these files: \n", lst);

// Make output folder
output_folder = input+"output/";
print(output_folder);
if (File.isDirectory(output_folder)) {
	print("Directory already made, moving on...");
} else {
	File.makeDirectory(output_folder);
}

// Default values
default_intensities = newArray(65, 1200);
default_frames = newArray(2,6);

// Function to prompt Intensity choice
function chooseRange(title, message, default_range) {
	// Default values
	Min = default_range[0]; 
	Max = default_range[1]; 
	
	// GUI elements
// 	Dialog.create(title);
 	Dialog.createNonBlocking(title);
 	Dialog.addMessage(message);
  	Dialog.addNumber("Min:", Min);
  	Dialog.addNumber("Max:", Max);
  	Dialog.show();
  	Min = Dialog.getNumber();
  	Max = Dialog.getNumber();
  	return newArray(Min, Max);
}

// Determine Intensity Thresholds
print("Determining intensity thresholds");

Dialog.createNonBlocking("Select reference image");
Dialog.addMessage("Pick your control/brightest image to normalize to:");
Dialog.addChoice("Reference image:", lst);
Dialog.show();
ref_img = Dialog.getChoice();

// Start processing
for (file=-1; file<lst.length; file++) { // Iterate over movie list
	
	if (file == -1) {
		// Open reference movvie
		path = input+ref_img;
		print("Opening reference image");
		run("Bio-Formats Importer", "open="+path+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		dir = File.getParent(path);
		name = File.getNameWithoutExtension(path);
		
		// Split movie and select center
		run("Split Channels");
		wait(100);
		selectImage("C1-"+name+".nd2");
		wait(100);
		center_frame = (round(nSlices/2));
		wait(100);
		Stack.setPosition(1,center_frame,1); // Go to middle slice
	} else {
		// Open movie
		print("Opening movie"+lst[file]);
		path = input+lst[file];
		run("Bio-Formats Importer", "open="+path+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		dir = File.getParent(path);
		name = File.getNameWithoutExtension(path);
		print("Starting Maximum Intensity Projection of" + name);
		
		// Select movie based on name and channel suffix: i.e. C1-[movie name]
		run("Split Channels");
		wait(100);
		selectImage("C1-"+name+".nd2");
		wait(100);
		center_frame = (round(nSlices/2));
		wait(100);
		Stack.setPosition(1,center_frame,1); // Go to middle slice
	}
	
	if (file == -1) {
		// Check intensity values for Channel #1
		run("Brightness/Contrast...");
		C1_intensities = chooseRange("Channel 1 Intensity", "Input a range of intensity values based on the brightest image.", default_intensities);
		C1_intensity_min = C1_intensities[0];
		C1_intensity_max = C1_intensities[1];
		close("B&C");
		selectImage("C1-"+name+".nd2");
		setMinAndMax(C1_intensity_min, C1_intensity_max);
		print("Setting channel 1 range to "+C1_intensity_min+"-"+C1_intensity_max);
	} else {
		selectImage("C1-"+name+".nd2");
		setMinAndMax(C1_intensity_min, C1_intensity_max);
	}
	
	// Repeat for channel 2
	selectImage("C2-"+name+".nd2");
	Stack.setPosition(1,center_frame,1); // Go to middle slice
	
	if (file == -1) {
		// Check intensity values for Channel #2
		run("Brightness/Contrast...");
		C2_intensities = chooseRange("Channel 2 Intensity", "Input a range of intensity values based on the brightest image.", default_intensities);
		C2_intensity_min = C2_intensities[0];
		C2_intensity_max = C2_intensities[1];
		close("B&C");
		selectImage("C2-"+name+".nd2");
		setMinAndMax(C2_intensity_min, C2_intensity_max);
		print("Setting channel 2 range to "+C2_intensity_min+"-"+C2_intensity_max);
	} else {
		selectImage("C2-"+name+".nd2");
		setMinAndMax(C2_intensity_min, C2_intensity_max);
	}
	
	if (file == -1) {
		// Skip MIP - Only get intensity info for this round
		close("*");
	} else {
		// Make the number of slices that you cut user 
		Stack.setPosition(1,center_frame,1); // Go to middle slice
		frame_range = chooseRange("Select the range of frames", "Input the range of frames used for this movie in your NIS-Elements analysis.", default_frames);
		frame1 = frame_range[0];
		frame2 = frame_range[1];
		run("Duplicate...", "duplicate slices="+frame1+"-"+frame2);	
		
		//MIP
		run("Merge Channels...", "c1=C1-"+name+".nd2 c2=C2-"+name+".nd2 create");
		run("Z Project...", "projection=[Max Intensity]");
		
		// Save Maximum Intensity Projection images
		saveAs("png", output_folder + "/MIP_"+name);
		close("*");
	}
}

print("Finished processing movies");
selectWindow("Log");
saveAs("Text", output_folder+"log.txt");