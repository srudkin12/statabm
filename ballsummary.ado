
program ballsummary
    version 16.0
    
    syntax [varlist], [CSVfile(string)]

    * The summary is based upon the most recently generated ballmapper and works in the BM_MERGED frame
    cap frame change BM_MERGED
    if _rc {
        di as error "Error: Frame BM_MERGED not found. Please run 'ballmapper' first."
        exit 111
    }

    * The list of variables to summarise is provided by the user. In this way you can use the real values instead of standardised values for the summaries
    if "`varlist'" == "" {
        ds ball_id orig_obs_id, not
        local varlist `r(varlist)'
    }

    di as txt "Calculating landmark summaries for: " as res "`varlist'"

    cap frame drop BM_SUMMARY
    
    * As with the main code, a temporary frame is used in construction
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

    * The results from the processing in the temporary frame are then moved across to the BM_SUMMARY frame
    frame create BM_SUMMARY
    frame BM_SUMMARY {
        use "`sum_results'", clear
        sort ball_id
        
        if "`csvfile'" != "" {
            
            if strpos("`csvfile'", ".") == 0 {
                local csvfile "`csvfile'.csv"
            }
            export delimited using "`csvfile'", replace
            di as txt "Summary statistics exported to: " as res "`csvfile'"
        }

        di as txt "Summary table created in frame: " as res "BM_SUMMARY"
        list ball_id ball_density `varlist' in 1/10, separator(0) divider
    }

    * The code concludes by returning the user to the default frame for their session. The user may switch back to the summary frame using the change frame options within Stata
    cap frame change default
end
