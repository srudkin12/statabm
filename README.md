BallMapper for Stata (v29.1)

(This code was written with heavy support from Gemini 3 - Documentation will be created in due course)

A Stata implementation of the Ball Mapper algorithm for Topological Data Analysis (TDA). This command allows you to visualize the "shape" of high-dimensional data by creating a network of overlapping landmarks. Unlike dimensionality reduction techniques (like PCA or t-SNE), Ball Mapper preserves the original distances of your data, ensuring no information loss during the landmark discovery phase.

Features

Automatic Landmark Selection: Reduces millions of data points into a manageable set of "balls" based on a user-defined radius ($\epsilon$).
Multi-Dimensional Connectivity: Nodes are connected if they share underlying data points, revealing the topology of the dataset.
Integrated Physics Engine: Includes a Mata-powered force-directed (spring) layout to untangle overlapping nodes.
Visual Analytics: Color nodes by any variable to see how features vary across the data manifold.
Data Export: Automatically creates a long-form dataset mapping every original observation to its respective Ball Mapper nodes.

Installation
Download ballmapper.ado. Place it in your Stata ado folder (usually C:\ado\plus\b\ or ~/Library/Application Support/Stata/ado/plus/b/).

Alternatively, run the script directly in your do-file.SyntaxStataballmapper varlist, epsilon(real) [options]

Required Arguments
varlist: The high-dimensional variables that define the "space" of your data.
epsilon(#): The radius of the balls. A smaller epsilon reveals more detail; a larger epsilon simplifies the shape.
Optionscolor(varname): Colors the nodes based on the mean value of this variable.
layout: Activates the Force-Directed Layout (Spring Engine).
repulsion(real): Sets the strength of the force pushing balls apart (Default: 0.05).
attraction(real): Sets the strength of the "spring" pulling connected balls together (Default: 0.1).
scale(real): Scales the size of the nodes in the final graph.
labels: Displays the Node ID on the graph.
filename(string): Saves the graph as a .png and the membership data as a .csv.

Example: The "Cars" Topology

Using the classic Stata auto dataset to find the "skeleton" of the 1978 car market:

Stata

sysuse auto, clear

* Standardize variables (recommended for TDA)
foreach v in price mpg weight length {
    egen z_`v' = std(`v')
}

* Run Ball Mapper with the Spring Layout
ballmapper z_price z_mpg z_weight z_length, epsilon(1.0) color(foreign) layout repulsion(0.05) attraction(0.01) filename("car_market")

Output Data
The command creates a new frame called BM_LONG_DATA. This is a long-form mapping of your original data:
orig_obs_id: The observation ID from your original dataset.
bm_node_id: The ID of the ball(s) that observation belongs to.This allows you to "zoom in" on specific nodes to see exactly which observations are driving the shape of the graph.

## Citation

If you use this package in your research, please cite both the software and the original algorithm:

**Software:**
Rudkin, S. and Rudkin, W. (2025). ballmapper: Topological Data Analysis for Stata. 
[https://github.com/srudkin12/statabm](https://github.com/srudkin12/statabm)

**Methodology:**
Dłotko, P. (2019). Ball mapper: A shape summary for topological data analysis. 
*arXiv preprint arXiv:1901.07410*.
