library(geohabnet)
library(terra)
# Get the host density
rast_C <- rast("./weighted_sum.tif")
plot(rast_C)
# set the link threshold to 0
cutoff<- 0
try<- msean(rast_C, res = 2, global = FALSE, 
            geoscale = c(-124.5, -114, 32.5, 42),
            link_threshold = cutoff,
            inv_pl = list(beta = c(0.25, 0.5, 0.7, 1, 1.5), 
                          metrics = c("betweeness","NODE_STRENGTH", "Sum_of_nearest_neighbors", "eigenVector_centrAlitY"), 
                          weights = c(50, 15, 15, 20),
                          cutoff = -1), neg_exp = NULL)

# the CCRI results are loaded
CCRI<- try
# Obtain all the matrices
matrices_list <- lapply(1:length(CCRI@rasters$rasters), function(i) CCRI@rasters$rasters[[i]]@amatrix)
# Sum all matrices
sum_matrix <- Reduce("+", matrices_list)
# Calculate the mean matrix by dividing the sum matrix by the number of matrices
mean_matrix <- sum_matrix / length(matrices_list)
# make the diagonal of the mean matrix one
diag(mean_matrix) <- 1
# write in a csv file the mean matrix
write.csv(mean_matrix, "mean_matrix.csv", row.names = FALSE)
