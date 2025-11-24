# 本地加载 ggtern 源码（不依赖安装的包）
# Load ggtern source code locally (without depending on installed package)

# 注意：这个脚本加载 ggtern 的核心源码文件，使其可以在不安装 ggtern 包的情况下使用
# Note: This script loads the core source files of ggtern, allowing use without installing the ggtern package

# 加载必要的依赖包
# Load necessary dependency packages
if (!requireNamespace("grid", quietly = TRUE)) {
  stop("grid package is required. Please install it: install.packages('grid')")
}
library(grid)
if (!requireNamespace("proto", quietly = TRUE)) {
  stop("proto package is required. Please install it: install.packages('proto')")
}
library(proto)
if (!requireNamespace("plyr", quietly = TRUE)) {
  stop("plyr package is required. Please install it: install.packages('plyr')")
}
library(plyr)  # 提供 rename 函数 Provides rename function

# 创建 ggint 对象（ggplot2 内部函数的包装）
# Create ggint object (wrapper for ggplot2 internal functions)
source("create_ggint.R", local = FALSE)

# 创建 coord() 工厂函数
# Create coord() factory function
source("coord_factory.R", local = FALSE)

# 设置必要的全局选项
# Set necessary global options
if (is.null(getOption("tern.default.T"))) options(tern.default.T = "x")
if (is.null(getOption("tern.default.L"))) options(tern.default.L = "y")
if (is.null(getOption("tern.default.R"))) options(tern.default.R = "z")
if (is.null(getOption("tern.clockwise"))) options(tern.clockwise = FALSE)
if (is.null(getOption("tern.expand"))) options(tern.expand = 0.05)
if (is.null(getOption("tern.discard.external"))) options(tern.discard.external = FALSE)  # 设置为 FALSE 避免过滤数据点
# 确保在数据转换过程中保留所有列（包括 size）
# Ensure all columns (including size) are preserved during data transformation
if (is.null(getOption("tern.dont_transform"))) options(tern.dont_transform = FALSE)
if (is.null(getOption("tern.breaks.default"))) options(tern.breaks.default = c(0,0.25,0.5,0.75,1))
if (is.null(getOption("tern.breaks.default.minor"))) options(tern.breaks.default.minor = c(0.125,0.375,0.625,0.875))
if (is.null(getOption("tern.showtitles"))) options(tern.showtitles = TRUE)
if (is.null(getOption("tern.showlabels"))) options(tern.showlabels = TRUE)
if (is.null(getOption("tern.showgrid.major"))) options(tern.showgrid.major = TRUE)
if (is.null(getOption("tern.showgrid.minor"))) options(tern.showgrid.minor = TRUE)
if (is.null(getOption("tern.ticks.outside"))) options(tern.ticks.outside = FALSE)
if (is.null(getOption("tern.ticks.showprimary"))) options(tern.ticks.showprimary = TRUE)
if (is.null(getOption("tern.ticks.showsecondary"))) options(tern.ticks.showsecondary = TRUE)
if (is.null(getOption("tern.expand.contour.inner"))) options(tern.expand.contour.inner = 0.02)
if (is.null(getOption("tern.line.ontop"))) options(tern.line.ontop = FALSE)
if (is.null(getOption("tern.title.show"))) options(tern.title.show = TRUE)
if (is.null(getOption("tern.text.show"))) options(tern.text.show = TRUE)

# 加载依赖文件（按依赖顺序）
# Load dependency files (in dependency order)
cat("Loading ggtern source files locally...\n")

# 1. 工具函数（ifthenelse, transform_tern_to_cart 等）- 必须最先加载
source("utilities.R", local = FALSE)

# 2. 坐标转换函数
source("tern-tlr2xy.R", local = FALSE)

# 3. 美学映射
source("aes.R", local = FALSE)

# 4. 坐标系定义（核心）- 必须在 global.R 之前加载，因为它需要 coord_tern
source("coord-tern.R", local = FALSE)

# 5. 全局函数和选项（依赖 coord_tern）
source("global.R", local = FALSE)

# 6. 面板和统计函数
source("panel.R", local = FALSE)

# 7. 未批准图层移除
source("strip-unapproved.R", local = FALSE)

# 8. 主题相关
source("theme.R", local = FALSE)
source("theme-defaults.R", local = FALSE)

# 9. 构建和渲染
source("ggtern-build.R", local = FALSE)

# 10. 构造函数
source("ggtern.R", local = FALSE)

# 11. 覆盖构造函数（使用本地版本）
source("ggtern-constructor.R", local = FALSE)

cat("✓ All ggtern source files loaded successfully!\n")
cat("✓ You can now use ggtern() and coord_tern() functions\n")

