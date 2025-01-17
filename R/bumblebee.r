#' Bumblebee: Quantify Disease Transmission Within and Between Population Groups
#' 
#' @description
#' Bumblebee uses counts of directed transmission pairs identified between samples
#' from population groups of interest to estimate the flow of transmissions within 
#' and between those population groups accounting for sampling heterogeneity.
#' 
#' Population groups might include: communities, geographical regions, age-gender 
#' groupings or arms of a randomized-clinical trial.
#' 
#' Counts of observed directed transmission pairs can be obtained from deep-sequence 
#' phylogenetic data (via phyloscanner) or known epidemiological contacts. Note: 
#' Deep-sequence data is also commonly referred to as high-throughput or
#' next-generation sequence data. See references to learn more about phyloscanner.
#' 
#' @section The \code{estimate_transmission_flows()} function:
#' To estimate transmission flows, that is, the relative probability of transmission 
#' within and between population groups accounting for variable sampling the among
#' the population groups the function: \code{estimate_transmission_flows_and_ci()}
#' computes the conditional probability, \code{theta_hat} that a pair of pathogen
#' sequences is from a specific population group pairing given that the pair is
#' linked.
#' 
#' For two population groups of interest \eqn{(u,v)} \code{theta_hat} is denoted by 
#' 
#' \deqn{\hat{\theta_{ij}} = Pr(pair from groups (i,j) | pair is linked), where i = u,v and j = u,v .}
#' 
#' To learn more and try some examples, see documentation of the 
#' \code{estimate_transmission_flows()} function and the bumblebee package
#' website \url{https://magosil86.github.io/bumblebee/}.
#' 
#' @seealso See the following functions for details on estimating transmission flows
#' and corresponding confidence intervals: \code{estimate_transmission_flows_and_ci}, 
#' \code{estimate_theta_hat} and \code{estimate_multinom_ci}.
#' 
#' @section Cite the package:
#' Please cite the package using the following reference:
#' Lerato E. Magosi, Marc Lipsitch (2021). Bumblebee: Quantify Disease
#' Transmission Within and Between Population Groups. R package version
#' 0.1.0 \url{https://magosil86.github.io/bumblebee/}
#' 
#' @author 
#' Lerato E. Magosi \email{lmagosi@hsph.harvard.edu} or 
#' \email{magosil86@gmail.com}
#' 
#' @references
#' \enumerate{
#'
#'    \item Magosi LE, et al., Deep-sequence phylogenetics to quantify patterns of 
#'          HIV transmission in the context of a universal testing and treatment
#'          trial – BCPP/ Ya Tsie trial. To submit for publication, 2021.
#'
#'    \item Carnegie, N.B., et al., Linkage of viral sequences among HIV-infected
#' 		 village residents in Botswana: estimation of linkage rates in the 
#' 		 presence of missing data. PLoS Computational Biology, 2014. 10(1): 
#' 		 p. e1003430.
#' 
#'    \item Goodman, L. A. On Simultaneous Confidence Intervals for Multinomial Proportions 
#' 		 Technometrics, 1965. 7, 247-254.
#' 
#'    \item Glaz, J., Sison, C.P. Simultaneous confidence intervals for multinomial proportions. 
#' 		 Journal of Statistical Planning and Inference, 1999. 82:251-262.
#' 
#'    \item May, W.L., Johnson, W.D. Constructing two-sided simultaneous confidence intervals for 
#' 		 multinomial proportions for small counts in a large number of cells. 
#' 		 Journal of Statistical Software, 2000. 5(6).
#' 		 Paper and code available at https://www.jstatsoft.org/v05/i06.
#' 
#'    \item Ratmann, O., et al., Inferring HIV-1 transmission networks and sources of 
#' 		 epidemic spread in Africa with deep-sequence phylogenetic analysis. 
#' 		 Nature Communications, 2019. 10(1): p. 1411.
#' 
#'    \item Sison, C.P and Glaz, J. Simultaneous confidence intervals and sample size determination
#' 		 for multinomial proportions. Journal of the American Statistical Association, 
#' 		 1995. 90:366-369.
#'   
#'    \item Wymant, C., et al., PHYLOSCANNER: Inferring Transmission from Within- and
#' 		 Between-Host Pathogen Genetic Diversity. Molecular Biology and Evolution,
#' 		 2017. 35(3): p. 719-733.
#' }
#' 
#' @docType package
#' @name bumblebee-package
#' @aliases bumblebee
#' 
#' @keywords internal
#' @importFrom dplyr %>%
"_PACKAGE"
