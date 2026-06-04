# Fiji\_Scripts



These are Fiji macro scripts used for analyzing multi-channel fluorescence time-lapse movies stored in .nd2 format.



Requirements:



* ImageJ/Fiji
* Bio-Formats plugin (included with Fiji)





#### Scripts:



###### MIP\_image\_export.ijm



* Generates Maximum Intensity Projection (MIP) images from a folder of .nd2 movies, with consistent intensity normalization across the dataset.
* The frame selection id determined from the first movie in the folder and applied to all others. If a movie is shorter, that frame is skipped with a warning recorded in the log.



1. Prompts you to select an input folder containing .nd2 files.
2. Creates an output/ subfolder in that directory.
3. Asks you to select a reference image (e.g. your brightest/control condition) to set intensity thresholds.
4. Opens the reference image, splits channels, and prompts you to set min/max intensity ranges for Channel 1 and Channel 2 using the Brightness/Contrast dialog.
5. Iterates over all remaining movies, applying the same intensity ranges.
6. For each movie, prompts you to specify the frame range (z-slice range) to include in the projection.
7. Merges Channel 1 and Channel 2, runs a Z Max Intensity Projection, and saves as a .png in the output folder.
8. Saves a log.txt of the session to the output folder.



###### puncta\_selection\_looped.ijm



* Detects and quantifies fluorescent puncta in each channel of a batch of .nd2 movies using thresholding and particle analysis.
* The input file must have the columns: "TimeLapseIndex", "XM", "YM", "Neighbor\_XM", and "Neighbor\_YM".



1. Prompts you to select an input folder of .nd2 files.
2. Creates an output/ folder, with a subfolder per movie.
3. Determines which frames to analyze based on the mode set in the config (see below).
4. For each movie and each channel:

   1. Opens the specified frame, enhances contrast, and duplicates it.
   2. On the first frame, opens the Threshold dialog and waits for manual adjustment; subsequent frames reuse the same threshold.
   3. Applies the threshold, converts to a binary mask, and runs Watershed to separate touching particles.
   4. Saves a watershed QC image (.png).
   5. Runs Analyze Particles (size filter: 0.15–3 area units) and measures ROIs against the original channel image.
   6. Saves a mask overlay QC image and a particle measurements table (.txt).
5. Saves a timestamped log.txt on completion.



###### particle\_overlay.ijm



* Draws particle coordinate overlays from a CSV file onto a two-channel .nd2 movie for visual validation of tracking results.
* The circle radius is set to 3px; this value is hardcoded at the top of the script and can be adjusted as necessary.



1. Prompts you to select a single .nd2 image file.
2. Enhances contrast on both channels, splits and re-merges them as an RGB stack.
3. Prompts you to select a CSV file containing particle coordinates.
4. Sorts the table by TimeLapseIndex (frame number).
5. Draws red circles (Channel 1 particles) at coordinates XM, YM for each frame.
6. Draws blue circles (Channel 2 / neighbor particles) at coordinates Neighbor\_XM, Neighbor\_YM for each frame.

