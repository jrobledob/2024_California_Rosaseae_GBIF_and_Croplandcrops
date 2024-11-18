Here’s a **README.md** file based on the information you provided. You can save this file as `README.md` in your GitHub repository.

---

# Adjacency Matrix for Rosaceae Detections in GBIF and Stone Fruits in California

This repository contains the resources and scripts to develop an adjacency matrix for Rosaceae detections in the GBIF dataset and stone fruits from croplandCROPS in California. Below are the steps and scripts provided in this repository:

---

## Steps to Reproduce the Analysis

### 1. **Download and Process the Rosaceae Dataset**
   - Download the Rosaceae dataset from GBIF.
   - Create a raster file from the dataset using the script:
     - **`GBIF-host-density.R`**

### 2. **Download and Process CroplandCROPS Raster**
   - Download the croplandCROPS raster dataset for California.
   - Select relevant hosts: peaches, apples, almonds, cherries, apricots, plums, and nectarines.
   - Aggregate the data with a factor of 40 using the script:
     - **`croplandCROS-density.R`**

### 3. **Set Resolution and Extent**
   - Match the resolution and extent of the two datasets:
     - The GBIF dataset is forced to fit the croplandCROPS raster.
     - Delete GBIF raster values that are not within California.
   - Perform a weighted sum of the two rasters, with:
     - GBIF: weight = **0.2**
     - CroplandCROPS: weight = **0.8**
   - Normalize the rasters before performing the weighted sum using the script:
     - **`weighted_rasters.R`**

### 4. **Create the Adjacency Matrix**
   - Use the `msean()` function with the following parameters:
     ```r
     msean(rast_C, res = 2, global = FALSE, 
           geoscale = c(-124.5, -114, 32.5, 42),
           link_threshold = cutoff,
           inv_pl = list(beta = c(0.25, 0.5, 0.7, 1, 1.5), 
                         metrics = c("betweeness","NODE_STRENGTH", "Sum_of_nearest_neighbors", "eigenVector_centrAlitY"), 
                         weights = c(50, 15, 15, 20),
                         cutoff = -1), 
           neg_exp = NULL)
     ```
   - Use the script:
     - **`adj_matrix_GEOHABNET.R`**

---

## Required Datasets

Two datasets are required for this analysis but are not included in the repository due to their size. They can be downloaded from the following links:

1. **Rosaceae Dataset (CSV)**  
   - Source: GBIF  
   - [Download Rosaceae.csv](https://uflorida-my.sharepoint.com/:x:/g/personal/jacoborobledobur_ufl_edu/ETlV82Xzdb5Dpf4YO-ZlWCUBwPDrieHNLHRRQMOmhHirYQ?e=21hzeS)

2. **Stone Fruits Raster (TIF)**  
   - Source: croplandCROPS 2023  
   - [Download Stone Fruits 2023.tif](https://uflorida-my.sharepoint.com/:i:/g/personal/jacoborobledobur_ufl_edu/ES1sFPJOm6JDtinvAV_atTMBMFLFwxY0_ASbjgdTbO6TRw?e=CA6EJD)

   *The species included in the stone fruits raster are shown in the image: `filter-stone-fruit-raster.jpg` (included in this repository).*

---

## Repository Contents

| File                       | Description                                                                                     |
|----------------------------|-------------------------------------------------------------------------------------------------|
| **`GBIF-host-density.R`**  | Script to process the GBIF Rosaceae dataset and create a raster.                                |
| **`croplandCROS-density.R`** | Script to process and aggregate the croplandCROPS dataset for stone fruits in California.      |
| **`weighted_rasters.R`**   | Script to normalize, set resolution, and perform the weighted sum of GBIF and croplandCROPS rasters. |
| **`adj_matrix_GEOHABNET.R`** | Script to create an adjacency matrix using the `msean()` function with specified parameters.     |
| **`filter-stone-fruit-raster.jpg`** | Image showing the stone fruits species included in the croplandCROPS dataset.               |

---

## Instructions

1. Clone this repository.
2. Download the required datasets from the provided links.
3. Run the scripts in the specified order to reproduce the adjacency matrix:
   1. **`GBIF-host-density.R`**
   2. **`croplandCROS-density.R`**
   3. **`weighted_rasters.R`**
   4. **`adj_matrix_GEOHABNET.R`**

---

## Contact

If you have questions or encounter issues, please contact:  
**[Jacobo Robledo]**  
**[jacoborobledobur@ufl.edu]**

