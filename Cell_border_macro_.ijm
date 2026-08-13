requires("1.53");

if (nImages == 0)
    exit("Open an image first.");

setBatchMode(true);

setOption("ScaleConversions", true);

run("Duplicate...", "title=CB_Source");
selectWindow("CB_Source");
run("32-bit");

pLow = percentileValue(0.01);
pHigh = percentileValue(0.99);

run("Subtract...", "value=" + pLow);

run("Min...", "value=0");

range = pHigh - pLow;
if (range <= 0) range = 1;
run("Divide...", "value=" + range);
run("Max...", "value=1");

run("Multiply...", "value=-1");

accExists = 0;

for (sigma = 6; sigma <= 12; sigma++) {

    selectWindow("CB_Source");
    run("Duplicate...", "title=CB_G");
    selectWindow("CB_G");
    run("Gaussian Blur...", "sigma=" + sigma);

    run("Duplicate...", "title=CB_Hxx");
    selectWindow("CB_Hxx");
    run("Convolve...", "text1=[0 0 0\n1 -2 1\n0 0 0]");

    selectWindow("CB_G");
    run("Duplicate...", "title=CB_Hyy");
    selectWindow("CB_Hyy");
    run("Convolve...", "text1=[0 1 0\n0 -2 0\n0 1 0]");

    selectWindow("CB_G");
    run("Duplicate...", "title=CB_Hxy");
    selectWindow("CB_Hxy");
    run("Convolve...", "text1=[1 0 -1\n0 0 0\n-1 0 1]");
    run("Multiply...", "value=0.25");

    imageCalculator("Subtract create 32-bit", "CB_Hxx", "CB_Hyy");
    rename("CB_D");
    run("Square");

    selectWindow("CB_Hxy");
    run("Duplicate...", "title=CB_XY");
    selectWindow("CB_XY");
    run("Square");
    run("Multiply...", "value=4");

    imageCalculator("Add create 32-bit", "CB_D", "CB_XY");
    rename("CB_DISC");
    run("Square Root");

    imageCalculator("Add create 32-bit", "CB_Hxx", "CB_Hyy");
    rename("CB_TRACE");

    imageCalculator("Add create 32-bit", "CB_TRACE", "CB_DISC");
    rename("CB_LAMBDA");
    run("Multiply...", "value=0.5");

    run("Min...", "value=0");

    run("Multiply...", "value=" + (sigma*sigma));

    if (accExists == 0) {
        rename("CB_ACC");
        accExists = 1;
    } else {
        imageCalculator("Max create 32-bit", "CB_ACC", "CB_LAMBDA");
        rename("CB_NEWACC");
        closeIfOpen("CB_ACC");
        selectWindow("CB_NEWACC");
        rename("CB_ACC");
        closeIfOpen("CB_LAMBDA");
    }

    closeIfOpen("CB_G");
    closeIfOpen("CB_Hxx");
    closeIfOpen("CB_Hyy");
    closeIfOpen("CB_Hxy");
    closeIfOpen("CB_D");
    closeIfOpen("CB_XY");
    closeIfOpen("CB_DISC");
    closeIfOpen("CB_TRACE");
}

selectWindow("CB_ACC");

lo = percentileValue(0.65);
hi = percentileValue(0.998);

run("Subtract...", "value=" + lo);
run("Min...", "value=0");

d = hi - lo;
if (d <= 0) d = 1;
run("Divide...", "value=" + d);
run("Max...", "value=1");

run("Gamma...", "value=0.60");

changeValues(0, 0.08, 0);

rename("Cell_Border_Response_32bit");

getStatistics(area, mean, minV, maxV);
print("Cell border response before LUT:");
print("  min = " + minV);
print("  max = " + maxV);
print("  mean = " + mean);

setOption("ScaleConversions", true);
setMinAndMax(0, 1);
run("8-bit");
rename("Cell_Border_Contrast");

reds = newArray(48,49,50,52,53,54,55,56,57,58,59,60,60,61,62,63,64,64,65,65,66,67,67,67,68,68,69,69,69,69,70,70,70,70,70,70,70,70,70,70,70,70,69,69,69,68,67,66,65,64,63,62,60,59,57,56,54,52,51,49,47,45,43,42,40,38,37,35,33,32,30,29,28,27,26,25,24,24,23,23,23,23,24,24,25,26,27,29,30,32,34,36,39,41,44,47,50,53,56,59,63,66,70,74,77,81,85,89,93,97,101,105,109,113,116,120,124,128,132,135,139,142,146,149,152,155,158,161,164,166,169,172,174,177,179,182,185,187,190,192,195,197,200,202,205,207,209,212,214,216,218,221,223,225,227,229,231,232,234,236,237,239,240,242,243,244,246,247,248,249,249,250,251,251,252,252,253,253,253,253,254,254,254,254,253,253,253,253,252,252,251,251,250,250,249,248,247,247,246,245,244,243,242,241,239,238,237,236,234,233,232,230,229,227,226,224,222,221,219,217,215,214,212,210,208,206,203,201,199,197,195,192,190,187,185,182,180,177,174,172,169,166,163,160,157,154,151,148,145,142,139,135,132,129,125,122);
greens = newArray(18,21,24,27,30,33,35,38,41,44,47,50,53,55,58,61,64,67,69,72,75,78,80,83,86,88,91,94,96,99,102,104,107,109,112,115,117,120,122,125,127,130,132,135,137,140,142,145,147,150,152,155,157,160,162,165,168,170,172,175,177,180,182,185,187,189,192,194,196,198,201,203,205,207,209,211,213,215,217,218,220,222,224,225,227,228,229,231,232,233,235,236,237,238,239,240,241,243,244,244,245,246,247,248,249,249,250,251,251,252,252,253,253,253,254,254,254,254,254,254,254,254,254,254,254,253,253,252,252,251,251,250,249,248,248,247,245,244,243,242,241,239,238,237,235,234,232,231,229,227,226,224,222,220,218,216,215,213,211,209,207,205,203,200,198,196,194,192,190,188,186,183,181,179,176,174,171,169,166,163,161,158,155,152,149,146,143,140,137,134,131,128,125,122,119,116,113,110,107,104,101,99,96,93,90,88,85,82,80,77,75,73,70,68,66,64,62,60,58,56,54,52,50,48,47,45,43,41,40,38,36,35,33,31,30,28,27,25,24,22,21,20,18,17,16,14,13,12,11,10,9,8,7,6,5,4);
blues = newArray(59,66,74,81,88,95,101,108,114,121,127,133,139,145,150,156,161,166,171,176,181,186,190,194,199,203,206,210,214,217,221,224,227,230,232,235,237,240,242,244,246,248,249,251,252,253,253,254,254,254,254,254,253,252,252,251,249,248,246,245,243,241,239,237,235,233,230,228,225,223,220,218,215,212,210,207,204,202,199,196,194,191,189,186,184,182,180,177,175,172,169,166,163,160,157,154,151,148,145,141,138,135,131,128,124,121,118,114,111,108,104,101,98,95,92,89,86,83,80,77,75,72,70,68,66,64,62,61,59,58,57,55,55,54,53,53,52,52,52,51,51,51,51,51,52,52,52,53,53,53,54,54,54,55,55,56,56,56,57,57,57,57,58,58,58,58,58,57,57,57,56,55,55,54,53,52,51,50,49,48,47,46,45,44,43,41,40,39,38,36,35,34,32,31,30,28,27,26,24,23,22,21,20,19,17,16,15,14,13,13,12,11,10,10,9,8,8,7,7,6,6,5,5,5,4,4,3,3,3,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2);
setLut(reds, greens, blues);

run("RGB Color");

closeIfOpen("CB_Source");

setBatchMode(false);
selectWindow("Cell_Border_Contrast");

function percentileValue(frac) {
    getStatistics(area, mean, minV, maxV);

    if (maxV <= minV)
        return minV;

    getHistogram(vals, counts, 4096, minV, maxV);

    total = 0;
    for (i=0; i<counts.length; i++)
        total += counts[i];

    target = frac * total;
    cumulative = 0;

    for (i=0; i<counts.length; i++) {
        cumulative += counts[i];
        if (cumulative >= target)
            return vals[i];
    }

    return maxV;
}

function closeIfOpen(title) {
    if (isOpen(title)) {
        selectWindow(title);
        close();
    }
}
