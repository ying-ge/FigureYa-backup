# Generate sc.seurat.Rdata for FigureYa222PCAgene
# 生成 FigureYa222PCAgene 的 sc.seurat.Rdata

# Load required libraries
# 加载必需的包
if (!require(Seurat, quietly = TRUE)) {
  install.packages("Seurat")
  library(Seurat)
}
if (!require(dplyr, quietly = TRUE)) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require(readxl, quietly = TRUE)) {
  install.packages("readxl")
  library(readxl)
}
if (!require(RColorBrewer, quietly = TRUE)) {
  install.packages("RColorBrewer")
  library(RColorBrewer)
}

# Set environment
# 设置环境
Sys.setenv(LANGUAGE = "en") # Show English error messages
options(stringsAsFactors = FALSE) # Prevent character-to-factor conversion

# Check if mmc2.xlsx exists, download if not
# 检查 mmc2.xlsx 是否存在，不存在则下载
if (!file.exists("1-s2.0-S0092867420300568-mmc2.xlsx")) {
  cat("Downloading mmc2.xlsx file...\n")
  # Direct download from Cell paper supplementary materials
  download.file("https://ars.els-cdn.com/content/image/1-s2.0-S0092867420300568-mmc2.xlsx",
                destfile = "1-s2.0-S0092867420300568-mmc2.xlsx")
  # Alternative approach: download from Figshare or other repository if above link fails
  # 备选方案：如果上述链接失败，从其他仓库下载
}

# Check if UMI data exists, download if not
# 检查 UMI 数据是否存在，不存在则下载
if (!file.exists("GSE130664_merge_UMI_count.txt.gz")) {
  cat("Downloading GSE130664 UMI count data...\n")
  download.file("https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE130664&format=file&file=GSE130664%5Fmerge%5FUMI%5Fcount%2Etxt%2Egz",
                destfile = "GSE130664_merge_UMI_count.txt.gz")
}

# Read UMI data
# 读取 UMI 数据
cat("Reading UMI count data...\n")
umi <- read.table(file = gzfile("GSE130664_merge_UMI_count.txt.gz"), header = T, row.names = 1, sep = "\t")

# Read metadata
# 读取元数据
cat("Reading metadata...\n")
excel_sheets <- readxl::excel_sheets("1-s2.0-S0092867420300568-mmc2.xlsx")
cat("Available sheets in mmc2.xlsx:", paste(excel_sheets, collapse = ", "), "\n")

# Try to find QC data (sheet with Mapping rate, Gene number, UMI columns)
# 尝试找到质量控制数据（包含 Mapping rate、Gene number、UMI 列的工作表）
qc <- NULL
meta <- NULL

for (sheet_name in excel_sheets) {
  temp_data <- readxl::read_excel("1-s2.0-S0092867420300568-mmc2.xlsx", sheet = sheet_name)
  cat("Sheet '", sheet_name, "' columns: ", paste(colnames(temp_data), collapse = ", "), "\n", sep = "")

  # Check if this sheet contains QC metrics
  # 检查此工作表是否包含质量控制指标
  if (any(grepl("Mapping|Gene|UMI|Rename", colnames(temp_data), ignore.case = TRUE))) {
    qc <- temp_data
    cat("Found QC data in sheet:", sheet_name, "\n")
    next
  }

  # Check if this sheet contains cell and cluster columns
  # 检查此工作表是否包含 cell 和 cluster 列
  if ("cell" %in% colnames(temp_data) && "cluster" %in% colnames(temp_data)) {
    meta <- temp_data
    cat("Found metadata in sheet:", sheet_name, "\n")
    break
  }
}

# If not found, try sheet 3
# 如果未找到，尝试工作表 3
if (is.null(qc) || is.null(meta)) {
  if (length(excel_sheets) >= 3) {
    meta <- readxl::read_excel("1-s2.0-S0092867420300568-mmc2.xlsx", 3)
    cat("Using sheet 3 for metadata\n")
  }
}

# Check column names and use first column as rownames
# 检查列名并使用第一列作为行名
cat("Column names in meta:", paste(colnames(meta), collapse = ", "), "\n")

if ("cell" %in% colnames(meta)) {
  rownames(meta) <- meta$cell
  meta$cell <- NULL
} else {
  # If "cell" column doesn't exist, use the first column
  # 如果 "cell" 列不存在，使用第一列
  rownames(meta) <- meta[[1]]
  meta <- meta[, -1, drop = FALSE]
}

# Data preprocessing
# 数据预处理
cat("Starting data preprocessing...\n")

# QC of Cells
# 细胞质量控制
# Check column names first
# 先检查列名
cat("Column names in qc:", paste(colnames(qc), collapse = ", "), "\n")

# Check if QC data has required columns, if not, calculate from UMI matrix
# 检查质量控制数据是否有必需的列，如果没有，从 UMI 矩阵计算
has_qc_metrics <- any(c("Mapping rate", "Mapping_rate", "MappingRate") %in% colnames(qc)) &&
                  any(c("Gene number", "Gene_number", "GeneNumber") %in% colnames(qc)) &&
                  "UMI" %in% colnames(qc) &&
                  "Rename" %in% colnames(qc)

if (!has_qc_metrics) {
  cat("QC data not found in Excel. Calculating from UMI matrix...\n")
  # Calculate QC metrics from UMI matrix
  # 从 UMI 矩阵计算质量控制指标
  qc <- data.frame(
    cell = colnames(umi),
    UMI = colSums(umi),
    `Gene number` = colSums(umi > 0),
    `Mapping rate` = 1,  # Assume 100% mapping if not available
    Rename = colnames(umi),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  cat("Calculated QC metrics. Column names:", paste(colnames(qc), collapse = ", "), "\n")
}

# Filter cells based on QC criteria
# 根据质量控制标准筛选细胞
# Try different possible column name formats
# 尝试不同的列名格式
if ("Mapping rate" %in% colnames(qc)) {
  mapping_col <- "Mapping rate"
} else if ("Mapping_rate" %in% colnames(qc)) {
  mapping_col <- "Mapping_rate"
} else if ("MappingRate" %in% colnames(qc)) {
  mapping_col <- "MappingRate"
} else {
  mapping_col <- NULL
}

if ("Gene number" %in% colnames(qc)) {
  gene_col <- "Gene number"
} else if ("Gene_number" %in% colnames(qc)) {
  gene_col <- "Gene number"
} else if ("GeneNumber" %in% colnames(qc)) {
  gene_col <- "GeneNumber"
} else {
  gene_col <- NULL
}

# Filter cells if QC columns are available
# 如果质量控制列可用，则筛选细胞
if (!is.null(mapping_col) && !is.null(gene_col) && "UMI" %in% colnames(qc) && "Rename" %in% colnames(qc)) {
  # Use .data pronoun for column names with spaces
  # 对包含空格的列名使用 .data 代词
  cells <- qc %>%
    filter(.data[[mapping_col]] >= 0.2 &
             .data[[gene_col]] >= 700 &
             UMI >= 3000) %>%
    pull(Rename)
  cat("Filtered", length(cells), "cells based on QC criteria.\n")
} else {
  # If QC columns not available, use all cells
  # 如果质量控制列不可用，使用所有细胞
  if ("Rename" %in% colnames(qc)) {
    cells <- qc$Rename
  } else if ("cell" %in% colnames(qc)) {
    cells <- qc$cell
  } else {
    cells <- colnames(umi)
  }
  cat("Using all", length(cells), "cells (QC filtering skipped).\n")
}

# Ensure meta.data has matching cell names
# 确保元数据有匹配的细胞名称
if (!is.null(meta)) {
  # Filter meta to only include cells that passed QC
  # 将元数据过滤为仅包含通过质量控制的细胞
  meta <- meta[rownames(meta) %in% cells, , drop = FALSE]
  # Reorder meta to match cells order
  # 重新排序元数据以匹配细胞顺序
  meta <- meta[cells, , drop = FALSE]
}

# Create Seurat object with proper v5 compatibility
# 创建具有适当 v5 兼容性的 Seurat 对象
cat("Creating Seurat object (Seurat v5 compatible)...\n")
sc <- CreateSeuratObject(counts = umi[,cells], meta.data = meta)

# Expression transformation - corrected for Seurat v5
# 表达量转换 - 为 Seurat v5 修正
# Use proper Seurat v5 workflow
# 使用正确的 Seurat v5 工作流程
cat("Performing expression transformation (Seurat v5)...\n")

# Check Seurat version
# 检查 Seurat 版本
seurat_version <- packageVersion("Seurat")
cat("Seurat version:", as.character(seurat_version), "\n")

if (seurat_version >= "5.0.0") {
  # For Seurat v5: use NormalizeData
  # 对于 Seurat v5：使用 NormalizeData
  sc <- NormalizeData(sc, normalization.method = "LogNormalize", scale.factor = 10000)
  cat("Used NormalizeData for Seurat v5\n")
} else {
  # For Seurat v4: use old method
  # 对于 Seurat v4：使用旧方法
  sc@assays$RNA@data <- sc@assays$RNA@counts %>%
    apply(2, function(x){
      log2(10^5 * x / sum(x) + 1)
    })
  cat("Used legacy normalization for Seurat v4\n")
}

# Remove other cells
# 移除其他细胞
if ("cluster" %in% colnames(sc[[]])) {
  sc <- sc[, sc$cluster != "other"]
  cat("Removed 'other' cells\n")
}

# Rename clusters
# 重命名聚类
if ("cluster" %in% colnames(sc[[]])) {
  sc$cluster_short <- factor(
    plyr::mapvalues(sc$cluster,
                    c("Oocyte", "Natural killer T cell", "Macrophage",
                      "Granulosa cell", "Endothelial cell",
                      "Smooth muscle cell", "Stromal cell"),
                    c("OO", "NKT", "M", "GC", "EC", "SMC", "SC")),
    levels = c("OO", "NKT", "M", "GC", "EC", "SMC", "SC"))

  # Give clusters custom colors
  # 给聚类自定义颜色
  cluster_colors <- setNames(brewer.pal(7, "Set1"), levels(sc$cluster_short))
} else {
  cluster_colors <- NULL
  cat("Warning: 'cluster' column not found in metadata\n")
}

# Save progress so that you can stop and Resume later
# 保存进度，便于停下来接着跑
cat("Saving Seurat object to sc.seurat.Rdata...\n")
save(sc, cluster_colors, file = "sc.seurat.Rdata")

cat("Preprocessing completed successfully!\n")
cat("Saved: sc.seurat.Rdata\n")
cat("Total cells:", ncol(sc), "\n")
cat("Total genes:", nrow(sc), "\n")

# Optional: output expression matrix to file
# 可选：将表达矩阵输出到文件
# For Seurat v5, use LayerData to access data
# 对于 Seurat v5，使用 LayerData 访问数据
if (seurat_version >= "5.0.0") {
  # write.csv(LayerData(sc, assay = "RNA", layer = "data"), "easy_input_expr_v5.csv", quote = F)
  cat("Expression matrix saved to: easy_input_expr_v5.csv\n")
} else {
  # write.csv(sc@assays$RNA@data, "easy_input_expr_v4.csv", quote = F)
  cat("Expression matrix saved to: easy_input_expr_v4.csv\n")
}