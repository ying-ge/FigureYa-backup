#!/usr/bin/env Rscript
# 修复后的 R 依赖安装脚本
# 专门针对 FigureYa215DNAage.Rmd 的依赖

# 设置镜像
options("repos" = c(CRAN = "https://cloud.r-project.org/"))
options(BioC_mirror = "https://bioconductor.org/")

# 检查包是否已安装
is_package_installed <- function(package_name) {
  return(package_name %in% rownames(installed.packages()))
}

# 安装 CRAN 包
install_cran_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing CRAN package:", package_name, "\n")
    tryCatch({
      install.packages(package_name, dependencies = TRUE)
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# 安装 Bioconductor 包
install_bioc_package <- function(package_name) {
  if (!is_package_installed(package_name)) {
    cat("Installing Bioconductor package:", package_name, "\n")
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager")
      }
      BiocManager::install(package_name, update = FALSE, ask = FALSE)
      cat("Successfully installed:", package_name, "\n")
    }, error = function(e) {
      cat("Failed to install", package_name, ":", e$message, "\n")
    })
  } else {
    cat("Package already installed:", package_name, "\n")
  }
}

# 特殊处理 ChAMP 包安装
install_ChAMP <- function() {
  if (!is_package_installed("ChAMP")) {
    cat("Installing ChAMP package (special handling required)...\n")
    
    # 方法1: 尝试安装旧版本 ChAMP
    tryCatch({
      if (!is_package_installed("BiocManager")) {
        install.packages("BiocManager")
      }
      # 尝试安装较旧的兼容版本
      BiocManager::install("ChAMP", version = "3.16")  # 对应 Bioconductor 3.16
      cat("Successfully installed ChAMP from Bioconductor\n")
    }, error = function(e) {
      cat("Bioconductor installation failed, trying alternative methods...\n")
      
      # 方法2: 从 GitHub 安装开发版
      tryCatch({
        if (!is_package_installed("devtools")) {
          install.packages("devtools")
        }
        devtools::install_github("YuanTian1991/ChAMP")
        cat("Successfully installed ChAMP from GitHub\n")
      }, error = function(e2) {
        cat("GitHub installation failed, trying manual workaround...\n")
        
        # 方法3: 安装替代包
        tryCatch({
          install_cran_package("minfi")
          install_cran_package("ENmix")
          install_cran_package("methylumi")
          cat("Installed alternative methylation analysis packages: minfi, ENmix, methylumi\n")
        }, error = function(e3) {
          cat("All ChAMP installation methods failed\n")
        })
      })
    })
  } else {
    cat("Package already installed: ChAMP\n")
  }
}

cat("Starting R package installation for DNA methylation analysis...\n")
cat("===========================================\n")

# 首先安装 BiocManager（如果尚未安装）
if (!is_package_installed("BiocManager")) {
  install.packages("BiocManager")
}

# 安装 CRAN 包
cat("\nInstalling CRAN packages...\n")
cran_packages <- c("data.table", "wateRmelon", "minfi", "ENmix", "methylumi", "DMRcate")

for (pkg in cran_packages) {
  install_cran_package(pkg)
}

# 安装 Bioconductor 包（除了 ChAMP）
cat("\nInstalling Bioconductor packages...\n")
bioc_packages <- c("limma", "impute", "preprocessCore", "sva", "IlluminaHumanMethylation450kmanifest", "IlluminaHumanMethylationEPICmanifest")

for (pkg in bioc_packages) {
  install_bioc_package(pkg)
}

# 特殊安装 ChAMP
cat("\nInstalling ChAMP (may require special handling)...\n")
install_ChAMP()

# DNA 甲基化分析常用的额外包
cat("\nInstalling additional DNA methylation analysis packages...\n")
additional_packages <- c("RPMM", "lumi", "FDb.InfiniumMethylation.hg19")
for (pkg in additional_packages) {
  if (pkg %in% c("lumi", "FDb.InfiniumMethylation.hg19")) {
    install_bioc_package(pkg)
  } else {
    install_cran_package(pkg)
  }
}

# 系统依赖检查
cat("\nChecking for system dependencies...\n")
if (.Platform$OS.type == "unix") {
  # 编译依赖
  system("sudo apt-get update && sudo apt-get install -y libblas-dev liblapack-dev gfortran libcurl4-openssl-dev libssl-dev")
}

cat("\n===========================================\n")
cat("Package installation completed!\n")

# 验证安装
cat("\nVerifying installation...\n")
required_packages <- c("minfi", "wateRmelon", "data.table", "limma", "DMRcate")
for (pkg in required_packages) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "installed successfully\n")
  } else {
    cat("❌", pkg, "installation failed\n")
  }
}

# 检查 ChAMP 状态
if (is_package_installed("ChAMP")) {
  cat("✅ ChAMP installed successfully\n")
} else {
  cat("⚠️ ChAMP not installed, but alternatives are available:\n")
  cat("   - minfi: Comprehensive methylation array analysis\n")
  cat("   - wateRmelon: Methylation array preprocessing and analysis\n")
  cat("   - ENmix: Background correction and normalization\n")
  cat("   - DMRcate: DMR identification\n")
}

cat("\nYou can now run FigureYa215DNAage.Rmd script!\n")
cat("If ChAMP failed to install, consider using minfi or wateRmelon as alternatives.\n")
