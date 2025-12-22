{smcl}
{* *! version 16.5  22dec2025}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "ballmapper##syntax"}{...}
{viewerjumpto "Description" "ballmapper##description"}{...}
{viewerjumpto "Options" "ballmapper##options"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:ballmapper} {hline 2}}Topological Data Analysis via Ball Mapper Algorithm{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ballmapper} {varlist} {ifin} {weight} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt e:psilon(#)}}Specifies the fixed radius for the balls (Landmark selection threshold).{p_end}
{synopt :{opt c:olor(varname)}}Variable used to color the nodes (averages the value per ball).{p_end}
{synopt :{opt labels}}Display node IDs on the graph.{p_end}
{synopt :{opt filename(string)}}Export graph as PNG and membership as CSV using this prefix.{p_end}
{synopt :{opt seed(string)}}Set random seed for reproducible landmark selection.{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{p std}
{cmd:ballmapper} implements the Ball Mapper algorithm for Topological Data Analysis. It covers the 
data manifold with balls of radius {it:epsilon} and creates an abstract graph where nodes 
represent balls and edges represent non-empty intersections between balls.

{p std}
The command produces a visual graph and a new frame {cmd:BM_LONG_DATA} containing the 
mapping of original observations to their respective balls.

{marker examples}{...}
{title:Examples}

{phang}. ballmapper x1 x2 x3, epsilon(0.5) color(profit) labels{p_end}