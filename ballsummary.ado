*! ballsummary v1.0.1 31dec2025
program ballsummary
    version 16.0
    syntax [varlist], [Clear]

    * 1. Check if the required frame exists
    cap frame change BM_MERGED
    if _rc {
        di as error "Error: Frame BM_MERGED not found. Please run 'ballmapper' first."
        exit 111
    }

    * 2. Identify variables to summarize
    * If no varlist is provided, get all numeric variables except IDs
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
        * Aggregate: Mean of vars, and count of points
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
        di as txt "Summary table created in frame: " as res "BM_SUMMARY"
        
        * Provide a clean preview to the user
        list ball_id ball_density `varlist' in 1/10, separator(0) divider
    }

    * 6. Return to the default frame so the user isn't 'lost'
    cap frame change default
end
