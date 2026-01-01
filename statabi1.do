clear
set seed 1  // For reproducibility
set obs 900     // 9 clouds * 100 points each

* 1. Create the base Gaussian noise
gen x1 = rnormal(0, 1)
gen x2 = rnormal(0, 1)

* 2. Create an ID for the 9 clusters (100 observations each)
gen cluster_id = ceil(_n / 100)

* 3. Translate the clusters to form the "X" shape
* Define the shifts based on your coordinates
* Group 1: Outer Corners
replace x1 = x1 - 6 if cluster_id == 1 // Top-Left
replace x2 = x2 + 6 if cluster_id == 1

replace x1 = x1 + 6 if cluster_id == 2 // Top-Right
replace x2 = x2 + 6 if cluster_id == 2

replace x1 = x1 - 6 if cluster_id == 3 // Bottom-Left
replace x2 = x2 - 6 if cluster_id == 3

replace x1 = x1 + 6 if cluster_id == 4 // Bottom-Right
replace x2 = x2 - 6 if cluster_id == 4

* Group 2: Inner "Arms"
replace x1 = x1 - 3 if cluster_id == 5 // Mid-Top-Left
replace x2 = x2 + 3 if cluster_id == 5

replace x1 = x1 + 3 if cluster_id == 6 // Mid-Top-Right
replace x2 = x2 + 3 if cluster_id == 6

replace x1 = x1 - 3 if cluster_id == 7 // Mid-Bottom-Left
replace x2 = x2 - 3 if cluster_id == 7

replace x1 = x1 + 3 if cluster_id == 8 // Mid-Bottom-Right
replace x2 = x2 - 3 if cluster_id == 8

* Group 3: Center
* cluster_id == 9 remains at (0,0) - no translation needed

* 4. Visualize the raw data
twoway (scatter x2 x1, msize(tiny) mcolor(gs10%50)), ///
    title("") ///
    subtitle("") ///
    aspect(1) xlabel(-10(2)10) ylabel(-10(2)10) ///
    xline(0, lcolor(gs14)) yline(0, lcolor(gs14)) ///
    graphregion(color(white))
	
graph export "greyx.png", replace
 
* --- 1. y1: Linear relationship with small noise ---
gen no1 = rnormal(0, 0.2)
gen y1 = x1 + x2 + no1

* --- 2. y2: Categorical (The Cloud ID) ---
* We already have cluster_id (1-9). Let's use it as y2.
gen y2 = cluster_id

* --- 3. y3: Radial pattern (Squared distance from origin) ---
gen y3 = x1^2 + x2^2

* --- 4. y4: Pure noise control ---
gen y4 = rnormal(0, 1)

* --- 5. y5: Conditional region (A "Hot Spot" in the upper right quadrant) ---
* This will be 1 if point is in the (0,3) box for both dimensions, else 0.
gen y5 = (x1 > 0 & x1 < 3) & (x2 > 0 & x2 < 3)

* --- Labeling for clarity ---
label var y1 "Linear (x1+x2)"
label var y2 "Cluster ID (1-9)"
label var y3 "Radial Distance (x1^2+x2^2)"
label var y4 "Random Noise"
label var y5 "Specific Region (0<x,y<3)"

* --- Plots and Saving ---

* --- PREPARE THE COLORS (5-bin approach for y1, y3, y4) ---
* We will use a 5-step color ramp from Blue to Red (or Viridis style)
foreach v in y1 y3 y4 {
    cap drop `v'_bin
    xtile `v'_bin = `v', nq(8) // Dividing into 8 "continuous-like" bins
}

* --- PLOT y1: Linear Trend (x1 + x2) ---
* This should show a diagonal gradient
twoway (scatter x2 x1 if y1_bin==1, mcolor("253 231 37") msize(tiny)) ///
       (scatter x2 x1 if y1_bin==2, mcolor("181 222 43") msize(tiny)) ///
       (scatter x2 x1 if y1_bin==3, mcolor("94 201 98") msize(tiny))  ///
       (scatter x2 x1 if y1_bin==4, mcolor("33 175 140") msize(tiny)) ///
       (scatter x2 x1 if y1_bin==5, mcolor("31 145 140") msize(tiny)) ///
       (scatter x2 x1 if y1_bin==6, mcolor("45 113 142") msize(tiny)) ///
       (scatter x2 x1 if y1_bin==7, mcolor("62 73 137") msize(tiny))  ///
       (scatter x2 x1 if y1_bin==8, mcolor("68 1 84") msize(tiny)),   ///
       title("") subtitle("") ///
       aspect(1) legend(off) graphregion(color(white)) name(plot_y1, replace)
	   
 graph export "xy1.png", replace
 
* --- PLOT y2: 9 Groups ---
* Using a mix of high-contrast colors to ensure the "X" arms are visible
twoway (scatter x2 x1 if y2 == 1, mcolor(navy) msize(tiny))    /// Top-Left
       (scatter x2 x1 if y2 == 2, mcolor(emerald) msize(tiny)) /// Top-Right
       (scatter x2 x1 if y2 == 3, mcolor(maroon) msize(tiny))  /// Bottom-Left
       (scatter x2 x1 if y2 == 4, mcolor(orange) msize(tiny))  /// Bottom-Right
       (scatter x2 x1 if y2 == 5, mcolor(blue) msize(tiny))    /// Mid-Top-Left
       (scatter x2 x1 if y2 == 6, mcolor(cranberry) msize(tiny)) /// Mid-Top-Right
       (scatter x2 x1 if y2 == 7, mcolor(purple) msize(tiny))  /// Mid-Bottom-Left
       (scatter x2 x1 if y2 == 8, mcolor(olive) msize(tiny))   /// Mid-Bottom-Right
       (scatter x2 x1 if y2 == 9, mcolor(black) msize(tiny)),  /// Center
       title("") ///
       subtitle("") ///
       legend(order(1 "TL" 2 "TR" 3 "BL" 4 "BR" 5 "mTL" 6 "mTR" 7 "mBL" 8 "mBR" 9 "Center") ///
              rows(2) size(vsmall) position(6)) ///
       aspect(1) graphregion(color(white)) name(plot_y2, replace)

graph export "xy2.png", replace

* --- PLOT y3: Radial Trend (x1^2 + x2^2) ---
* This should show "rings" of color moving away from the center
twoway (scatter x2 x1 if y3_bin==1, mcolor("253 231 37") msize(tiny)) ///
       (scatter x2 x1 if y3_bin==2, mcolor("181 222 43") msize(tiny)) ///
       (scatter x2 x1 if y3_bin==3, mcolor("94 201 98") msize(tiny))  ///
       (scatter x2 x1 if y3_bin==4, mcolor("33 175 140") msize(tiny)) ///
       (scatter x2 x1 if y3_bin==5, mcolor("31 145 140") msize(tiny)) ///
       (scatter x2 x1 if y3_bin==6, mcolor("45 113 142") msize(tiny)) ///
       (scatter x2 x1 if y3_bin==7, mcolor("62 73 137") msize(tiny))  ///
       (scatter x2 x1 if y3_bin==8, mcolor("68 1 84") msize(tiny)),   ///
       title("") subtitle("") ///
       aspect(1) legend(off) graphregion(color(white)) name(plot_y3, replace)

graph export "xy3.png", replace

* --- PLOT y4: Random Noise ---
* This should show "rings" of color moving away from the center
twoway (scatter x2 x1 if y4_bin==1, mcolor("253 231 37") msize(tiny)) ///
       (scatter x2 x1 if y4_bin==2, mcolor("181 222 43") msize(tiny)) ///
       (scatter x2 x1 if y4_bin==3, mcolor("94 201 98") msize(tiny))  ///
       (scatter x2 x1 if y4_bin==4, mcolor("33 175 140") msize(tiny)) ///
       (scatter x2 x1 if y4_bin==5, mcolor("31 145 140") msize(tiny)) ///
       (scatter x2 x1 if y4_bin==6, mcolor("45 113 142") msize(tiny)) ///
       (scatter x2 x1 if y4_bin==7, mcolor("62 73 137") msize(tiny))  ///
       (scatter x2 x1 if y4_bin==8, mcolor("68 1 84") msize(tiny)),   ///
       title("") subtitle("") ///
       aspect(1) legend(off) graphregion(color(white)) name(plot_y4, replace)

graph export "xy4.png", replace
 
* --- PLOT y5: The Regional "Hot Spot" ---
* Since this is binary (0/1), we only need two colors
twoway (scatter x2 x1 if y5==0, mcolor(gs14) msize(tiny)) ///
       (scatter x2 x1 if y5==1, mcolor(red) msize(small) msymbol(circle)), ///
       title("") ///
       aspect(1) legend(order(1 "Outside" 2 "Inside (0,3)")) graphregion(color(white)) name(plot_y5, replace)

 graph export "xy5.png", replace
 

 * -- Ball Mapper
 
ballmapper x1 x2, epsilon(0.8) color(y1) layout repulsion(0.05) attraction(0.01) filename("xy1bm08")
ballmapper x1 x2, epsilon(1.0) color(y1) layout repulsion(0.05) attraction(0.01) filename("xy1bm10")
ballmapper x1 x2, epsilon(1.2) color(y1) layout repulsion(0.05) attraction(0.01) filename("xy1bm12")
ballmapper x1 x2, epsilon(1.5) color(y1) layout repulsion(0.05) attraction(0.01) filename("xy1bm15")
ballmapper x1 x2, epsilon(2.0) color(y1) layout repulsion(0.05) attraction(0.01) filename("xy1bm20")
ballmapper x1 x2, epsilon(0.8) color(y2) layout repulsion(0.05) attraction(0.01) filename("xy2bm08")
ballmapper x1 x2, epsilon(1.0) color(y2) layout repulsion(0.05) attraction(0.01) filename("xy2bm10")
ballmapper x1 x2, epsilon(1.2) color(y2) layout repulsion(0.05) attraction(0.01) filename("xy2bm12")
ballmapper x1 x2, epsilon(1.5) color(y2) layout repulsion(0.05) attraction(0.01) filename("xy2bm15")
ballmapper x1 x2, epsilon(2.0) color(y2) layout repulsion(0.05) attraction(0.01) filename("xy2bm20")
ballmapper x1 x2, epsilon(0.8) color(y3) layout repulsion(0.05) attraction(0.01) filename("xy3bm08")
ballmapper x1 x2, epsilon(1.0) color(y3) layout repulsion(0.05) attraction(0.01) filename("xy3bm10")
ballmapper x1 x2, epsilon(1.2) color(y3) layout repulsion(0.05) attraction(0.01) filename("xy3bm12")
ballmapper x1 x2, epsilon(1.5) color(y3) layout repulsion(0.05) attraction(0.01) filename("xy3bm15")
ballmapper x1 x2, epsilon(2.0) color(y3) layout repulsion(0.05) attraction(0.01) filename("xy3bm20")
ballmapper x1 x2, epsilon(0.8) color(y4) layout repulsion(0.05) attraction(0.01) filename("xy4bm08")
ballmapper x1 x2, epsilon(1.0) color(y4) layout repulsion(0.05) attraction(0.01) filename("xy4bm10")
ballmapper x1 x2, epsilon(1.2) color(y4) layout repulsion(0.05) attraction(0.01) filename("xy4bm12")
ballmapper x1 x2, epsilon(1.5) color(y4) layout repulsion(0.05) attraction(0.01) filename("xy4bm15")
ballmapper x1 x2, epsilon(2.0) color(y4) layout repulsion(0.05) attraction(0.01) filename("xy4bm20")
ballmapper x1 x2, epsilon(0.8) color(y5) layout repulsion(0.05) attraction(0.01) filename("xy5bm08")
ballmapper x1 x2, epsilon(1.0) color(y5) layout repulsion(0.05) attraction(0.01) filename("xy5bm10")
ballmapper x1 x2, epsilon(1.2) color(y5) layout repulsion(0.05) attraction(0.01) filename("xy5bm12")
ballmapper x1 x2, epsilon(1.5) color(y5) layout repulsion(0.05) attraction(0.01) filename("xy5bm15") 
ballmapper x1 x2, epsilon(2.0) color(y5) layout repulsion(0.05) attraction(0.01) filename("xy5bm20")

 * -- Case with Labels
 
ballmapper x1 x2, epsilon(1.2) color(y1) layout repulsion(0.05) attraction(0.01) filename("xy1bm12l") labels

* -- Ball Summary Table

ballsummary y1 y2 y3 y4 y5, csvfile("ymeans12")

variablesummary y1, boxplot boxfile("y1_12_box") csvfile("y1_12_stats")

variablesummary y4, boxplot boxfile("y4_12_box") csvfile("y4_12_stats")

variablesummary y5, boxplot boxfile("y5_12_box") csvfile("y5_12_stats")
