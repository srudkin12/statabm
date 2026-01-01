clear
set seed 1
set obs 1000

gen x1 = rnormal(0, 1)
gen x2 = rnormal(0, 1)

* 1. Initialize Permanent Variables
cap drop covered landmark_id first_ball
gen covered = 0
gen landmark_id = .
gen first_ball = .  // Added: Essential for the summary table
local epsilon = 1
local i = 0

* Ensure phi exists for drawing circles
cap range phi 0 2*_pi 100

* 2. Loop until no uncovered points remain
quietly count if covered == 0
while r(N) > 0 {
    local points_left = r(N)
    local ++i
    
    * Find the first uncovered observation index
    tempvar obs_idx
    quietly gen `obs_idx' = _n if covered == 0
    quietly summarize `obs_idx', meanonly
    local L = r(min)
    drop `obs_idx'
    
    * Get coordinates of current landmark
    local lx = x1[`L']
    local ly = x2[`L']
    
    * Identify points in the NEWEST ball
    tempvar in_new_ball
    quietly gen `in_new_ball' = (sqrt((x1 - `lx')^2 + (x2 - `ly')^2) <= `epsilon')
    
    * RECORD DATA FOR TABLE: Mark points covered for the FIRST time
    * Logic: If a point is in the current ball AND was not covered previously
    quietly replace first_ball = `i' if `in_new_ball' == 1 & covered == 0
    
    * Update global coverage and landmark ID
    quietly replace covered = 1 if `in_new_ball' == 1
    quietly replace landmark_id = `i' if _n == `L'
    
    * Store circle coordinates for plotting
    gen circ_x_`i' = `lx' + cos(phi)
    gen circ_y_`i' = `ly' + sin(phi)
    
    * 3. Build the plot command for HISTORY (Previous Red Balls)
    local history ""
    if `i' > 1 {
        forval j = 1/`=`i'-1' {
            * Solid red for history as requested
            local history `history' (line circ_y_`j' circ_x_`j', lcolor(red) lwidth(medium))
            local history `history' (scatter x2 x1 if landmark_id == `j', mcolor(gs6) msymbol(D) msize(medium))
        }
    }

    * 4. Generate the Plot
    * Layering: Background -> Covered(Red) -> History -> New Points(Blue) -> Current Ball
    twoway (scatter x2 x1 if covered==0, mcolor(gs13) msize(tiny)) (scatter x2 x1 if covered==1 & `in_new_ball'==0, mcolor(red) msize(tiny)) `history' (scatter x2 x1 if `in_new_ball'==1, mcolor(blue) msize(tiny)) (line circ_y_`i' circ_x_`i', lcolor(blue) lwidth(medium)) (scatter x2 x1 if landmark_id == `i', mcolor(blue) msymbol(D) msize(medium)), title("Ball Mapper Construction: Ball `i'") subtitle("Points Remaining to cover: `points_left'") xtitle("X{sub:1}") ytitle("X{sub:2}") aspect(1) xlabel(-4(1)4) ylabel(-4(1)4) legend(off) graphregion(color(white))
           
    graph export "stata_`i'.png", replace
    
    * Clean up the temporary membership variable for this ball
    drop `in_new_ball'
    
    * Re-check for the loop condition
    quietly count if covered == 0
}

*--- GENERATE SUMMARY TABLE ---
preserve
    * Filter to only include points that were assigned to a ball
    keep if first_ball != .
    
    * contract calculates the frequency of each landmark assignment
    contract first_ball, p(percent)
    
    rename _freq newly_captured_pts
    label var first_ball "Landmark ID"
    label var newly_captured_pts "New Points Covered"
    label var percent "% of Dataset"
    
    * Display the table in the results window
    list, table div ab(20)
    
    * Export the CSV
    export delimited using "landmark_summary.csv", replace
restore

* --- 1. PREPARE THE SIZES ---
* We use the numbers from your list (1.5 to 7.5)
* Ensure these variables exist from your previous step
summarize ball_density if landmark_id != .
scalar max_d = r(max)
scalar min_d = r(min)

* --- 2. BUILD THE LANDMARK PLOT MACRO ---
local landmark_plots ""

forval k = 1/`=num_balls' {
    * Get coordinates and density for ball k
    summarize x1 if landmark_id == `k', meanonly
    local kx = r(mean)
    summarize x2 if landmark_id == `k', meanonly
    local ky = r(mean)
    summarize ball_density if landmark_id == `k', meanonly
    local kd = r(mean)
    
    * Calculate a specific size for this specific diamond (Scale 1.5 to 8)
    local ksize = ((`kd' - `=min_d') / (`=max_d' - `=min_d')) * 6.5 + 1.5
    
    * Add a specific scatter command for JUST THIS ONE diamond to our macro
    local landmark_plots `landmark_plots' (scatter x2 x1 if landmark_id == `k', msymbol(D) mcolor(gs4) msize(`ksize') mlabel(landmark_id) mlabp(12) mlabcolor(black) mlabsize(small))
}

* --- 2. GENERATE PLOT 1: GEOMETRIC VIEW ---
* This includes the raw data dots and the red circle boundaries
twoway (scatter x2 x1, mcolor(gs14%40) msize(tiny)) `circle_lines' `landmark_plots' (pcspike edg_y1 edg_x1 edg_y2 edg_x2, lcolor(black) lwidth(thick)) , title("Ball Mapper: Density & Topology") subtitle("Geometric View: Data and Covers") aspect(1) legend(off) name(struc1, replace)

graph export "stata_struc1.png", replace


* --- 3. GENERATE PLOT 2: ABSTRACT SKELETON ---
* This drops the data and circles for a clean topological graph
twoway (pcspike edg_y1 edg_x1 edg_y2 edg_x2, lcolor(black) lwidth(thick)) `abstract_landmarks' `landmark_plots', title("Ball Mapper: Abstract Skeleton") subtitle("Topological View: Landmark Adjacency") xtitle("X1") ytitle("X2") aspect(1) legend(off) graphregion(color(white)) name(struc2, replace)

graph export "stata_struc2.png", replace
