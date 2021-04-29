<!-- badges: start -->
[![R-CMD-check](https://github.com/magosil86/bumblebee/workflows/R-CMD-check/badge.svg)](https://github.com/magosil86/bumblebee/actions)
[![Codecov test coverage](https://codecov.io/gh/magosil86/bumblebee/branch/master/graph/badge.svg)](https://codecov.io/gh/magosil86/bumblebee?branch=master)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/magosil86/bumblebee/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/magosil86/bumblebee.svg)](https://github.com/magosil86/bumblebee/issues)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/bumblebee)](https://cran.r-project.org/package=bumblebee)
<!-- [![CRAN_Logs_Rstudio](https://cranlogs.r-pkg.org/badges/grand-total/bumblebee)](http://cran.rstudio.com/web/packages/bumblebee/index.html) -->

<!-- badges: end -->

## Bumblebee
![bumblebee_transmission_flows_with_title_and_labels_img](https://user-images.githubusercontent.com/8364031/116549613-b4c79580-a8c3-11eb-9415-1330f491e6a0.png)

## Overview

Bumblebee uses counts of directed transmission pairs identified between samples from population groups of interest to estimate the flow of transmissions within and between those population groups accounting for sampling heterogeneity.

Population groups might include: communities, geographical regions, age-gender groupings or arms of a cluster-randomized trial.

### Why is this useful?

Quantifying the contribution of interventions, demographics and geographical factors to shaping patterns of transmission is important for understanding and ultimately controlling the spread of an infectious disease.

### Example application areas include: 

1. quantifying transmission patterns of HIV, the virus causes AIDS, in the context of HIV prevention initiatives such as universal test-and-treat 

2. quantifying transmission patterns of SARS-COV-2, virus causes COVID-19, in the presence of heterogeneous vaccine uptake


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

Load the bumblebee package in your current R session, and try some examples in the [example workflow]()

```
# Load libraries
library(bumblebee)  # for estimating transmission flows and confidence intervals

```

For an overview of available functions in bumblebee, type at the R prompt:

```
* ?estimate_transmission_flows_and_ci()

* ?estimate_p_hat()

* ?estimate_theta_hat()

```

## Details

* To estimate the relative probability of transmissions within and between population groups accounting for variable sampling among population groups, the bumblebee package computes that conditional probability that a pair of individuals is from a specific population group pairing given that the pair is linked.

To read up about the statistical theory behind estimating transmission flows see:

Magosi LE, Yinfeng Z, Golubchick T, De Gruttola V, ..., Lockman S, Essex M, Lipsitch M, 
on behalf of the Botswana Combination Prevention Project and the PANGEA consortium (2021) 
Deep-sequence phylogenetics to quantify patterns of HIV transmission in the context of a 
universal testing and treatment trial – BCPP/ Ya Tsie trial. To submit for publication.


## Getting help

To suggest a new feature, report a bug or ask for help, please provide a reproducible example at: https://github.com/magosil86/bumblebee/issues. Also see reprex to learn more about generating reproducible examples.


## Code of conduct
Contributions are welcome. Please observe the [Contributor Code of Conduct](https://github.com/magosil86/getmstatistic/blob/master/CONDUCT.md) when participating in this project.

## Citation
Magosi LE, Yinfeng Z, Golubchick T, De Gruttola V, ..., Lockman S, Essex M, Lipsitch M, on behalf of the Botswana Combination Prevention Project and the PANGEA consortium (2021) Deep-sequence phylogenetics to quantify patterns of HIV transmission in the context of a universal testing and treatment trial – BCPP/ Ya Tsie trial. To submit for publication.

## Acknowledgements and references.
The bumblebee package extends methods from Carnegie et al and Steve Cherry to estimate transmission flows and confidence intervals
Carnegie, N.B., et al., Linkage of viral sequences among HIV-infected village residents in Botswana: estimation of linkage rates in the presence of missing data. PLoS Computational Biology, 2014. 10(1): p. e1003430.

Cherry, S., A Comparison of Confidence Interval Methods for Habitat Use-Availability Studies. The Journal of Wildlife Management, 1996. 60(3): p. 653-658.

Goodman, L.A., On Simultaneous Confidence Intervals for Multinomial Proportions. Technometrics, 1965. 7(2): p. 247-254.

## Authors.
Lerato E. Magosi and Marc Lipsitch.

## Maintainer.
Lerato E. Magosi lmagosi@hsph.harvard.edu or magosil86@gmail.com

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
