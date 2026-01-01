sysuse auto, clear

summarize

correlate price mpg trunk weight length turn displacement gear_ratio foreign

* 1. Define Variable Lists
local xvars mpg trunk weight length turn displacement gear_ratio
local yvars price foreign

* 2. Prepare Color Binning for Price (20 bins)
xtile price_bin = price, n(20)
forv b = 1/20 {
    * Correctly generating the 20 colors from the Ball Mapper logic
    qui mata: st_local("hex_`b'", sprintf("%g %g %g", round(255*(`b'/20)), 80, round(255*(1 - `b'/20))))
}

* 3. Nested Loops
local n : word count `xvars'

foreach y of local yvars {
    forval i = 1/`n' {
        forval j = `= `i' + 1'/`n' {
            
            local x1 : word `i' of `xvars'
            local x2 : word `j' of `xvars'
            
            * Use short internal name (max 32 chars)
            local shortname "gr_`i'_`j'_`y'"
            
            di as txt "Generating Scatter: `x1' vs `x2' (Color: `y')"

            if "`y'" == "price" {
                * Build 20 layers, one for each color bin
                local layers ""
                forv b = 1/20 {
                    local layers `layers' (scatter `x2' `x1' if price_bin == `b', mcolor("`hex_`b''") msize(small) mlwidth(none))
                }
                
                twoway `layers', ///
                    title("") subtitle("") ///
                    legend(off) xlabel(, grid) ylabel(, grid) ///
                    graphregion(color(white)) name(`shortname', replace)
            }
            else {
                * Categorical coloring for 'foreign'
                twoway (scatter `x2' `x1' if foreign==0, mcolor(navy%60) msymbol(circle) msize(small)) ///
                       (scatter `x2' `x1' if foreign==1, mcolor(red%60) msymbol(diamond) msize(small)), ///
                    title("") subtitle("") ///
                    legend(order(1 "Domestic" 2 "Foreign") pos(6) rows(1) size(vsmall)) ///
                    xlabel(, grid) ylabel(, grid) ///
                    graphregion(color(white)) name(`shortname', replace)
            }
            
            * Save using the descriptive filename
            graph export "`x1'_`x2'_`y'.png", replace
        }
    }
}

* Create a pure numeric version without any labels
gen double for_num = (foreign == 1)

* Standardize all X variables
foreach v in mpg trunk weight length turn displacement gear_ratio {
    egen std_`v' = std(`v')
}

* Run Ball Mapper on the standardized versions. The main plots are with epsilon of 1.5. 

ballmapper std_*, epsilon(1.5) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std15") labels
ballmapper std_*, epsilon(1) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std10") labels
ballmapper std_*, epsilon(1.2) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std12") labels
ballmapper std_*, epsilon(1.8) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std18") labels
ballmapper std_*, epsilon(2) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std20") labels
ballmapper std_*, epsilon(2.5) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std25") labels
ballmapper std_*, epsilon(3) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std30") labels

ballmapper std_*, epsilon(1) color(price) layout repulsion(0.05) attraction(0.01) filename("price10") labels
ballmapper std_*, epsilon(1.5) color(price) layout repulsion(0.05) attraction(0.01) filename("price15") labels
ballmapper std_*, epsilon(2) color(price) layout repulsion(0.05) attraction(0.01) filename("price20") labels
ballmapper std_*, epsilon(2.5) color(price) layout repulsion(0.05) attraction(0.01) filename("price25") labels
ballmapper std_*, epsilon(3) color(price) layout repulsion(0.05) attraction(0.01) filename("price30") labels

* Repeat the Ball Mapper at 1.5 for the later analysis

ballmapper std_*, epsilon(1.5) color(for_num) layout repulsion(0.05) attraction(0.01) filename("foreign_std15") labels

* Ball Summary with the main variables

ballsummary mpg trunk weight length turn displacement gear_ratio price foreign, csvfile("auto_means12")

variablesummary foreign, boxplot boxfile("foreign_15_box") csvfile("foreign_15_stats")

variablesummary price, boxplot boxfile("price_15_box") csvfile("price_15_stats")


