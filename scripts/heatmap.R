# ============================
# SNP Matrix to Heatmap in R
# ============================

# Install required package if not already installed
if (!requireNamespace("pheatmap", quietly = TRUE)) {
  install.packages("pheatmap")
}

library(pheatmap)

# ---- Step 1: Load SNP matrix ----
# Assumes CSV file where:
# - Rows and columns are sample IDs
# - First row/column contains headers
# - Values are numeric distances or SNP counts

file_path <- "path/to/snpmatrix.csv"  # Change to your file path

# Read CSV, ensuring row names are set
snpmatrix <- tryCatch({
  read.csv(file_path, row.names = 1, check.names = FALSE)
}, error = function(e) {
  stop("Error reading file: ", e$message)
})

# Validate matrix
if (!all(sapply(snpmatrix, is.numeric))) {
  stop("SNP matrix must contain only numeric values.")
}

# Convert to matrix type
snpmatrix <- read.csv(file_path, row.names = 1, check.names = FALSE, stringsAsFactors = FALSE)
snpmatrix_mat <- as.matrix(snpmatrix)

# determine alphabetical order of rownames and colnames
row_order <- order(rownames(snpmatrix_mat))
col_order <- order(colnames(snpmatrix_mat))

# reorder matrix
snpmatrix_sorted <- snpmatrix_mat[row_order, col_order]

# plot without clustering
pheatmap(
  snpmatrix_sorted,
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  color = colorRampPalette(c("white","#CAF0F8", "#90E0EF", "#00B4D8", "#0077B6", "#03045E"))(100),
  main = "M948-M952 SNP Distance Heatmap"
)

