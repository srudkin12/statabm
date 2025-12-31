*! ballsummary v1.1.0 31dec2025
program ballsummary
    version 16.0
    * Added CSVfile option to syntax
    syntax [varlist], [CSVfile(string)]

    * 1. Check if the required frame exists
    cap frame change BM_MERGED
    if _rc {
        di as error "Error: Frame BM_MERGED not found. Please run 'ballmapper' first."
        exit 111
    }

    * 2. Identify variables to summarize
    if "`varlist'" == "" {
        ds ball_id orig_obs_id, not
        local varlist `r(varlist)'
    }

    di as txt "Calculating landmark summaries for: " as res "`varlist'"

    * 3. Prepare the Summary Frame
    cap frame drop BM_SUMMARY
    
    * 4. Use a temporary frame to perform the aggregation
    cap frame drop BM_TEMP_SUM
    frame copy BM_MERGED BM_TEMP_SUM
    
    frame BM_TEMP_SUM {
        collapse (mean) `varlist' (count) ball_density=orig_obs_id, by(ball_id)
        
        label var ball_id "Landmark ID"
        label var ball_density "Points inside Ball"
        
        tempfile sum_results
        save "`sum_results'"
    }
    cap frame drop BM_TEMP_SUM

    * 5. Load results into BM_SUMMARY
    frame create BM_SUMMARY
    frame BM_SUMMARY {
        use "`sum_results'", clear
        sort ball_id
        
        * --- NEW: Export to CSV logic ---
        if "`csvfile'" != "" {
            * Ensure file extension is .csv
            if strpos("`csvfile'", ".") == 0 {
                local csvfile "`csvfile'.csv"
            }
            export delimited using "`csvfile'", replace
            di as txt "Summary statistics exported to: " as res "`csvfile'"
        }

        di as txt "Summary table created in frame: " as res "BM_SUMMARY"
        list ball_id ball_density `varlist' in 1/10, separator(0) divider
    }

    * 6. Return to the default frame
    cap frame change default
end
