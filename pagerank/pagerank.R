#' @param info the data frame oject of the graph, in which headers from and to are REQUIRED
#' @param use_iter whether using iterating method or not, defaultly TRUE 
#' @param iterate_times if using iterating method, this indicates the times, defaultly 100
#' @param d the damping factor, defaultly 0.85
#' @return pr the n*1 matrix of the pageranks of each node
get_pagerank <- function(info, use_iter=TRUE, iterate_times=100, d=0.85){
    # grab all the nodes, i.e. factor levels into one vector
    nodes = levels(unlist(list(info$from, info$to)))
    info$from = factor(info$from, levels=nodes)
    info$to = factor(info$to, levels=nodes)

    # how many nodes?
    nodes_count = length(nodes)

    # get a n*n diagonal matrices describing the count of outbound links for each node
    # outdegree_matrix = diag(as.integer(summary(info$from)))
    inverse_outdegree_matrix = diag(1/as.integer(summary(info$from))) # well, some Inf occur...
    inverse_outdegree_matrix = replace(inverse_outdegree_matrix, is.infinite(inverse_outdegree_matrix), 0) # tricky

    # get the adjacency matrix
    # by scanning the graph of info
    adj_matrix = matrix(0, nodes_count, nodes_count)
    for (i in seq(1, nrow(info))) {
        one_edge = info[i,]
        index_node_from = match(one_edge$from, nodes)
        index_node_to = match(one_edge$to, nodes)
        adj_matrix[index_node_from, index_node_to] = 1
    }

    # get the normalized adjacency matrix
    norm_adj_matrix = t(inverse_outdegree_matrix %*% adj_matrix)

    if(use_iter){
        # if using iterating method

        # first step, initial the pagerank as n*1 matrix
        # t = 0
        pr = as.matrix(rep(1/nodes_count, nodes_count))

        # secondly, iterate!
        # t = i
        for (i in seq(1, iterate_times)) {
            pr = matrix((1-d)/nodes_count, nodes_count, 1) + d * norm_adj_matrix %*% pr

        }
    }
    else{
        # or, another way
        # directly solve it!
        pr = solve(diag(nodes_count) - d * norm_adj_matrix) %*% matrix((1-d)/nodes_count, nodes_count, 1)
    }

    return(pr)
}

#' @param csv_file the path of the csv file of the graph
#' @return info the data frame oject of the graph
get_info <- function(csv_file){
    info <- read.csv(csv_file, header=T, colClasses='factor')
    return(info)
}