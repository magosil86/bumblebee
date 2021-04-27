# Author:    Lerato E. Magosi
# R version: 4.0.3 (2020-10-10)
# Platform:  x86_64-apple-darwin19.6.0 (64-bit)
# Date:      16Mar2021


# Goal: Estimate transmission flows within and between population groups accounting for
#       sampling heterogeneity


# Required libraries ---------------------------

# library(dplyr)     # needed for sorting and merging data.frames
# library(Hmisc)     # needed for capitalizing elements of a character vector
# library(magrittr)
# library(gtools)    # needed for computing permutations and combinations
# library(DescTools) # needed for computing simultaneous confidence intervals for a multinomial proportions (Goodman, Sison-Glaz)
# library(ACSWR)     # needed for computing Queensbury Hurst simultaneous confidence intervals
# library(CoinMinD)  # needed for computing Queensbury Hurst simultaneous confidence intervals (narrow CIs)
# library(stats)     # needed for the following functions: qchisq
# library(utils)     # needed for the following functions: str, head, tail



# Strategy ---------------------------

# Estimates of transmisison flows are computed using methods from Carnegie and colleagues. 
#     Carnegie NB, Wang R, Novitsky V, De Gruttola V (2014) Linkage of Viral Sequences among 
#     HIV-Infected Village Residents in Botswana: Estimation of Linkage Rates in the Presence 
#     of Missing Data. PLoS Computational Biology 10(1): e1003430. (PMID: 24415932)

# Note: Methods from Carnegie and colleagues are extended to account for direction of transmission
#       between linked pairs


# Function: estimate_transmission_flows ---------------------------
#
# Goal: use counts of observed directed transmission pairs (obtained via phyloscanner) 
#       to estimate transmission flows within and between population groups accounting 
#       for sampling heterogeneity
#
# For details on phyloscanner see PMID: 30926780 and PMID: 29186559
#
# parameters:
#
#
#   group_in                  (character) A vector indicating population groups/strata (e.g. communities, age-groups, genders or trial arms) between which transmission flows will be evaluated, 
#   individuals_sampled_in    (numeric)   A vector indicating the number of individuals sampled per population group, 
#   individuals_population_in (numeric)   A vector of the estimated number of individuals per population group, 
#   linkage_counts_in                     A data.frame of counts of identified/observed linked pairs per population group pairing.
#                                         The data.frame should contain the following three fields: H1_group (character), H2_group (character), number_linked_pairs_observed (numeric).
#                                         For a population group pairing, H1_group and H2_group denote population groups 1 and 2 respectively; and number_linked_pairs_observed denotes 
#                                         the number of observed directed transmission pairs between samples from population groups 1 and 2.
#   verbose_output            (boolean)   A value to display intermediate output                        
#   detailed_report           (boolean)   A value to produce detailed output of the analysis                       
# 
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2 
#     p_hat                            (numeric) Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked                                      
#     est_linkedpairs_in_population    (numeric) Estimated transmission pairs between population groups 1 and 2
#     theta_hat                        (numeric) Estimated transmission flows or relative probability of transmission within and between population groups 1 and 2 adjusted
#                                                for sampling heterogeneity. More precisely, the conditional probability that a pair of pathogen sequences is from a specific population 
#                                                group pairing given that the pair is linked.
#     obs_trm_pairs_est_goodman        (numeric) Point estimate, Goodman method Confidence intervals for observed transmission pairs
#     obs_trm_pairs_lwr_ci_goodman     (numeric) Lower bound of Goodman confidence interval 
#     obs_trm_pairs_upr_ci_goodman     (numeric) Upper bound of Goodman confidence interval 
#     est_goodman                      (numeric) Point estimate, Goodman method Confidence intervals for estimated transmission flows
#     lwr_ci_goodman                   (numeric) Lower bound of Goodman confidence interval 
#     upr_ci_goodman                   (numeric) Upper bound of Goodman confidence interval 
#
#
# The following additional fields are returned if the detailed_report 
#     flag is set
#
#     prob_group_pairing_and_linked    (numeric) Probability that a pair of pathogen sequences is from a specific population group pairing and is linked
#     c_hat                            (numeric) Probability that a randomly selected pathogen sequence in one population group links to at least 
#                                                one pathogen sequence in another population group i.e. probability of clustering
#     est_goodman_cc                   (numeric) Point estimate, Goodman method Confidence intervals with continuity correction
#     lwr_ci_goodman_cc                (numeric) Lower bound of Goodman confidence interval 
#     upr_ci_goodman_cc                (numeric) Upper bound of Goodman confidence interval 
#     est_sisonglaz                    (numeric) Point estimate, Sison-Glaz method Confidence intervals
#     lwr_ci_sisonglaz                 (numeric) Lower bound of Sison-Glaz confidence interval 
#     upr_ci_sisonglaz                 (numeric) Upper bound of Sison-Glaz confidence interval 
#     est_qhurst_acswr                 (numeric) Point estimate, Queensbury-Hurst method Confidence intervals via ACSWR r package 
#     lwr_ci_qhurst_acswr              (numeric) Lower bound of Queensbury-Hurst confidence interval 
#     upr_ci_qhurst_acswr              (numeric) Upper bound of Queensbury-Hurst confidence interval 
#     est_qhurst_coinmind              (numeric) Point estimate, Queensbury-Hurst method Confidence intervals via CoinMinD r package 
#     lwr_ci_qhurst_coinmind           (numeric) Lower bound of Queensbury-Hurst confidence interval
#     upr_ci_qhurst_coinmind           (numeric) Upper bound of Queensbury-Hurst confidence interval
#     lwr_ci_qhurst_adj_coinmind       (numeric) Lower bound of Queensbury-Hurst confidence interval adjusted 
#     upr_ci_qhurst_adj_coinmind       (numeric) Upper bound of Queensbury-Hurst confidence interval adjusted
#
# ------------------------------------------------------------------------------------


estimate_transmission_flows <- function(group_in, 
                                        individuals_sampled_in, 
                                        individuals_population_in, 
                                        linkage_counts_in,
                                        detailed_report = FALSE,
                                        verbose_output = FALSE) {

	# Assemble dataset and prepare input to calculate p_hat
	# Reminder! p_hat denotes the probability that pathogen sequences from two individuals randomly sampled from their
	#           respective population groups are linked.

	results_prepare_input_for_get_p_hat <- prepare_input_for_get_p_hat(group_in, 
																	   individuals_sampled_in, 
																	   individuals_population_in, 
																	   linkage_counts_in, 
																	   verbose_output)

	# Calculate p_hat
	results_get_p_hat <- get_p_hat(results_prepare_input_for_get_p_hat)


	if (detailed_report) {


		# Calculate the probability that a pair of pathogen sequences is from a specific 
		# population group pairing and is linked
		results_get_prob_group_pairing_and_linked <- get_prob_group_pairing_and_linked(results_get_p_hat, individuals_population_in, verbose_output)

		# Calculate theta_hat, the probability that a pair of pathogen sequences is from 
		# a specific population group pairing given that the pair is linked
		results_get_theta_hat <- get_theta_hat(results_get_prob_group_pairing_and_linked)

		# Calculate c_hat, the probability that a randomly selected pathogen sequence 
		# in one population group links to at least one pathogen sequence in another
		# population group i.e. probability of clustering. This excludes linkage to 
		# itself when clustering is estimated within populaton groups. 
		results_get_c_hat <- get_c_hat(results_get_theta_hat)

		# Calculate simultaneous confidence intervals at the 5% significance level
		output <- get_multinomial_proportion_conf_ints_extended(results_get_c_hat, detailed_report = TRUE)

	} else {

		# Calculate theta_hat, the probability that a pair of pathogen sequences is from 
		# a specific population group pairing given that the pair is linked
		results_get_theta_hat <- get_theta_hat(results_get_p_hat)

		# Calculate simultaneous confidence intervals at the 5% significance level with the Goodman method
		output <- get_multinomial_proportion_conf_ints_extended(results_get_theta_hat, detailed_report = FALSE)

	}


	# List of items to return
	base::list(flows_dataset = output)
		

}




# Function: prepare_input_for_get_p_hat ---------------------------
#
# goal: Generate variables required for calculating p_hat
#
# parameters: 
#
#
#   group_in                  (character) A vector indicating population groups/strata (e.g. communities, age-groups, genders or trial arms) between which transmission flows will be evaluated, 
#   individuals_sampled_in    (numeric)   A vector indicating the number of individuals sampled per population group, 
#   individuals_population_in (numeric)   A vector of the estimated number of individuals per population group, 
#   linkage_counts_in                     A data.frame of counts of identified/observed linked pairs per population group pairing.
#                                         The data.frame should contain the following three fields: H1_group (character), H2_group (character), number_linked_pairs_observed (numeric).
#                                         For a population group pairing, H1_group and H2_group denote population groups 1 and 2 respectively; 
#                                         and number_linked_pairs_observed denotes the number of observed directed transmission pairs between samples from population groups 1 and 2.
#   verbose_output            (boolean)   A value to display intermediate output                        
#
#
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2
#
# ------------------------------------------------------------------------------------


prepare_input_for_get_p_hat <- function(group_in, 
                                        individuals_sampled_in, 
                                        individuals_population_in, 
                                        linkage_counts_in, 
                                        verbose_output = FALSE) {

	# Assemble dataset
	group <- base::factor(group_in)

	individuals_sampled <- base::as.numeric(individuals_sampled_in)

	individuals_population <- base::as.numeric(individuals_population_in)

	m <- base::data.frame(group, individuals_sampled, individuals_population)

    # View dataset structure
	if (verbose_output) utils::str(m)


	# Calculate number of groups
	n_groups <- base::nlevels(m$group)

	# Get all possible group pairings
	group_permutations <- base::data.frame(gtools::permutations(n_groups, 2, base::as.character(m$group), repeats.allowed = TRUE))

	base::names(group_permutations) <- base::c("H1_group", "H2_group")

    # View dataset structure
	if (verbose_output) utils::str(group_permutations)	



	get_max_possible_pairs <- function(df_group_permutations, df_number_hosts_per_group) {


        if (verbose_output) {
        
			base::writeLines("\nstr(df_group_permutations): \n")
			utils::str(df_group_permutations)
		
			base::writeLines("str(df_number_hosts_per_group): \n")
			utils::str(df_number_hosts_per_group)
        
        }


		# Calculate max distinct possible pairs in sample for each group pairing

		group_1 <- df_group_permutations[["H1_group"]]
		num_hosts_group_1 <- df_number_hosts_per_group$individuals_sampled[df_number_hosts_per_group$group == group_1]

        if (verbose_output) {
        
			base::writeLines(paste0("\nNumber of hosts in group 1: ", group_1, "\n"))
			base::print(num_hosts_group_1)
        
        }
        
		group_2 <- df_group_permutations[["H2_group"]]
		num_hosts_group_2 <- df_number_hosts_per_group$individuals_sampled[df_number_hosts_per_group$group == group_2]

        if (verbose_output) {
        
			base::writeLines(paste0("\nNumber of hosts in group 2: ", group_2, "\n"))
			base::print(num_hosts_group_2)
        
        }
        
		if (verbose_output) base::writeLines("Max distinct possible linked pairs in sample for current group pairing i.e. individuals_sampled_group_1 * individuals_sampled_group_2: \n")
		if (group_1 == group_2 & !(num_hosts_group_1 == 1)) {
		
		    max_possible_pairs_in_sample <- (num_hosts_group_1 * (num_hosts_group_1 - 1)) / 2
		
		} else {
		
		    max_possible_pairs_in_sample <- num_hosts_group_1 * num_hosts_group_2
		
		}
		
		if (verbose_output) base::print(max_possible_pairs_in_sample)


		# Calculate max distinct possible pairs in population for each group pairing

        individuals_population_group_1 <- df_number_hosts_per_group$individuals_population[df_number_hosts_per_group$group == group_1]
        
		if (verbose_output) {
		
		    base::writeLines("\nEstimated number of individuals in population group 1: \n")
		    base::print(individuals_population_group_1)
		}
		

        individuals_population_group_2 <- df_number_hosts_per_group$individuals_population[df_number_hosts_per_group$group == group_2]
        
		if (verbose_output) {
		
		    base::writeLines("\nEstimated number of individuals in population group 2: \n")
		    base::print(individuals_population_group_2)
		}
        

		if (verbose_output) base::writeLines("Max distinct possible linked pairs in population for current group pairing i.e. individuals_population_group_1 * individuals_population_group_2: \n")
		if (group_1 == group_2) {

		    max_possible_pairs_in_population <- (individuals_population_group_1 * (individuals_population_group_1 - 1)) / 2
		
		} else {

		    max_possible_pairs_in_population <- individuals_population_group_1 * individuals_population_group_2
		
		}

		if (verbose_output) base::print(max_possible_pairs_in_population)


		output <- data.frame("H1_group" = group_1, "H2_group" = group_2, "number_hosts_sampled_group_1" = num_hosts_group_1, "number_hosts_sampled_group_2" = num_hosts_group_2, "number_hosts_population_group_1" = individuals_population_group_1, "number_hosts_population_group_2" = individuals_population_group_2, max_possible_pairs_in_sample, max_possible_pairs_in_population)

		output

	}


	result_get_max_possible_pairs <- base::apply(group_permutations, 1, get_max_possible_pairs, m)


    # Assemble entries in list: result_get_max_possible_pairs into a data.frame using row bind
	number_hosts_per_group_pairing <- base::data.frame()

	for (item in base::seq_along(result_get_max_possible_pairs)) { number_hosts_per_group_pairing <- base::rbind(number_hosts_per_group_pairing, result_get_max_possible_pairs[[item]]) }


    # Attach counts for the number of highly supported linked pairs observed between each group pairing

	# Important! Number of observed links was set to zero where no linked pairs were detected by phyloscanner
	#     between group pairings           

    number_hosts_per_group_pairing <- dplyr::left_join(number_hosts_per_group_pairing, linkage_counts_in, by = c("H1_group", "H2_group"))
    number_hosts_per_group_pairing$num_linked_pairs_observed[is.na(number_hosts_per_group_pairing$num_linked_pairs_observed)] <- 0
	
	number_hosts_per_group_pairing

}



# Function: get_p_hat ---------------------------
#
# Goal: Compute probability that pathogen sequences from two individuals randomly sampled from their respective 
#       population groups (e.g. communities, age-groups, genders or trial arms) are linked.
# 
#       Example: For a group pairing (u,v) this would be the fraction of distinct possible
#                pairs between samples from groups u and v that are linked. Note: The number
#                of distinct possible (u,v) pairs in the sample is the product of sampled 
#                individuals in groups u and v. If u = v, distinct possible pairs is the 
#                number of individuals sampled in population group u choose 2.
#
# parameters:
#
#     df_counts                                  A data.frame returned by the function: 
#                                                prepare_input_for_get_p_hat()
# 
#
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2
#     p_hat                            (numeric) Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked                                      
#
# ------------------------------------------------------------------------------------

      
get_p_hat <- function(df_counts) {

    df_counts$p_hat <- df_counts$num_linked_pairs_observed / df_counts$max_possible_pairs_in_sample

    df_counts

}



# Function: get_prob_group_pairing_and_linked ---------------------------
#
# Goal: Compute probability that a pair is from a specific population group pairing and is linked.
#       Example: For a group pairing (u,v), prob. that a pair is from (u,v) and linked is:
#                (N_uv / N_choose_2) * p_hat_uv
#       where:
#       N_uv = N_u * N_v i.e. maximum distinct possible (u,v) pairs in population.
#       p_hat_uv = fraction of observed (u,v) pairs between samples from population groups 
#                  u and v that are linked.
#       N choose 2 or (N * (N - 1))/2 i.e. all distinct possible pairs in population.
#
# parameters:
#
#     df_counts_and_p_hat                        A data.frame returned by function: 
#                                                get_p_hat()
#     individuals_population_in        (numeric) A vector of the estimated number of individuals 
#                                                per population group 
#     verbose_output                   (boolean) A value to display intermediate output                        
#
#
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2
#     p_hat                            (numeric) Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked                                      
#     prob_group_pairing_and_linked    (numeric) Probability that a pair of pathogen sequences is from a specific population group pairing and is linked
#
# ------------------------------------------------------------------------------------


get_prob_group_pairing_and_linked <- function(df_counts_and_p_hat, individuals_population_in,
                                              verbose_output = FALSE) {

    # View dataset structure
	if (verbose_output) utils::str(df_counts_and_p_hat)

    # Sum up estimated number of individuals in each population group to get total population
	individuals_population <- base::as.numeric(individuals_population_in)
    individuals_population_total <- base::sum(individuals_population)
    if (verbose_output) base::print(individuals_population_total)
    
    # Get all distinct possible pairs in population
    max_possible_pairs_in_total_population <- (individuals_population_total * (individuals_population_total - 1)) / 2
    
    df_counts_and_p_hat$prob_group_pairing_and_linked <- (df_counts_and_p_hat$max_possible_pairs_in_population / max_possible_pairs_in_total_population) * df_counts_and_p_hat$p_hat
    
    df_counts_and_p_hat

}



# Function: get_theta_hat ---------------------------
#
# Goal: Compute the conditional probability that a pair is from a specific population group
#       pairing given the pair is linked.
#       Example: For a group pairing (u,v), theta_hat denotes estimated transmission
#                flows within and between population groups u and v adjusted for sampling
#                heterogeneity.
#
# parameters:
#
#     df_counts_and_p_hat                        A data.frame returned by the function: 
#                                                get_p_hat()
#
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2 
#     p_hat                            (numeric) Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked                                      
#     est_linkedpairs_in_population    (numeric) Estimated transmission pairs between population groups 1 and 2
#     theta_hat                        (numeric) Estimated transmission flows or relative probability of transmission within and between population groups 1 and 2 adjusted
#                                                for sampling heterogeneity. More precisely, the conditional probability that a pair of pathogen sequences is from a specific population 
#                                                group pairing given that the pair is linked.
#
# ------------------------------------------------------------------------------------


get_theta_hat <- function(df_counts_and_p_hat) {

	df_counts_and_p_hat$est_linkedpairs_in_population <- df_counts_and_p_hat$max_possible_pairs_in_population * df_counts_and_p_hat$p_hat

	df_counts_and_p_hat$theta_hat <- df_counts_and_p_hat$est_linkedpairs_in_population / base::sum(df_counts_and_p_hat$est_linkedpairs_in_population)

	df_counts_and_p_hat

}



# Function: get_c_hat ---------------------------
#
# Goal: Compute c_hat, for a group pairing (u,v) c_hat is the probability that a pathogen sequence from
#       an individual in population group u links with pathogen sequences from one or more other individuals
#       in population group v (excluding itself if u = v) i.e. probability of clustering.
#
# parameters:
#
#     df_counts_and_p_hat                        A data.frame returned by the function: 
#                                                get_p_hat()
#
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2 
#     p_hat                            (numeric) Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked                                      
#     c_hat                            (numeric) Probability that a randomly selected pathogen sequence in one population group links to at least 
#                                                one pathogen sequence in another population group i.e. probability of clustering
#
# ------------------------------------------------------------------------------------


get_c_hat <- function(df_counts_and_p_hat) {

	df_counts_and_p_hat$c_hat <- 1 - ((1 - df_counts_and_p_hat$p_hat) ^ df_counts_and_p_hat$number_hosts_population_group_2)

	df_counts_and_p_hat

}



# Calculate simultaneous confidence intervals for a multinomial proportion
#---------------------------


# Function: get_multinomial_proportion_conf_ints ---------------------------
#
# Goal: Compute simultaneous confidence intervals at the 5% significance level
#
# Reminder: Goodman CIs work for fewer cells with larger counts and Sison-Glaz many cells with smaller counts
#
# parameters:
#
#     df_theta_hat                               A data.frame returned by the function: 
#                                                get_theta_hat()
#     detailed_report                  (boolean) A value to produce detailed output of the analysis                       
#
# returns: a data.frame containing:
#
#
#     H1_group                         (Factor)  Name of population group 1 
#     H2_group                         (Factor)  Name of population group 2 
#     number_hosts_sampled_group_1     (numeric) Number of individuals sampled from population group 1
#     number_hosts_sampled_group_2     (numeric) Number of individuals sampled from population group 2
#     number_hosts_population_group_1  (numeric) Estimated number of individuals in population group 1
#     number_hosts_population_group_2  (numeric) Estimated number of individuals in population group 2
#     max_possible_pairs_in_sample     (numeric) Number of distinct possible transmission pairs between individuals sampled from population groups 1 and 2
#     max_possible_pairs_in_population (numeric) Number of distinct possible transmission pairs between individuals in population groups 1 and 2
#     num_linked_pairs_observed        (numeric) Number of observed directed transmission pairs between samples from population groups 1 and 2 
#     p_hat                            (numeric) Probability that pathogen sequences from two individuals randomly sampled from their respective population groups are linked                                      
#     est_linkedpairs_in_population    (numeric) Estimated transmission pairs between population groups 1 and 2
#     theta_hat                        (numeric) Estimated transmission flows or relative probability of transmission within and between population groups 1 and 2 adjusted
#                                                for sampling heterogeneity. More precisely, the conditional probability that a pair of pathogen sequences is from a specific population 
#                                                group pairing given that the pair is linked.
#     obs_trm_pairs_est_goodman        (numeric) Point estimate, Goodman method Confidence intervals for observed transmission pairs
#     obs_trm_pairs_lwr_ci_goodman     (numeric) Lower bound of Goodman confidence interval 
#     obs_trm_pairs_upr_ci_goodman     (numeric) Upper bound of Goodman confidence interval 
#     est_goodman                      (numeric) Point estimate, Goodman method Confidence intervals for estimated transmission flows
#     lwr_ci_goodman                   (numeric) Lower bound of Goodman confidence interval 
#     upr_ci_goodman                   (numeric) Upper bound of Goodman confidence interval 
#
#
# The following additional fields are returned if the detailed_report 
#     flag is set
#
#     est_goodman_cc                   (numeric) Point estimate, Goodman method Confidence intervals with continuity correction
#     lwr_ci_goodman_cc                (numeric) Lower bound of Goodman confidence interval 
#     upr_ci_goodman_cc                (numeric) Upper bound of Goodman confidence interval 
#     est_sisonglaz                    (numeric) Point estimate, Sison-Glaz method Confidence intervals
#     lwr_ci_sisonglaz                 (numeric) Lower bound of Sison-Glaz confidence interval 
#     upr_ci_sisonglaz                 (numeric) Upper bound of Sison-Glaz confidence interval 
#     est_qhurst_acswr                 (numeric) Point estimate, Queensbury-Hurst method Confidence intervals via ACSWR r package 
#     lwr_ci_qhurst_acswr              (numeric) Lower bound of Queensbury-Hurst confidence interval 
#     upr_ci_qhurst_acswr              (numeric) Upper bound of Queensbury-Hurst confidence interval 
#     est_qhurst_coinmind              (numeric) Point estimate, Queensbury-Hurst method Confidence intervals via CoinMinD r package 
#     lwr_ci_qhurst_coinmind           (numeric) Lower bound of Queensbury-Hurst confidence interval
#     upr_ci_qhurst_coinmind           (numeric) Upper bound of Queensbury-Hurst confidence interval
#     lwr_ci_qhurst_adj_coinmind       (numeric) Lower bound of Queensbury-Hurst confidence interval adjusted 
#     upr_ci_qhurst_adj_coinmind       (numeric) Upper bound of Queensbury-Hurst confidence interval adjusted
#
# ------------------------------------------------------------------------------------

      
get_multinomial_proportion_conf_ints_extended <- function(df_theta_hat, detailed_report = FALSE) {

    # Extend MultinomCI function in DescTools to compute Goodman confidence intervals
    # with a continuity correction i.e. goodmancc. 
    # Acknowledgements: 
    # (Steve Cherry, 1996) A Comparison of Confidence Interval Methods for Habitat Use-Availability Studies.
    # The Journal of Wildlife Management, Jul., 1996, Vol. 60, No. 3 (Jul., 1996), pp. 653-658
    # Goodman continuity correction described on pg. 655   
	
	# Define function:
	MultinomCI_mod <- function (x, conf.level = 0.95, sides = c("two.sided", "left", 
		"right"), method = c("sisonglaz", "cplus1", "goodman", "goodmancc",
		"wald", "waldcc", "wilson")) {

		.moments <- function(c, lambda) {
			a <- lambda + c
			b <- lambda - c
			if (b < 0) 
				b <- 0
			if (b > 0) 
				den <- ppois(a, lambda) - ppois(b - 1, lambda)
			if (b == 0) 
				den <- ppois(a, lambda)
			mu <- mat.or.vec(4, 1)
			mom <- mat.or.vec(5, 1)
			for (r in 1:4) {
				poisA <- 0
				poisB <- 0
				if ((a - r) >= 0) {
					poisA <- ppois(a, lambda) - ppois(a - r, lambda)
				}
				if ((a - r) < 0) {
					poisA <- ppois(a, lambda)
				}
				if ((b - r - 1) >= 0) {
					poisB <- ppois(b - 1, lambda) - ppois(b - r - 
					  1, lambda)
				}
				if ((b - r - 1) < 0 && (b - 1) >= 0) {
					poisB <- ppois(b - 1, lambda)
				}
				if ((b - r - 1) < 0 && (b - 1) < 0) {
					poisB <- 0
				}
				mu[r] <- (lambda^r) * (1 - (poisA - poisB)/den)
			}
			mom[1] <- mu[1]
			mom[2] <- mu[2] + mu[1] - mu[1]^2
			mom[3] <- mu[3] + mu[2] * (3 - 3 * mu[1]) + (mu[1] - 
				3 * mu[1]^2 + 2 * mu[1]^3)
			mom[4] <- mu[4] + mu[3] * (6 - 4 * mu[1]) + mu[2] * (7 - 
				12 * mu[1] + 6 * mu[1]^2) + mu[1] - 4 * mu[1]^2 + 
				6 * mu[1]^3 - 3 * mu[1]^4
			mom[5] <- den
			return(mom)
		}
		.truncpoi <- function(c, x, n, k) {
			m <- matrix(0, k, 5)
			for (i in 1L:k) {
				lambda <- x[i]
				mom <- .moments(c, lambda)
				for (j in 1L:5L) {
					m[i, j] <- mom[j]
				}
			}
			for (i in 1L:k) {
				m[i, 4] <- m[i, 4] - 3 * m[i, 2]^2
			}
			s <- colSums(m)
			s1 <- s[1]
			s2 <- s[2]
			s3 <- s[3]
			s4 <- s[4]
			probn <- 1/(ppois(n, n) - ppois(n - 1, n))
			z <- (n - s1)/sqrt(s2)
			g1 <- s3/(s2^(3/2))
			g2 <- s4/(s2^2)
			poly <- 1 + g1 * (z^3 - 3 * z)/6 + g2 * (z^4 - 6 * z^2 + 
				3)/24
			+g1^2 * (z^6 - 15 * z^4 + 45 * z^2 - 15)/72
			f <- poly * exp(-z^2/2)/(sqrt(2) * gamma(0.5))
			probx <- 1
			for (i in 1L:k) {
				probx <- probx * m[i, 5]
			}
			return(probn * probx * f/sqrt(s2))
		}
		n <- sum(x, na.rm = TRUE)
		k <- length(x)
		p <- x/n
		if (missing(method)) 
			method <- "sisonglaz"
		if (missing(sides)) 
			sides <- "two.sided"
		sides <- match.arg(sides, choices = c("two.sided", "left", 
			"right"), several.ok = FALSE)
		if (sides != "two.sided") 
			conf.level <- 1 - 2 * (1 - conf.level)
		method <- match.arg(arg = method, choices = c("sisonglaz", 
			"cplus1", "goodman", "goodmancc", "wald", "waldcc", "wilson"))
		if (method == "goodman") {
			q.chi <- qchisq(conf.level, k - 1)
			lci <- (q.chi + 2 * x - sqrt(q.chi * (q.chi + 4 * x * 
				(n - x)/n)))/(2 * (n + q.chi))
			uci <- (q.chi + 2 * x + sqrt(q.chi * (q.chi + 4 * x * 
				(n - x)/n)))/(2 * (n + q.chi))
			res <- cbind(est = p, lwr.ci = pmax(0, lci), upr.ci = pmin(1, 
				uci))
		}
		else if (method == "goodmancc") {
			q.chi <- qchisq(conf.level, k - 1)
			lci <- (q.chi + 2 * (x - 0.5) - sqrt(q.chi * (q.chi + 4 * (x - 0.5) * 
				(n - x + 0.5)/n)))/(2 * (n + q.chi))
			uci <- (q.chi + 2 * (x + 0.5) + sqrt(q.chi * (q.chi + 4 * (x + 0.5) * 
				(n - x - 0.5)/n)))/(2 * (n + q.chi))
			res <- cbind(est = p, lwr.ci = pmax(0, lci), upr.ci = pmin(1, 
				uci))
		}
		else if (method == "wald") {
			q.chi <- qchisq(conf.level, 1)
			lci <- p - sqrt(q.chi * p * (1 - p)/n)
			uci <- p + sqrt(q.chi * p * (1 - p)/n)
			res <- cbind(est = p, lwr.ci = pmax(0, lci), upr.ci = pmin(1, 
				uci))
		}
		else if (method == "waldcc") {
			q.chi <- qchisq(conf.level, 1)
			lci <- p - sqrt(q.chi * p * (1 - p)/n) - 1/(2 * n)
			uci <- p + sqrt(q.chi * p * (1 - p)/n) + 1/(2 * n)
			res <- cbind(est = p, lwr.ci = pmax(0, lci), upr.ci = pmin(1, 
				uci))
		}
		else if (method == "wilson") {
			q.chi <- qchisq(conf.level, 1)
			lci <- (q.chi + 2 * x - sqrt(q.chi^2 + 4 * x * q.chi * 
				(1 - p)))/(2 * (q.chi + n))
			uci <- (q.chi + 2 * x + sqrt(q.chi^2 + 4 * x * q.chi * 
				(1 - p)))/(2 * (q.chi + n))
			res <- cbind(est = p, lwr.ci = pmax(0, lci), upr.ci = pmin(1, 
				uci))
		}
		else {
			const <- 0
			pold <- 0
			for (cc in 1:n) {
				poi <- .truncpoi(cc, x, n, k)
				if (poi > conf.level && pold < conf.level) {
					const <- cc
					break
				}
				pold <- poi
			}
			delta <- (conf.level - pold)/(poi - pold)
			const <- const - 1
			if (method == "sisonglaz") {
				res <- cbind(est = p, lwr.ci = pmax(0, p - const/n), 
					upr.ci = pmin(1, p + const/n + 2 * delta/n))
			}
			else if (method == "cplus1") {
				res <- cbind(est = p, lwr.ci = pmax(0, p - const/n - 
					1/n), upr.ci = pmin(1, p + const/n + 1/n))
			}
		}
		if (sides == "left") 
			res[3] <- 1
		else if (sides == "right") 
			res[2] <- 0
		return(res)
	}

	# Acknowledgments
	# QH (Queensbury-Hurst) confidence intervals function sourced from CoinMinD package and tweaked 
	#     to report and store the estimate and confidence intervals. 
	# Default behaviour: Print confidence intervals to screen without reporting the estimate. 

	# Define function:
	QH_coinmind_mod <- function(inpmat, alpha) {

		k = base::length(inpmat)
		s = base::sum(inpmat)
		chi = stats::qchisq(1 - alpha, df = k - 1)
		pi = inpmat / s
		QH.UL = (chi + 2 * inpmat + sqrt(chi * chi + 4 * inpmat * 
			chi * (1 - pi)))/(2 * (chi + s))
		QH.LL = (chi + 2 * inpmat - sqrt(chi * chi + 4 * inpmat * 
			chi * (1 - pi)))/(2 * (chi + s))
		LLA = 0
		ULA = 0
		for (r in 1:base::length(inpmat)) {
			if (QH.LL[r] < 0) 
				LLA[r] = 0
			else LLA[r] = QH.LL[r]
			if (QH.UL[r] > 1) 
				ULA[r] = 1
			else ULA[r] = QH.UL[r]
		}
		diA = ULA - LLA
		VOL = base::round(prod(diA), 8)

		output <- base::cbind("est_qhurst_coinmind" = pi, "lwr_ci_qhurst_coinmind" = QH.LL, "upr_ci_qhurst_coinmind" = QH.UL, "lwr_ci_qhurst_adj_coinmind" = LLA, "upr_ci_qhurst_adj_coinmind" = ULA)

		output

	}


	# Acknowledgments
	# QH (Queensbury-Hurst) confidence intervals function sourced from ACSWR package and tweaked 
	#     to report the estimate as well as confidence intervals. 
	# Default behaviour: Report confidence intervals without the estimate. 

	# Define function:
	QH_CI_acswr_mod <- function(x, alpha) {

	  k <- base::length(x); n <- base::sum(x)
  
	  QH_est <- x / n
  
	  QH_lcl <- (1 / (2 * (base::sum(x) + stats::qchisq(1 - alpha / k, k - 1)))) * 
		  {
			  stats::qchisq(1 - alpha / k, k - 1) + 2 * x - base::sqrt( stats::qchisq(1 - alpha / k, k - 1) * 
			  (stats::qchisq(1 - alpha / k, k - 1) + 4 * x *(base::sum(x) - x) / base::sum(x))) 
	  
		  }
  
	  QH_ucl <- (1 / (2 * (base::sum(x) + stats::qchisq(1 - alpha / k, k - 1)))) *
		  {
			  stats::qchisq(1 - alpha / k, k - 1) + 2 * x + base::sqrt( stats::qchisq(1 - alpha / k, k - 1) *
			  (stats::qchisq(1 - alpha / k, k - 1) + 4 * x * (base::sum(x) - x) / base::sum(x))) 
		  }  
  
	  return(base::cbind("est_qhurst_acswr" = QH_est, "lwr_ci_qhurst_acswr" = QH_lcl, "upr_ci_qhurst_acswr" = QH_ucl))

	}


    # compute multi-nomial confidence intervals
        
    # Note: We scale the estimated transmission pairs in the population such that the sum of the weights
    #       is equal to the observed number of transmission pairs. This is a common approach in survey sampling.
    #       Basically, we express the estimated transmission pairs in the population as proportions then multiply 
    #       by the sum of the observed counts
    weighted_est_linkedpairs_in_population <- (df_theta_hat$est_linkedpairs_in_population / base::sum(df_theta_hat$est_linkedpairs_in_population)) * base::sum(df_theta_hat$num_linked_pairs_observed)

    # compute Goodman confidence intervals for observed transmission events
    obs_trm_pairs_ci_goodman <- base::cbind(df_theta_hat, MultinomCI_mod(df_theta_hat$num_linked_pairs_observed, method="goodman"))
    obs_trm_pairs_ci_goodman <- obs_trm_pairs_ci_goodman %>% dplyr::rename(obs_trm_pairs_est_goodman = est, obs_trm_pairs_lwr_ci_goodman = lwr.ci, obs_trm_pairs_upr_ci_goodman = upr.ci)
 
 	# compute Goodman intervals
    df_theta_hat_goodman <- base::cbind(obs_trm_pairs_ci_goodman, MultinomCI_mod(weighted_est_linkedpairs_in_population, method="goodman"))
    df_theta_hat_goodman <- df_theta_hat_goodman %>% dplyr::rename(est_goodman = est, lwr_ci_goodman = lwr.ci, upr_ci_goodman = upr.ci)


    if (detailed_report) {
    
		# compute Goodman intervals with a continuity correction
		df_theta_hat_goodman_cc <- base::cbind(df_theta_hat_goodman, MultinomCI_mod(weighted_est_linkedpairs_in_population, method="goodmancc"))
		df_theta_hat_goodman_cc <- df_theta_hat_goodman_cc %>% dplyr::rename(est_goodman_cc = est, lwr_ci_goodman_cc = lwr.ci, upr_ci_goodman_cc = upr.ci)

		
		# compute Sison-Glaz intervals
		df_theta_hat_goodman_sisonglaz <- base::cbind(df_theta_hat_goodman_cc, MultinomCI_mod(weighted_est_linkedpairs_in_population, method="sisonglaz"))
		df_theta_hat_goodman_sisonglaz <- df_theta_hat_goodman_sisonglaz %>% dplyr::rename(est_sisonglaz = est, lwr_ci_sisonglaz = lwr.ci, upr_ci_sisonglaz = upr.ci)
	
		# compute Queensbury-Hurst intervals
		df_theta_hat_goodman_sisonglaz_qhurst_acswr <- base::cbind(df_theta_hat_goodman_sisonglaz, QH_CI_acswr_mod(weighted_est_linkedpairs_in_population, 0.05))

		df_theta_hat_goodman_sisonglaz_qhurst_acswr_coinmind <- base::cbind(df_theta_hat_goodman_sisonglaz_qhurst_acswr, QH_coinmind_mod(weighted_est_linkedpairs_in_population, 0.05))
	
		df_theta_hat_goodman_sisonglaz_qhurst_acswr_coinmind <- df_theta_hat_goodman_sisonglaz_qhurst_acswr_coinmind %>% dplyr::arrange(-num_linked_pairs_observed)
    		
	    output <- df_theta_hat_goodman_sisonglaz_qhurst_acswr_coinmind
	    
	} else {
	
        output <- df_theta_hat_goodman %>% dplyr::arrange(-num_linked_pairs_observed)
	
	}

    output

}


