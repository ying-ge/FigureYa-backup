# install_dependencies.R - 修复后的纯 R 版本

cat("===========================================\n")
cat("安装 FigureYa197SmoothHaz.Rmd 所需依赖\n")
cat("===========================================\n")

# 设置镜像
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# 检查包是否已安装
is_package_installed <- function(package_name) {
  package_name %in% rownames(installed.packages())
}

# 安装函数
install_if_needed <- function(pkg) {
  if (!is_package_installed(pkg)) {
    cat("安装:", pkg, "\n")
    tryCatch({
      install.packages(pkg, dependencies = TRUE, quiet = TRUE)
      cat("✅ 成功安装:", pkg, "\n")
    }, error = function(e) {
      cat("❌ 安装失败:", pkg, "-", e$message, "\n")
    })
  } else {
    cat("✅ 已安装:", pkg, "\n")
  }
}

# 安装核心包
cat("安装核心包...\n")
core_packages <- c(
  "cowplot", "dplyr", "ggplot2", "muhaz", 
  "openxlsx", "survival", "survminer", "remotes",
  "Rttf2pt1", "extrafontdb"
)

for (pkg in core_packages) {
  install_if_needed(pkg)
}

# 特殊处理 extrafont
cat("处理 extrafont...\n")
if (!is_package_installed("extrafont")) {
  # 尝试从 CRAN 安装
  install_if_needed("extrafont")
  
  # 如果失败，尝试其他方法
  if (!is_package_installed("extrafont")) {
    cat("尝试替代方法安装 extrafont...\n")
    tryCatch({
      remotes::install_version("extrafont", version = "0.19")
    }, error = function(e) {
      cat("版本安装失败，尝试从 GitHub 安装...\n")
      remotes::install_github("wch/extrafont")
    })
  }
}

# 验证安装
cat("验证安装...\n")
required <- c("survival", "survminer", "muhaz", "ggplot2", "extrafont")
for (pkg in required) {
  if (is_package_installed(pkg)) {
    cat("✅", pkg, "安装成功\n")
  } else {
    cat("❌", pkg, "安装失败\n")
  }
}

# 初始化字体（如果安装成功）
if (is_package_installed("extrafont")) {
  cat("初始化字体系统...\n")
  library(extrafont)
  tryCatch({
    if (length(fonts()) == 0) {
      cat("导入字体（可能需要几分钟）...\n")
      font_import(prompt = FALSE)
    }
    loadfonts(quiet = TRUE)
    cat("字体初始化完成\n")
  }, error = function(e) {
    cat("字体初始化失败:", e$message, "\n")
  })
}

cat("===========================================\n")
cat("安装完成！\n")
cat("===========================================\n")
