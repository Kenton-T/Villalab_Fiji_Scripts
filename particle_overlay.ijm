// circle points stored in a csv file in order to identify and track picks across frames
radius = 3

// opening file
input = File.openDialog("Select an image file");
if (File.exists(input) == true) {
	run("Bio-Formats Importer", "open="+input+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	print("Opened: " + input);
} else {
	print("File does not exist/No file was selected");
}

// enhance contrast for user 
img = getTitle();
Stack.setChannel(1);
wait(100);
run("Enhance Contrast...", "saturated=1.00");
Stack.setChannel(2);
wait(100);
run("Enhance Contrast...", "saturated=1.00");
wait(100);
run("Split Channels");
wait(100);
run("Merge Channels...", "c1=C1-"+img+" c2=C2-"+img+" create");
wait(100);
run("RGB Color", "frames");
Stack.getDimensions(width, height, channels, slices, frames);

// locate & load file coordinate file
csv_path = File.openDialog("Select the CSV containing particle coordinates");
print("Reading file: "+File.getName(csv_path));
Table.open(csv_path);
wait(100);
Table.sort("TimeLapseIndex"); // if out of order, arrange by frame
table_len = Table.size();
print("Found "+table_len+" number of particles");

// Draw channel 1 particles, column names should be XM and YM
Stack.setFrame(1);
setForegroundColor(207, 60, 60); 

for (n = 1; n <= frames;) {
	for (i = 0; i < table_len; i++) {
		if (Table.get("TimeLapseIndex", i) != n) {
			n++;
			Stack.setFrame(n);
		} else {
			x_coord = Table.get("XM", i);
			y_coord = Table.get("YM", i);
			makeOval((x_coord - radius), (y_coord - radius), (radius*2), (radius*2));
			run("Draw", "slice");
		}
	}
	n++; // necessary to close the first for loop 
}

// Draw channel 2 particles, column names should be Neighbor_XM and Neighbor_YM
Stack.setFrame(1);
setForegroundColor(20, 120, 255);

for (n = 1; n <= frames;) {
	for (i = 0; i < table_len; i++) {
		if (Table.get("TimeLapseIndex", i) != n) {
			n++;
			Stack.setFrame(n);
		} else {
			x_coord = Table.get("Neighbor_XM", i);
			y_coord = Table.get("Neighbor_YM", i);
			makeOval((x_coord - radius), (y_coord - radius), (radius*2), (radius*2));
			run("Draw", "slice");
		}
	}
	n++; // necessary to close the first for loop 
}

print("Finished drawing selection");