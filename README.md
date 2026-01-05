BallMapper for Stata 

This repository provides a Stata implementation of the Ball Mapper algorithm for Topological Data Analysis (TDA) as developed in Dlotko (2019). TDABM allows you to visualize the "shape" of high-dimensional data by creating a network of overlapping landmarks. Unlike dimensionality reduction techniques (like PCA or t-SNE), Ball Mapper preserves the original distances of your data, ensuring no information loss during the landmark discovery phase.

Installation:

net install ballmapper, from("https://raw.githubusercontent.com/srudkin12/statabm/main") replace

Documentation:

The paper [https://arxiv.org/abs/2601.00508](https://arxiv.org/abs/2601.00508) contains a guide to the ballmapper package in Stata. The accompanying do files are, statabi1.do for the X data example, autodata.do for the auto data example, and appendix.do for Appendix B. Users are encouraged to use the accompanying guide to follow the .do files. 

## Citation

If you use this package in your research, please cite both the software and the original algorithm:

**Software:**
Rudkin, S. and Rudkin, W. (2025). ballmapper: Topological Data Analysis for Stata. 
[https://github.com/srudkin12/statabm](https://github.com/srudkin12/statabm)

**Methodology:**
Dłotko, P. (2019). Ball mapper: A shape summary for topological data analysis. 
*arXiv preprint arXiv:1901.07410*.

**Bibtex**
@misc{rudkin2026ballmapperapplyingtopologicaldata,
      title={ballmapper: Applying Topological Data Analysis Ball Mapper in Stata}, 
      author={Simon Rudkin and Wanling Rudkin},
      year={2026},
      eprint={2601.00508},
      archivePrefix={arXiv},
      primaryClass={stat.ME},
      url={https://arxiv.org/abs/2601.00508}, 
}
