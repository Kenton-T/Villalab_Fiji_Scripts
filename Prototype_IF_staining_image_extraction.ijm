
// Get size of movies
getDimensions(width, height, channels, slices, frames);


// Make the number of slices that you cut user definable
run("Duplicate...", "duplicate slices=1-3");


// Runs the brightness/contrast function
run("Brightness/Contrast...");


// Somehow record the inputs then save them here

//placeholder

//MIP

run("Z Project...", "projection=[Max Intensity]");


// save png????
