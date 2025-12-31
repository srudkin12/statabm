{smcl}
{* *! version 29.1  22dec2025}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "ballmapper##syntax"}{...}
{viewerjumpto "Description" "ballmapper##description"}{...}
{viewerjumpto "Options" "ballmapper##options"}{...}
{viewerjumpto "Examples" "ballmapper##examples"}{...}
{title:Title}

{phang}
{bf:ballmapper} {hline 2} Topological Data Analysis (TDA) via landmark clustering and force-directed visualization.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{bf:ballmapper} {varlist} {ifin} {weight} {cmd:,} {opt e:psilon(real)} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt e:psilon(real)}}radius of the balls in the metric space (required).{p_end}
{synopt:{opt c:olor(varname)}}variable used to color the nodes (calculated as mean per ball).{p_end}
{synopt:{opt s:cale(real)}}multiplier for node sizes; default is {cmd:scale(1.0)}.{p_end}
{synopt:{opt l:abels}}display node IDs inside the balls.{p_end}

{syntab:Layout (Physics)}
{synopt:{opt layout}}enable force-directed (spring) layout to reduce overlap.{p_end}
{synopt:{opt r:epulsion(real)}}strength of node-to-node repulsion; default is {cmd:0.05}.{p_end}
{synopt:{opt a:ttraction(real)}}strength of edge-based attraction; default is {cmd:0.1}.{p_end}

{syntab:Output}
{synopt:{opt f:ilename(string)}}prefix for exported .png graph and .csv membership data.{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ballmapper} implements the Ball Mapper algorithm for Topological Data Analysis. It covers a high-dimensional 
point cloud with a set of overlapping balls (landmarks) of radius {cmd:epsilon}. 

{pstd}
Two balls are connected by an edge if they share at least one common observation from the original data. 
This creates a "skeleton" of the data manifold without the information loss typical of linear projections like PCA.

Stored results
    The command stores the following data in new Frames:
    
    BM_RESULTS   Contains the graph structure (nodes and edges) used for plotting.
    BM_MERGED    Contains your original dataset merged with a new column 'ball_id'.
                 Use 'frame change BM_MERGED' to access this data.

{marker options}{...}
{title:Options}

{phang}
{opt epsilon(real)} defines the resolution of the topology. Points within this distance from a landmark 
are considered "covered" by that ball.

{phang}
{opt layout} uses a Fruchterman-Reingold inspired algorithm in Mata to reposition nodes for visual clarity. 
This does not change the underlying topology, only the 2D representation.


{marker examples}{...}
{title:Examples}

{pstd}Setup: Standardize variables to ensure equal weight in distance calculations{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. foreach v in price mpg weight { }}{p_end}
{phang2}{cmd:.    egen z_`v' = std(`v')}{p_end}
{phang2}{cmd:. { }}{p_end}

{pstd}Run Ball Mapper with spring layout{p_end}
{phang2}{cmd:. ballmapper z_price z_mpg z_weight, epsilon(1.2) color(foreign) layout repulsion(0.1) attraction(0.01)}{p_end}



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