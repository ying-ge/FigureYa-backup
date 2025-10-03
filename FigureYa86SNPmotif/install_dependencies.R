#!/usr/bin/env Rscript
# 简化的 motifBreakR 安装脚本

# 设置镜像
options(repos = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# 检查包是否已安装
is_installed <- function(pkg) {
  pkg %in% rownames(installed.packages())
}

# 安装Bioconductor包
install_bioc <- function(pkg) {
  if (!is_installed("BiocManager")) {
    install.packages("BiocManager", quiet = TRUE)
  }
  
  if (!is_installed(pkg)) {
    cat("安装:", pkg, "\n")
    BiocManager::install(pkg, update = FALSE, ask = FALSE, quiet = TRUE)
  } else {
    cat("✓", pkg, "已经安装\n")
  }
}

# 安装CRAN包
install_cran <- function(pkg) {
  if (!is_installed(pkg)) {
    cat("安装:", pkg, "\n")
    install.packages(pkg, quiet = TRUE)
  } else {
    cat("✓", pkg, "已经安装\n")
  }
}

# 主安装函数
main <- function() {
  cat("开始安装 motifBreakR 及其依赖...\n")
  cat("=============================================\n")
  
  # 首先安装 BiocManager
  install_cran("BiocManager")
  
  # 安装关键依赖（按照正确顺序）
  cat("\n安装关键依赖...\n")
  bioc_packages <- c(
    "DirichletMultinomial",
    "BiocGenerics",
    "S4Vectors",
    "IRanges",
    "GenomicRanges",
    "Biostrings",
    "rtracklayer"
  )
  
  for (pkg in bioc_packages) {
    install_bioc(pkg)
  }
  
  # 安装 TFBSTools
  cat("\n安装 TFBSTools...\n")
  install_bioc("TFBSTools")
  
  # 安装 motifStack
  cat("\n安装 motifStack...\n")
  install_bioc("motifStack")
  
  # 安装其他Bioconductor包
  cat("\n安装其他依赖...\n")
  other_bioc <- c(
    "Gviz",
    "VariantAnnotation",
    "MotifDb",
    "BSgenome",
    "BiocParallel"
  )
  
  for (pkg in other_bioc) {
    install_bioc(pkg)
  }
  
  # 安装基因组数据
  cat("\n安装基因组数据...\n")
  genome_pkgs <- c(
    "BSgenome.Hsapiens.UCSC.hg19",
    "SNPlocs.Hsapiens.dbSNP142.GRCh37"
  )
  
  for (pkg in genome_pkgs) {
    install_bioc(pkg)
  }
  
  # 安装 motifbreakR
  cat("\n安装 motifbreakR...\n")
  if (!is_installed("motifbreakR")) {
    if (!is_installed("remotes")) {
      install_cran("remotes")
    }
    cat("从GitHub安装 motifbreakR...\n")
    remotes::install_github("Simon-Coetzee/motifBreakR", quiet = TRUE)
  }
  
  # 验证安装
  cat("\n验证安装...\n")
  required <- c("motifbreakR", "TFBSTools", "motifStack", "DirichletMultinomial")
  
  all_installed <- TRUE
  for (pkg in required) {
    if (is_installed(pkg)) {
      cat("✓", pkg, "已安装\n")
    } else {
      cat("❌", pkg, "未安装\n")
      all_installed <- FALSE
    }
  }
  
  cat("\n=============================================\n")
  if (all_installed) {
    cat("✅ 所有包安装成功！\n")
  } else {
    cat("⚠ 部分包安装失败\n")
    cat("可以尝试手动安装:\n")
    cat("BiocManager::install(c('DirichletMultinomial', 'TFBSTools', 'motifStack'))\n")
    cat("remotes::install_github('Simon-Coetzee/motifBreakR')\n")
  }
}

# 执行安装
main()
