<!-- badges: start -->
[![R-CMD-check](https://github.com/magosil86/bumblebee/workflows/R-CMD-check/badge.svg)](https://github.com/magosil86/bumblebee/actions)
[![Codecov test coverage](https://codecov.io/gh/magosil86/bumblebee/branch/master/graph/badge.svg)](https://codecov.io/gh/magosil86/bumblebee?branch=master)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/magosil86/bumblebee/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/magosil86/bumblebee.svg)](https://github.com/magosil86/bumblebee/issues)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/bumblebee)](https://cran.r-project.org/package=bumblebee)
<!-- [![CRAN_Logs_Rstudio](https://cranlogs.r-pkg.org/badges/grand-total/bumblebee)](http://cran.rstudio.com/web/packages/bumblebee/index.html) -->

<!-- badges: end -->

## Bumblebee
![bumblebee_transmission_flows_with_title_img](https://user-images.githubusercontent.com/8364031/116499664-b91b9080-a87a-11eb-82be-edc7468946cf.png)

## Overview

Bumblebee uses counts of directed transmission pairs identified between samples from population groups of interest to estimate the flow of transmissions within and between those population groups accounting for sampling heterogeneity.

Population groups might include: communities, geographical regions, age-gender groupings or arms of a cluster-randomized trial.

### Why is this useful?

Quantifying the contribution of interventions, demographics and geographical factors to shaping patterns of transmission is important for understanding and ultimately controlling an infectious disease.

Example application areas include: 

1. quantifying HIV transmission patterns in the context of HIV prevention initiatives such as universal test-and-treat 

2. quantifying SARS-COV-2 transmission patterns in the presence of heterogeneous vaccine uptake


## Installation: bumblebee [**R** package](https://github.com/magosil86/bumblebee)

```{r}
# To install the release version from CRAN:
install.packages("bumblebee")

# Load libraries
library(bumblebee)  # for estimating transmission flows and confidence intervals
library(dplyr)      # for working with data.frames


# To install the development version from GitHub:

# install devtools
install.packages("devtools")

# install bumblebee
library(devtools)
devtools::install_github("magosil86/bumblebee")

# Load libraries
library(bumblebee)  # for estimating transmission flows and confidence intervals
library(dplyr)      # for working with data.frames

```


## Usage

*  Take a look at an [example workflow](https://github.com/magosil86/getmstatistic/blob/master/vignettes/getmstatistic-tutorial.md)

## Details

* Essentially, _M_ statistics are computed by aggregating standardized predicted random effects (SPREs). To read up about the statistical theory behind the _M_ statistic see:

Magosi LE, Goel A, Hopewell JC, Farrall M, on behalf of the CARDIoGRAMplusC4D Consortium (2017) Identifying systematic heterogeneity patterns in genetic association meta-analysis studies. PLoS Genet 13(5): e1006755. [https://doi.org/10.1371/journal.pgen.1006755](https://doi.org/10.1371/journal.pgen.1006755).


## Getting help

To suggest new features, learn about bumblebee updates, report bugs, ask questions, or just interact with other users, sign up to the [getmstatistic](https://groups.google.com/forum/#!forum/getmstatistic) mailing list.


## Code of conduct
Contributions are welcome. Please observe the [Contributor Code of Conduct](https://github.com/magosil86/getmstatistic/blob/master/CONDUCT.md) when participating in this project.

## Citation
Magosi LE, Goel A, Hopewell JC, Farrall M, on behalf of the CARDIoGRAMplusC4D Consortium (2017) Identifying systematic heterogeneity patterns in genetic association meta-analysis studies. PLoS Genet 13(5): e1006755. [https://doi.org/10.1371/journal.pgen.1006755](https://doi.org/10.1371/journal.pgen.1006755).


## Acknowledgements.
Roger M. Harbord’s metareg command for computation of standardized predicted random effects which are then incorporated into calculations for the _M_ statistics. Harbord, R. M., & Higgins, J. P. T. (2008). Meta-regression in Stata. Stata Journal 8: 493‚Äì519.


## Authors.
Lerato E. Magosi, Jemma C. Hopewell and Martin Farrall.

## Maintainer.
Lerato E. Magosi lmagosi@well.ox.ac.uk or magosil86@gmail.com

## License

See the [LICENSE](https://github.com/magosil86/getmstatistic/blob/master/LICENSE) file.


## Welcome to GitHub Pages

You can use the [editor on GitHub](https://github.com/magosil86/bumblebee/edit/gh-pages/index.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/magosil86/bumblebee/settings/pages). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://support.github.com/contact) and we’ll help you sort it out.
