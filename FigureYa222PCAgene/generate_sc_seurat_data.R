# 附：单细胞RNA-seq数据预处理
# 以下代码出自`FigureYa206scHeatmap`，会输出`sc.seurat.Rdata`，可作为以上代码的输入文件。

# ===============================================================================
# 环境设置和库加载
# ===============================================================================
# 加载必要的R包
if (!requireNamespace("Seurat", quietly = TRUE)) {
  install.packages("Seurat")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}
if (!requireNamespace("plyr", quietly = TRUE)) {
  install.packages("plyr")
}
if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
  install.packages("RColorBrewer")
}
if (!requireNamespace("tibble", quietly = TRUE)) {
  install.packages("tibble")
}

library(Seurat)
library(dplyr)
library(readxl)
library(tibble)
library(plyr)
library(RColorBrewer)

# 设置R环境
Sys.setenv(LANGUAGE = "en")  # 显示英文报错信息
options(stringsAsFactors = FALSE)  # 禁止chr转成factor

# ===============================================================================
# 下载单细胞RNA-seq数据
# ===============================================================================
# 1) UMI count，从NCBI GSE130664下载：GSE130664_merge_UMI_count.txt.gz文件
if (!file.exists("GSE130664_merge_UMI_count.txt.gz")) {
  cat("Downloading UMI count data...\n")
  download.file(
    "https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE130664&format=file&file=GSE130664%5Fmerge%5FUMI%5Fcount%2Etxt%2Egz",
    destfile = "GSE130664_merge_UMI_count.txt.gz"
  )
}

# 2) metadata，从例文的Supplementary Tables获得：mmc1.xlsx
if (!file.exists("mmc1.xlsx")) {
  stop("Please download mmc1.xlsx from the supplementary materials of the paper.")
}

# ===============================================================================
# Read data
# ===============================================================================
cat("Reading data files...\n")
umi <- read.table(
  file = gzfile("GSE130664_merge_UMI_count.txt.gz"),
  header = TRUE,
  row.names = 1,
  sep = "\t"
)
qc <- readxl::read_excel("mmc1.xlsx", sheet = 2)
meta <- readxl::read_excel("mmc1.xlsx", 3) %>%
  column_to_rownames("cell")

cat("UMI count matrix dimensions:", dim(umi), "\n")
cat("QC metadata dimensions:", dim(qc), "\n")
cat("Cell metadata dimensions:", dim(meta), "\n")

# ===============================================================================
# 数据预处理
# See Methods: QUANTIFICATION AND STATISTICAL ANALYSIS -> Single-Cell RNA-Seq Data Processing
# ===============================================================================
cat("Performing cell quality control...\n")

# QC of Cells
cells <- qc %>%
  filter(
    `Mapping rate` >= 0.2 &
      `Gene number` >= 700 &
      UMI >= 3000
  ) %>%
  pull(Rename)

cat("Cells passing QC:", length(cells), "\n")

# seurat object
cat("Creating Seurat object...\n")
sc <- CreateSeuratObject(counts = umi[, cells], meta.data = meta)

# expression transformation
cat("Transforming expression data...\n")
# Check Seurat version and use appropriate API
if (packageVersion("Seurat") >= "5.0.0") {
  # For Seurat v5
  sc <- NormalizeData(sc, normalization.method = "LogNormalize",
                     scale.factor = 1e5)
} else {
  # For Seurat v4 and earlier
  sc@assays$RNA@data <- sc@assays$RNA@counts %>%
    apply(2, function(x) {
      log2(10^5 * x / sum(x) + 1)
    })
}

# remove other cells
cat("Removing 'other' cells...\n")
sc <- sc[, sc$cluster != "other"]

# 给cluster改名
cat("Renaming clusters...\n")
sc$cluster_short <- factor(
  plyr::mapvalues(
    sc$cluster,
    c("Oocyte", "Natural killer T cell", "Macrophage",
      "Granulosa cell", "Endothelial cell", "Smooth muscle cell",
      "Stromal cell"),
    c("OO", "NKT", "M", "GC", "EC", "SMC", "SC")
  ),
  levels = c("OO", "NKT", "M", "GC", "EC", "SMC", "SC")
)

# 给cluster自定义颜色
cat("Setting cluster colors...\n")
cluster_colors <- setNames(
  brewer.pal(7, "Set1"),
  levels(sc$cluster_short)
)

# 保存一下，便于停下来接着跑
cat("Saving Seurat object...\n")
save(sc, cluster_colors, file = "sc.seurat.Rdata")

# 还可以把表达矩阵输出到文件
# write.csv(sc@assays$RNA@data, "easy_input_expr.csv", quote = FALSE)

cat("Single-cell data preprocessing completed successfully!\n")
cat("Output files:\n")
cat("- sc.seurat.Rdata: Processed Seurat object\n")
# cat("- easy_input_expr.csv: Expression matrix (optional)\n")
