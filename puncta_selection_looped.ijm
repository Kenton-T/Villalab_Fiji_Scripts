//config
random_selection = false; // when false, the frame positions specified in frame_override will be used 
select_all = true; // when true, this overrides the random selection of frames and instead iterates for every frame in movie (with respect to the first movie)
frame_override = newArray(1, 11, 21); // enter desired frames for analysis in lieu of 1, 2, 3 

//initialise
roiManager("Reset"); // clears the roi manager
run("Clear Results"); //empties the results table 
run("Select None"); //makes sure there is nothing selected
run("Set Measurements...", "area mean min center stack redirect=None decimal=3"); //selects measurements saved in output 
call("ij.Prefs.set", "threshold.mode", "B&W");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

//function to check if a value is already present inside an array
function containing(array, value) { 
	for (i = 0; i < array.length; i++) {
		if (array[i] == value){
			return true;
		}
	}
	return false;
}

// open the file
input = getDirectory("Input folder for images"); //get input folder
FileList = getFileList(input); //get list of files
rm = newArray(0);
for (i = 0; i < FileList.length; i++) { // handles exception if this script is run in a directory where the output folder already exists
	if (File.isDirectory(input + FileList[i]) == true) {
		rm = Array.concat(rm, FileList[i]);
	}
} // can probably make this script a bit more robust by checking if the file extension is actually .nd2
for (i = 0; i < rm.length; i++) {
	FileList = Array.deleteValue(FileList, rm[i]);
}
print("Found these files: ");
Array.print(FileList); // no function exists to combine a string and array into a single print function (??)

// make output folder
output_folder = input+"output/";
print(output_folder);
if (File.isDirectory(output_folder)) {
	print("Directory already made, moving on...");
} else {
	File.makeDirectory(output_folder);
}

for (image=0; image<FileList.length; image++) {
	path = input + FileList[image]; //reads the images sequentially from the list
	run("Bio-Formats Importer", "open="+path+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	dir = File.getParent(path);
	name = File.getNameWithoutExtension(path);
	print("Starting the process on "+name);
	// making output subfolder
	if (File.isDirectory(output_folder+"/"+name)) { 
	print("Directory already made, moving on...");
	} else {
		File.makeDirectory(output_folder+"/"+name);
	}
	Stack.getDimensions(width, height, channels, slices, frames); //get total frame count
	// determining which frames to process
	if (image == 0) {
		if (random_selection == true) {
			frame_list = newArray(0); //creates empty array 		
			for (i = 0; i < 3;) { //change this value to draw more samples 
				random_frame = parseInt(random * frames);
				if ((containing(frame_list, random_frame) == false) && random_frame != 0) {
					frame_list = Array.concat(frame_list, random_frame);
					print("Frame "+random_frame+" is selected");
					i++;
				} else {
					print("Frame "+random_frame+" is already selected, selecting another frame");
				}
			}
		} if (select_all == true) {
			frame_seq = Array.getSequence(frames);
			frame_list_tmp = newArray();
			for (i=0; i < frame_seq.length; i++){
				frame_list_tmp = Array.concat(frame_list_tmp, frame_seq[i]+1);
			}
			frame_list = frame_list_tmp;
		} else {
			frame_list = frame_override;
		}
	}
	
	// select a slice to proceed for now 	
	for (i = 1; !(i > channels); i++) {
		selectImage(name+".nd2");	
		Stack.getDimensions(width, height, channels, slices, frames);
		for (n = 0; n < frame_list.length; n++) { 
			if (!(frame_list[n] > frames)) {
				Stack.setPosition(i,1,frame_list[n]); 
				roiManager("Reset"); // clears the roi manager
				run("Clear Results"); //empties the results table 
				run("Select None"); //makes sure there is nothing selected
				run("Enhance Contrast...", "saturated=1.00");
				// mask lysosomes
				run("Duplicate...", "title=ch"+i+".tif");
				run("Duplicate...", "title=ch"+i+"_mask.tif");
				if (n == 0) { //this thresholding method should hopefully be better than relying on automatic methods, which seems unreliable for our data
					run("Threshold...");
					waitForUser("Adjust threshold as necessary");
					getThreshold(lower, upper);
					print("Threshold set:\nUpper: "+upper+"\nLower: "+lower);
				} else {
					setThreshold(lower, upper);
				}
				run("Convert to Mask");
				wait(100);
				// watershed
				run("Watershed");
				wait(1500);
				// saving an image of the watershed, delete section later
				run("Duplicate...", "title=ch"+i+"_watershed.tif");
				selectWindow("ch"+i+"_watershed.tif");
				saveAs("PNG", output_folder+"/"+name+"/ch"+i+"_"+frame_list[n]+"_watershed.png");
				close("ch"+i+"_watershed.tif");
				close("ch"+i+"_"+frame_list[n]+"_watershed.png");
				selectWindow("ch"+i+"_mask.tif");
				run("Analyze Particles...", "size=0.15-3 show=Outlines display clear add");
				wait(100);
				close("ch"+i+"_mask.tif");
				close("Results");
				selectWindow("ch"+i+".tif");
				run("Hide Overlay");
				//roiManager("Show All");
				roiManager("Measure");
				wait(500);
				run("Add Image...", "image=[Drawing of ch"+i+"_mask.tif] x=0 y=0 opacity=30");
				saveAs("PNG", output_folder+"/"+name+"/ch"+i+"_"+frame_list[n]+"_mask.png");
				saveAs("Results", output_folder+"/"+name+"/ch"+i+"_"+frame_list[n]+"_particles.txt");
				//closing files to prepare for next loop
				close("Results");
				close("ch"+i+".tif");
				close("Drawing of ch"+i+"_mask.tif");
				close("ch"+i+"_"+frame_list[n]+"_mask.png");
			}
			else { // prevents script from hanging/crashing if there are movies with different lengths in the selected directory
				print("Frame "+frame_list[n]+" is out of range for "+name+". Please rerun this job or disable random selection in line 2.");
			}
		}
	}
	close(name+".nd2");
}
print("Finished processing dataset");

selectWindow("Log");
saveAs("Text", output_folder+year+"_"+month+"_"+dayOfMonth+"_log.txt");
