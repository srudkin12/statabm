*! Ball Mapper v29.1 - RESET VERSION
cap mata: mata drop build_bm()
cap program drop ballmapper
cap end 

mata:
void build_bm(real matrix X, real colvector C, real scalar do_layout, real scalar rep, real scalar att)
{
    real matrix landmarks, Adj, diffs, owners, result_edges, pos, force
    real colvector NodeSizes, NodeColorSum, dists
    real scalar n, n_vars, n_landmarks, p, i, j, edge_count, row, found_coverage, k, iter, dist
    external real matrix BM_MEMBERSHIP_MAT
    
    n = rows(X)
    n_vars = cols(X)
    landmarks = J(0, n_vars, .)
    
    for (p=1; p<=n; p++) {
        found_coverage = 0
        n_landmarks = rows(landmarks)
        if (n_landmarks > 0) {
            diffs = landmarks :- J(n_landmarks, 1, X[p, .])
            dists = sqrt(rowsum(diffs :^ 2))
            if (min(dists) <= st_numscalar("BM_EPS")) found_coverage = 1
        }
        if (found_coverage == 0) landmarks = landmarks \ X[p, .]
    }
    
    n_landmarks = rows(landmarks)
    st_numscalar("n_land_found", n_landmarks)
    NodeSizes = J(n_landmarks, 1, 0)
    NodeColorSum = J(n_landmarks, 1, 0)
    Adj = J(n_landmarks, n_landmarks, 0)
    BM_MEMBERSHIP_MAT = J(0, 2, .) 

    for (p=1; p<=n; p++) {
        diffs = landmarks :- J(n_landmarks, 1, X[p, .])
        dists = sqrt(rowsum(diffs :^ 2))
        owners = select(range(1, n_landmarks, 1), dists :<= st_numscalar("BM_EPS"))
        if (rows(owners) > 0) {
            for (k=1; k<=rows(owners); k++) {
                NodeSizes[owners[k]] = NodeSizes[owners[k]] + 1
                NodeColorSum[owners[k]] = NodeColorSum[owners[k]] + C[p]
            }
            BM_MEMBERSHIP_MAT = BM_MEMBERSHIP_MAT \ (J(rows(owners), 1, p), owners)
            if (rows(owners) > 1) {
                for (i=1; i<=rows(owners); i++) {
                    for (j=i+1; j<=rows(owners); j++) {
                        Adj[owners[i], owners[j]] = 1
                        Adj[owners[j], owners[i]] = 1
                    }
                }
            }
        }
    }

    pos = landmarks[., 1..2] 
    if (do_layout == 1) {
        for (iter=1; iter<=150; iter++) {
            force = J(n_landmarks, 2, 0)
            for (i=1; i<=n_landmarks; i++) {
                for (j=1; j<=n_landmarks; j++) {
                    if (i==j) continue
                    diffs = pos[i,.] - pos[j,.]
                    dist = sqrt(sum(diffs:^2)) + 0.01
                    force[i,.] = force[i,.] + (diffs / dist) * (rep / dist)
                    if (Adj[i,j] == 1) force[i,.] = force[i,.] - (diffs * dist * att)
                }
            }
            pos = pos + force * 0.4
        }
    }

    st_matrix("BM_NODE_VALS", (NodeColorSum :/ NodeSizes))
    edge_count = sum(Adj) / 2
    result_edges = J(edge_count, 4, .)
    row = 1
    for (i=1; i<=n_landmarks; i++) {
        for (j=i+1; j<=n_landmarks; j++) {
            if (Adj[i, j] == 1) result_edges[row++, .] = pos[i, 1..2], pos[j, 1..2]
        }
    }

    stata("drop _all")
    st_addobs(n_landmarks + edge_count)
    st_addvar("double", ("node_id", "size", "x", "y", "mean_color", "x1", "y1", "x2", "y2"))
    st_addvar("str10", "type")
    st_store(range(1, n_landmarks, 1), ("node_id", "size", "x", "y", "mean_color"), (range(1, n_landmarks, 1), NodeSizes, pos, st_matrix("BM_NODE_VALS")))
    st_sstore(range(1, n_landmarks, 1), "type", J(n_landmarks, 1, "node"))
    if (edge_count > 0) {
        st_store(range(n_landmarks + 1, n_landmarks + edge_count, 1), ("x1", "y1", "x2", "y2"), result_edges)
        st_sstore(range(n_landmarks + 1, n_landmarks + edge_count, 1), "type", J(edge_count, 1, "edge"))
    }
}
end

program ballmapper
    version 16.0
    syntax varlist, Epsilon(real) [Color(varname) Scale(real 1.0) Labels Filename(string) ///
            Layout Repulsion(real 0.05) Attraction(real 0.1)]
    
    cap frame change default
    foreach f in BM_RESULTS BM_MERGED BM_SANDBOX {
        cap frame drop `f'
    }
    
    scalar BM_EPS = `epsilon'
    local layout_opt = ("`layout'" != "")
    local color_name = "`color'"
    if "`color_name'" == "" local color_name "Value"

    qui {
        tempvar touse
        mark `touse'
        markout `touse' `varlist' `color'
        
        preserve
        keep if `touse'
        gen double orig_obs_id = _n 
        
        tempvar color_data
        if "`color'" != "" gen double `color_data' = `color'
        else gen double `color_data' = 0
        
        mata: BM_X_DATA = st_data(., "`varlist'")
        mata: BM_C_DATA = st_data(., "`color_data'")
        
        tempfile user_data_temp
        save "`user_data_temp'"
    }

    * Sandbox Creation
    cap frame drop BM_SANDBOX
    frame create BM_SANDBOX
    frame BM_SANDBOX {
        mata: build_bm(BM_X_DATA, BM_C_DATA, `layout_opt', `repulsion', `attraction')
        
        qui {
            sum size if type == "node"
            local max_count = r(max)
            gen double size_val = (1.5 + (sqrt(size)/sqrt(max(`max_count', 1))) * 8) * `scale'
            
            sum mean_color if type == "node", detail
            foreach stat in min p25 p50 p75 max {
                local v`stat' = cond(r(`stat')==., 0, r(`stat'))
            }
            
            cap drop bin
            xtile bin = mean_color if type == "node", n(20)
            sum bin, meanonly
            local max_bin = cond(r(max)==., 1, r(max))
        }
        
        forv b = 1/20 {
            qui mata: st_local("hex_`b'", sprintf("%g %g %g", round(255*(`b'/20)), 80, round(255*(1 - `b'/20))))
        }

        local node_layers ""
        forv i = 1/`max_bin' {
            qui levelsof size_val if bin == `i' & type == "node", local(s_levels)
            foreach s in `s_levels' {
                local node_layers `node_layers' (scatter y x if bin == `i' & type == "node" & abs(size_val - `s') < 0.001, mcolor("`hex_`i''") mlcolor(black%40) mlwidth(vthin) msymbol(circle) msize(`s'))
            }
        }
        
        local label_cmd ""
        if "`labels'" != "" local label_cmd (scatter y x if type == "node", mlabel(node_id) mlabpos(0) mlabsize(tiny) mlabcolor(white) msize(0))

        twoway (pcspike y1 x1 y2 x2 if type == "edge", lcolor(black%25) lwidth(vthin)) ///
               (scatter y x if _n==0, mcolor("`hex_1'") msize(3) msymbol(circle)) ///
               (scatter y x if _n==0, mcolor("`hex_5'") msize(3) msymbol(circle)) ///
               (scatter y x if _n==0, mcolor("`hex_10'") msize(3) msymbol(circle)) ///
               (scatter y x if _n==0, mcolor("`hex_15'") msize(3) msymbol(circle)) ///
               (scatter y x if _n==0, mcolor("`hex_20'") msize(3) msymbol(circle)) ///
               `node_layers' `label_cmd', ///
               aspect(1) title("Epsilon: `epsilon'") ///
               legend(order(2 3 4 5 6) ///
                      label(2 "Min: `: display %4.2f `vmin''") label(3 "25%: `: display %4.2f `vp25''") ///
                      label(4 "Med: `: display %4.2f `vp50''") label(5 "75%: `: display %4.2f `vp75''") ///
                      label(6 "Max: `: display %4.2f `vmax''") ///
                      cols(1) pos(3) size(vsmall) region(lcolor(white%0)) subtitle("`color_name'", size(vsmall))) ///
               xlabel(none) ylabel(none) xscale(off) yscale(off) ///
               graphregion(color(white)) name(BM_Plot, replace)

        if "`filename'" != "" {
            if strpos("`filename'", ".") == 0 local filename "`filename'.png"
            graph export "`filename'", replace
        }
    }

    * Merged Data Creation
    cap frame drop BM_MERGED 
    frame create BM_MERGED
    frame BM_MERGED {
        getmata (orig_obs_id ball_id) = BM_MEMBERSHIP_MAT
        merge m:1 orig_obs_id using "`user_data_temp'", nogenerate
        label var ball_id "Ball Mapper Landmark ID"
    }

    * Results Extraction
    cap frame drop BM_RESULTS
    frame copy BM_SANDBOX BM_RESULTS
    cap frame drop BM_SANDBOX

    restore 
    
    di as txt _n "Ball Mapper Successful."
    di as txt " -> Graph data stored in frame: BM_RESULTS"
    di as txt " -> Original data + Ball IDs in frame: BM_MERGED"
end

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
