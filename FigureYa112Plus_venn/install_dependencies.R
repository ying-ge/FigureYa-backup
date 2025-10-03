#!/usr/bin/env Rscript
# 专门安装地理空间相关R包的脚本

# 设置下载选项
options(repos = c(CRAN = "https://cloud.r-project.org/"))
options(timeout = 600)
options(download.file.method = "libcurl")
options(Ncpus = 4)  # 使用多核编译

# 检查包是否已安装
is_installed <- function(pkg) {
  pkg %in% rownames(installed.packages())
}

# 安装地理空间核心包（使用系统依赖）
install_geo_core_packages <- function() {
  cat("安装地理空间核心包...\n")
  
  # 这些包需要系统依赖，现在应该可以顺利安装
  core_geo_packages <- c(
    "sf",        # 简单要素，最重要的地理空间包
    "units",     # 单位处理
    "raster",    # 栅格数据处理
    "stars",     # 多维栅格数据
    "leaflet"    # 交互式地图
  )
  
  for (pkg in core_geo_packages) {
    if (!is_installed(pkg)) {
      cat("安装:", pkg, "\n")
      tryCatch({
        install.packages(pkg, configure.args = c(
          "--with-proj-lib=/usr/lib/x86_64-linux-gnu",
          "--with-gdal-lib=/usr/lib/x86_64-linux-gnu"
        ))
        if (is_installed(pkg)) {
          cat("✓", pkg, "安装成功\n")
        }
      }, error = function(e) {
        cat("⚠", pkg, "安装遇到问题:", e$message, "\n")
        # 尝试简单安装
        tryCatch({
          install.packages(pkg)
          cat("✓", pkg, "通过简单安装成功\n")
        }, error = function(e2) {
          cat("✗", pkg, "完全安装失败\n")
        })
      })
    } else {
      cat("✓", pkg, "已安装\n")
    }
  }
}

# 安装地图可视化包
install_map_packages <- function() {
  cat("安装地图可视化包...\n")
  
  map_packages <- c(
    "mapview",    # 交互式地图查看
    "tmap",       # 主题地图
    "leafem",     # leaflet扩展
    "leafpop",    # leaflet弹出窗口
    "leafgl",     # leafletWebGL渲染
    "leaflegend", # leaflet图例
    "leafsync",   # leaflet同步
    "maptiles",   # 地图瓦片
    "tmaptools",  # tmap工具
    "satellite"   # 卫星数据
  )
  
  for (pkg in map_packages) {
    if (!is_installed(pkg)) {
      cat("安装:", pkg, "\n")
      tryCatch({
        install.packages(pkg)
        if (is_installed(pkg)) {
          cat("✓", pkg, "安装成功\n")
        }
      }, error = function(e) {
        cat("⚠", pkg, "安装失败:", e$message, "\n")
      })
    } else {
      cat("✓", pkg, "已安装\n")
    }
  }
}

# 安装ggVennDiagram
install_ggVennDiagram_safe <- function() {
  if (is_installed("ggVennDiagram")) {
    cat("✓ ggVennDiagram 已经安装\n")
    return(TRUE)
  }
  
  cat("安装 ggVennDiagram...\n")
  
  # 方法1: 直接从CRAN安装
  tryCatch({
    install.packages("ggVennDiagram")
    if (is_installed("ggVennDiagram")) {
      cat("✓ ggVennDiagram 从CRAN安装成功\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("CRAN安装失败:", e$message, "\n")
  })
  
  # 方法2: 从GitHub安装
  tryCatch({
    if (!is_installed("remotes")) install.packages("remotes")
    remotes::install_github("gaospecial/ggVennDiagram")
    if (is_installed("ggVennDiagram")) {
      cat("✓ ggVennDiagram 从GitHub安装成功\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("GitHub安装失败:", e$message, "\n")
  })
  
  # 方法3: 安装特定版本
  tryCatch({
    install.packages("https://cran.r-project.org/src/contrib/Archive/ggVennDiagram/ggVennDiagram_1.2.0.tar.gz", 
                    repos = NULL, type = "source")
    if (is_installed("ggVennDiagram")) {
      cat("✓ ggVennDiagram 从存档安装成功\n")
      return(TRUE)
    }
  }, error = function(e) {
    cat("存档安装失败:", e$message, "\n")
  })
  
  return(FALSE)
}

# 安装其他必要包
install_other_packages <- function() {
  cat("安装其他必要包...\n")
  
  other_packages <- c(
    "export", "ggplot2", "openxlsx", "stringr", 
    "rgeos", "devtools", "remotes"
  )
  
  for (pkg in other_packages) {
    if (!is_installed(pkg)) {
      cat("安装:", pkg, "\n")
      install.packages(pkg)
      cat("✓", pkg, "安装完成\n")
    } else {
      cat("✓", pkg, "已安装\n")
    }
  }
}

# 验证地理空间包安装
verify_geo_installation <- function() {
  cat("\n验证地理空间包安装...\n")
  
  # 关键地理空间包
  critical_geo <- c("sf", "raster", "leaflet")
  for (pkg in critical_geo) {
    if (is_installed(pkg)) {
      cat("✓", pkg, "已安装\n")
      # 测试加载
      tryCatch({
        library(pkg, character.only = TRUE)
        cat("  → 加载成功\n")
      }, error = function(e) {
        cat("  ⚠ 加载失败:", e$message, "\n")
      })
    } else {
      cat("✗", pkg, "未安装\n")
    }
  }
}

# 验证所有必要包
verify_installation <- function() {
  cat("\n验证所有必要包安装...\n")
  
  required <- c("export", "ggplot2", "openxlsx", "stringr", "rgeos")
  venn_packages <- c("ggVennDiagram", "VennDiagram", "ggvenn")
  
  all_ok <- TRUE
  
  for (pkg in required) {
    if (is_installed(pkg)) {
      cat("✓", pkg, "已安装\n")
    } else {
      cat("✗", pkg, "未安装\n")
      all_ok <- FALSE
    }
  }
  
  venn_installed <- any(sapply(venn_packages, is_installed))
  if (venn_installed) {
    installed_venn <- venn_packages[sapply(venn_packages, is_installed)]
    cat("✓ Venn图包已安装:", paste(installed_venn, collapse = ", "), "\n")
  } else {
    cat("✗ 没有Venn图包安装\n")
    all_ok = FALSE
  }
  
  return(all_ok)
}

# 主函数
main <- function() {
  cat("开始安装，系统依赖已就绪...\n")
  cat("===========================================\n")
  
  # 安装其他必要包
  install_other_packages()
  
  # 安装地理空间核心包
  cat("\n安装地理空间核心包...\n")
  install_geo_core_packages()
  
  # 安装地图可视化包
  cat("\n安装地图可视化包...\n")
  install_map_packages()
  
  # 安装ggVennDiagram
  cat("\n安装ggVennDiagram...\n")
  install_ggVennDiagram_safe()
  
  # 验证安装
  cat("\n===========================================\n")
  verify_geo_installation()
  success <- verify_installation()
  
  if (success) {
    cat("\n✅ 所有包安装成功！\n")
    cat("现在可以运行 FigureYa112Plus_venn.Rmd 了。\n")
  } else {
    cat("\n⚠ 有些包可能安装有问题，但主要功能应该可用。\n")
  }
}

# 执行安装
main()
