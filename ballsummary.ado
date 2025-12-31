program ballsummary
    version 16.0
    syntax [varlist], [Clear]

    * 1. Check if the required frame exists
    cap frame change BM_MERGED
    if _rc {
        di as error "Error: Frame BM_MERGED not found. Please run 'ballmapper' first."
        exit 111
    }

    * 2. If no varlist is provided, use all numeric variables from the original data
    if "`varlist'" == "" {
        ds ball_id orig_obs_id, not
        local varlist `r(varlist)'
    }

    di as txt "Generating summary statistics for `r(N)' observations across landmarks..."

    * 3. Create the summary frame
    cap frame drop BM_SUMMARY
    frame create BM_SUMMARY
    
    * 4. Perform the calculation
    * We calculate Mean, SD, and Count for every variable in the varlist
    frame BM_MERGED: statsby `varlist' n=(_b[ball_id]), by(ball_id) saving("`temp_stats'", replace): summarize
    
    * Alternatively, a faster approach using collapse:
    frame copy BM_MERGED BM_TEMP_SUM
    frame BM_TEMP_SUM {
        collapse (mean) `varlist' (count) point_count=orig_obs_id, by(ball_id)
        label var point_count "Number of points in ball"
        tempfile sum_data
        save "`sum_data'"
    }
    cap frame drop BM_TEMP_SUM

    * 5. Load results into the Summary Frame
    frame BM_SUMMARY {
        use "`sum_data'", clear
        sort ball_id
        di as res _n "Summary table created in frame: BM_SUMMARY"
        list in 1/10
    }

    * 6. Return to default frame
    frame change default
end
