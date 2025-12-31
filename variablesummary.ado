*! variablesummary v1.1.0 31dec2025
program variablesummary
    version 16.0
    syntax varname, [Ball(numlist) Boxplot Boxfile(string) CSVfile(string)]

    * 1. Check if the required frame exists
    cap frame change BM_MERGED
    if _rc {
        di as error "Error: Frame BM_MERGED not found. Please run 'ballmapper' first."
        exit 111
    }

    local v `varlist'
    di as txt _n "Analyzing distribution of: " as res "`v'"

    * 2. Prepare Detailed Statistics Frame
    cap frame drop BM_VAR_SUMMARY
    cap frame drop BM_TEMP_VAR
    frame copy BM_MERGED BM_TEMP_VAR
    
    frame BM_TEMP_VAR {
        collapse (mean) mean=`v' (sd) sd=`v' (min) min=`v' ///
                 (p25) p25=`v' (p50) med=`v' (p75) p75=`v' ///
                 (max) max=`v' (count) n=`v', by(ball_id)
        
        label var mean "Mean"
        label var sd "Std. Dev."
        label var p25 "25th Pct"
        label var med "Median"
        label var p75 "75th Pct"
        label var n "N points"
        
        tempfile var_sum_results
        save "`var_sum_results'"
    }
    cap frame drop BM_TEMP_VAR

    * 3. Process BM_VAR_SUMMARY Frame
    frame create BM_VAR_SUMMARY
    frame BM_VAR_SUMMARY {
        use "`var_sum_results'", clear
        if "`ball'" != "" keep if inlist(ball_id, `ball')
        sort ball_id
        
        * --- CSV Export Logic ---
        if "`csvfile'" != "" {
            if strpos("`csvfile'", ".") == 0 local csvfile "`csvfile'.csv"
            export delimited using "`csvfile'", replace
            di as txt "Statistics exported to: " as res "`csvfile'"
        }
        
        di as txt "Detailed summary created in frame: " as res "BM_VAR_SUMMARY"
        format mean sd min p25 med p75 max %9.3f
        list ball_id n mean sd min p25 med p75 max, separator(0) divider
    }

    * 4. --- Boxplot Logic ---
    if "`boxplot'" != "" {
        * We create the boxplot from the MERGED frame to get full point distribution
        frame BM_MERGED: graph box `v', over(ball_id, label(labsize(vsmall))) ///
            title("Distribution of `v' by Landmark") ///
            subtitle("Variable Summary Analysis") ///
            ytitle("Value") marker(1, msize(tiny) mcolor(gs10)) ///
            graphregion(color(white)) name(BM_Boxplot, replace)
            
        if "`boxfile'" != "" {
            if strpos("`boxfile'", ".") == 0 local boxfile "`boxfile'.png"
            graph export "`boxfile'", replace
            di as txt "Boxplot saved as: " as res "`boxfile'"
        }
    }

    cap frame change default
end
