*! Ball Mapper v16.5 (Fixed Mata Conformability & Sacred Default)
cap program drop ballmapper
cap mata: mata drop build_bm()

program ballmapper
    version 16.0
    syntax varlist, Epsilon(real) [Color(varname) Scale(real 1.0) Labels Seed(string) Filename(string)]
    
    // 1. ENSURE WE START AT HOME BASE (default frame)
    qui cwf default
    
    // 2. AGGRESSIVE CLEANUP OF OLD OUTPUTS
    foreach f in BM_LONG_DATA BM_SANDBOX {
        cap frame drop `f'
    }
    
    confirm variable `varlist'
    if "`color'" != "" confirm variable `color'
    if "`seed'" != "" set seed `seed'
    
    // 3. PREPARE ID AND PHYSICAL BACKUP
    cap drop orig_obs_id
    gen double orig_obs_id = _n
    tempfile user_data_file
    qui save "`user_data_file'"
    
    // 4. CREATE SANDBOX & RUN MATA
    frame copy default BM_SANDBOX
    frame BM_SANDBOX {
        mata: build_bm("`varlist'", `epsilon', "`color'")
        
        // Setup Plotting inside Sandbox
        qui {
            sum mean_color if type == "node"
            local v_min : di %9.2f r(min)
            local v_max : di %9.2f r(max)
            local v_25  : di %9.2f r(min) + (r(max)-r(min))*0.25
            local v_50  : di %9.2f r(min) + (r(max)-r(min))*0.50
            local v_75  : di %9.2f r(min) + (r(max)-r(min))*0.75
            
            cap drop bin
            xtile bin = mean_color if type == "node", n(20)
            sum bin, meanonly
            local max_bin = r(max)
        }

        local node_layers ""
        forv i = 1/`max_bin' {
            mata: st_local("hex", sprintf("%g %g %g", round(255*(`i'/`max_bin')), 80, round(255*(1 - `i'/`max_bin'))))
            local node_layers `node_layers' (scatter y x [w=size] if bin == `i' & type == "node", ///
                mcolor("`hex'") mlcolor(black%20) mlwidth(vthin) msize(*`scale'))
        }

        local label_layer ""
        if "`labels'" != "" {
            local label_layer "(scatter y x if type == "node", mlabel(node_id) mlabpos(0) mlabsize(vsmall) mlabcolor(white) msize(0))"
        }

        local r_lab = subinstr("`epsilon'", ".", "_", .)
        local final_name = "`filename'_`r_lab'"
        local leg_order "order(2 "`v_min'" 6 "`v_25'" 11 "`v_50'" 16 "`v_75'" 21 "`v_max'")"
        
        twoway (pcspike y1 x1 y2 x2 if type == "edge", lcolor(black%15) lwidth(vthin)) ///
               `node_layers' `label_layer', aspect(1) title("Ball Mapper: {&epsilon} = `epsilon'") ///
               legend(`leg_order' rows(1) pos(6) size(vsmall) symxsize(small) region(lcolor(white))) ///
               xlabel(none) ylabel(none) xscale(off) yscale(off) graphregion(color(white)) name(BM_Plot, replace)
        
        if "`filename'" != "" graph export "`final_name'.png", replace
    }

    // 5. BUILD LONG-FORM DATA
    frame create BM_LONG_DATA
    frame BM_LONG_DATA {
        mata: st_addobs(rows(BM_MEMBERSHIP_MAT))
        mata: st_addvar("double", ("orig_obs_id", "bm_node_id"))
        mata: st_store(., (1,2), BM_MEMBERSHIP_MAT)
        
        qui merge m:1 orig_obs_id using "`user_data_file'", nogenerate
        qui keep if !missing(bm_node_id)
        
        if "`filename'" != "" export delimited using "`final_name'_long.csv", replace
    }
    
    // 6. FINALIZE
    cap frame drop BM_SANDBOX
    frame change BM_LONG_DATA
    di as res "Iteration Successful. Saved: `final_name'.png"
end

mata:
void build_bm(string scalar vars, real scalar eps, string scalar cvar)
{
    real matrix X, landmarks, Adj
    real colvector is_covered, NodeSizes, NodeColorSum, C, uncovered, owners
    real scalar n, n_vars, n_landmarks, p, i, j, idx, edge_count, row
    external real matrix BM_MEMBERSHIP_MAT
    
    X = st_data(., vars); n = rows(X); n_vars = cols(X)
    C = (cvar != "" ? st_data(., cvar) : J(n, 1, 0))
    is_covered = J(n, 1, 0); landmarks = J(0, n_vars, .)
    BM_MEMBERSHIP_MAT = J(0, 2, .) 
    
    idx = 1
    landmarks = landmarks \ X[idx, .]
    is_covered = is_covered :| (sqrt(rowsum((X :- X[idx, .]):^2)) :<= eps)
    
    while (sum(is_covered) < n) {
        uncovered = select(range(1, n, 1), is_covered :== 0)
        idx = uncovered[ceil(uniform(1, 1) * rows(uncovered))] 
        landmarks = landmarks \ X[idx, .]
        is_covered = is_covered :| (sqrt(rowsum((X :- X[idx, .]):^2)) :<= eps)
    }
    
    n_landmarks = rows(landmarks)
    Adj = J(n_landmarks, n_landmarks, 0); NodeSizes = NodeColorSum = J(n_landmarks, 1, 0)

    for (p=1; p<=n; p++) {
        owners = select(range(1, n_landmarks, 1), sqrt(rowsum((landmarks :- X[p, .]):^2)) :<= eps)
        if (rows(owners) > 0) {
            NodeSizes[owners] = NodeSizes[owners] :+ 1
            NodeColorSum[owners] = NodeColorSum[owners] :+ C[p]
            // FIXED LINE: Avoided redundant J() calls and concatenation issues
            BM_MEMBERSHIP_MAT = BM_MEMBERSHIP_MAT \ (J(rows(owners), 1, p), owners)
            for (i=1; i<=rows(owners); i++) {
                for (j=i+1; j<=rows(owners); j++) Adj[owners[i], owners[j]] = 1
            }
        }
    }

    st_matrix("BM_NODE_VALS", (NodeColorSum :/ NodeSizes))
    edge_count = sum(Adj); result_edges = J(edge_count, 4, .)
    row = 1
    for (i=1; i<=n_landmarks; i++) {
        for (j=i+1; j<=n_landmarks; j++) {
            if (Adj[i, j] == 1) result_edges[row++, .] = landmarks[i, 1..2], landmarks[j, 1..2]
        }
    }

    stata("drop _all") 
    st_addobs(n_landmarks + edge_count)
    st_addvar("double", ("node_id", "size", "x", "y", "mean_color", "x1", "y1", "x2", "y2"))
    st_addvar("str10", "type")
    st_store(range(1, n_landmarks, 1), ("node_id", "size", "x", "y", "mean_color"), (range(1, n_landmarks, 1), NodeSizes, landmarks[., 1..2], st_matrix("BM_NODE_VALS")))
    st_sstore(range(1, n_landmarks, 1), "type", J(n_landmarks, 1, "node"))
    if (edge_count > 0) {
        st_store(range(n_landmarks + 1, n_landmarks + edge_count, 1), ("x1", "y1", "x2", "y2"), result_edges)
        st_sstore(range(n_landmarks + 1, n_landmarks + edge_count, 1), "type", J(edge_count, 1, "edge"))
    }
}
end
