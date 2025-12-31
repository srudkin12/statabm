{smcl}
{* *! version 29.1  31dec2025}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "ballmapper##syntax"}{...}
{viewerjumpto "Description" "ballmapper##description"}{...}
{viewerjumpto "Options" "ballmapper##options"}{...}
{viewerjumpto "Stored Results" "ballmapper##results"}{...}
{viewerjumpto "Examples" "ballmapper##examples"}{...}
{title:Title}

{phang}
{bf:ballmapper} {hline 2} Ball Mapper algorithm for Topological Data Analysis (TDA)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{bf:ballmapper} {varlist} {ifin} {weight} {cmd:,} {opt e:psilon(#)} [{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opt e:psilon(#)}}radius of the balls used to cover the data; determines the scale of the topology{p_end}
{synopt:{opt c:olor(varname)}}variable used to color the nodes (calculated as the mean value per ball){p_end}
{synopt:{opt s:cale(#)}}multiplicative factor for node sizes; default is {cmd:1.0}{p_end}
{synopt:{opt f:ilename(string)}}save the resulting graph to a file (e.g., "mygraph.png"){p_end}
{synopt:{opt l:abels}}display landmark IDs inside the nodes{p_end}

{syntab:Layout (Force-Directed)}
{synopt:{opt l:ayout}}apply a force-directed layout to the graph instead of using raw coordinates{p_end}
{synopt:{opt r:epulsion(#)}}strength of node-to-node repulsion; default is {cmd:0.05}{p_end}
{synopt:{opt a:ttraction(#)}}strength of edge-based attraction; default is {cmd:0.1}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt epsilon()} is required.


{marker description}{...}
{title:Description}

{pstd}
{bf:ballmapper} implements the Ball Mapper algorithm, a tool from Topological Data Analysis (TDA). 
It creates an abstract graph (simplicial complex) that summarizes the shape of high-dimensional 
data. Landmarks are selected greedily to cover the data with balls of radius {it:epsilon}. 
Nodes represent balls, and edges represent non-empty intersections between balls.


{marker results}{...}
{title:Stored Results}

{pstd}
{bf:ballmapper} creates two new frames in memory to facilitate further analysis:

{phang}
{bf:BM_RESULTS}: Contains the graph structure (nodes and edges). Useful for custom plotting.

{phang}
{bf:BM_MERGED}: Contains the original dataset merged with {bf:ball_id}, indicating 
which landmark ball(s) each observation belongs to.


{marker examples}{...}
{title:Examples}

{pstd}Basic usage with coordinate variables x1 and x2:{p_end}
{phang2}{cmd:. ballmapper x1 x2, epsilon(3.5)}{p_end}

{pstd}Coloring nodes by a variable 'income' and saving as a PNG:{p_end}
{phang2}{cmd:. ballmapper x1 x2, epsilon(2.0) color(income) filename("topology_map")}{p_end}

{pstd}Applying a force-directed layout for abstract visualization:{p_end}
{phang2}{cmd:. ballmapper x1 x2 x3 x4, epsilon(5.0) layout labels}{p_end}




{marker citation}{...}
{title:Citation}

{pstd}
If you use {cmd:ballmapper} in your research, please cite: {p_end}

{phang}
Rudkin, S. and Rudkin, W. (2025). ballmapper: Topological Data Analysis for Stata. 
Available at: https://github.com/srudkin12/statabm
{p_end}

{pstd}
The underlying algorithm is based on: {p_end}

{phang}
Dlotko, P. (2019). Ball mapper: A shape summary for topological data analysis. 
arXiv preprint arXiv:1901.07410.
{p_end}

{title:Author}
{pstd}Simon Rudkin, University of Manchester and Wanling Rudkin, University of Exeter{p_end}
{pstd}Support: simon.rudkin@manchester.ac.uk{p_end}