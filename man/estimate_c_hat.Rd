% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/driver_estimate_transmissision_flows.r
\name{estimate_c_hat}
\alias{estimate_c_hat}
\alias{c_hat}
\alias{est_c_hat}
\alias{estim_c_hat}
\alias{estimate_c_hat.default}
\title{\code{estimate_c_hat} Estimates probability of clustering}
\usage{
estimate_c_hat(df_counts_and_p_hat, ...)

\method{estimate_c_hat}{default}(df_counts_and_p_hat, ...)
}
\arguments{
\item{df_counts_and_p_hat}{A data.frame returned by the function: \code{\link[=estimate_p_hat]{estimate_p_hat()}}}

\item{\dots}{Further arguments.}
}
\value{
Returns a data.frame containing:
\itemize{
\item H1_group, Name of population group 1
\item H2_group, Name of population group 2
\item number_hosts_sampled_group_1, Number of individuals sampled from population group 1
\item number_hosts_sampled_group_2, Number of individuals sampled from population group 2
\item number_hosts_population_group_1, Estimated number of individuals in population group 1
\item number_hosts_population_group_2, Estimated number of individuals in population group 2
\item max_possible_pairs_in_sample, Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
\item max_possible_pairs_in_population, Number of distinct possible transmission pairs between individuals in population groups 1 and 2
\item num_linked_pairs_observed, Number of observed directed transmission pairs between samples from population groups 1 and 2
\item p_hat, Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked
\item c_hat, Probability that a randomly selected pathogen sequence in one population group links to at least
one pathogen sequence in another population group i.e. probability of clustering
}
}
\description{
This function estimates \code{c_hat}, the probability that a randomly
selected pathogen sequence in one population group links to at least
one pathogen sequence in another population group.
}
\section{Methods (by class)}{
\itemize{
\item \code{default}: Estimates probability of clustering
}}

\examples{
library(bumblebee)
library(dplyr)

# Estimate the probability of clustering between individuals from two population groups of interest

# We shall use the data of HIV transmissions within and between intervention and control
# communities in the BCPP/Ya Tsie HIV prevention trial. To learn more about the data 
# ?counts_hiv_transmission_pairs, ?sampling_frequency and ?estimated_hiv_transmission_flows


# Load and view data
#
# The input data comprises counts of observed directed HIV transmission pairs within and
# between intervention and control communities in the BCPP/Ya Tsie trial, sampling 
# information and the probability of linkage between individuals sampled from
# intervention and control communities (i.e. \code{p_hat})
#
# See ?estimate_p_hat() for details on estimating p_hat
results_estimate_p_hat <- estimated_hiv_transmission_flows[, c(1:10)]

results_estimate_p_hat

# Estimate c_hat
results_estimate_c_hat <- estimate_c_hat(df_counts_and_p_hat = results_estimate_p_hat)

# View results
results_estimate_c_hat

}
\references{
\enumerate{

\item Magosi LE, et al., Deep-sequence phylogenetics to quantify patterns of
HIV transmission in the context of a universal testing and treatment
trial – BCPP/ Ya Tsie trial. To submit for publication, 2021.

\item Carnegie, N.B., et al., Linkage of viral sequences among HIV-infected
village residents in Botswana: estimation of linkage rates in the
presence of missing data. PLoS Computational Biology, 2014. 10(1):
p. e1003430.

}
}
\seealso{
See \code{\link{estimate_p_hat}} to prepare input data to estimate \code{c_hat}
}
