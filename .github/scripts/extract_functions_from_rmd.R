# 安装和加载所需的 R 包
if (!requireNamespace("readr")) install.packages("readr")
if (!requireNamespace("stringr")) install.packages("stringr")
if (!requireNamespace("tidyverse")) install.packages("tidyverse")

library(readr)
library(stringr)
library(tidyverse)

# 函数：提取 Rmd 文件中的 R 代码块
extract_r_code <- function(rmd_file) {
  # 读取 Rmd 文件内容
  lines <- read_lines(rmd_file)
  # 找到 R 代码块的开始和结束
  code_chunks <- which(str_detect(lines, "^```\\{r.*\\}"))
  # 提取代码块内容
  r_code <- c()
  for (i in seq(1, length(code_chunks), by = 2)) {
    start <- code_chunks[i] + 1
    end <- code_chunks[i + 1] - 1
    r_code <- c(r_code, lines[start:end])
  }
  return(r_code)
}

# 函数：提取函数调用
extract_functions <- function(code_lines) {
  # 正则匹配函数调用
  matches <- str_match_all(code_lines, "\\b([a-zA-Z0-9_\\.]+)\\s*\\(")
  # 提取函数名
  functions <- unique(unlist(lapply(matches, function(x) x[, 2])))
  # 去除 NA 和重复项
  functions <- functions[!is.na(functions)]
  return(functions)
}

# 函数：识别函数所在包
identify_packages <- function(functions) {
  package_info <- sapply(functions, function(func) {
    tryCatch({
      # 获取函数所在包
      package <- getAnywhere(func)$where
      # 提取包名
      if (length(package) > 0) {
        package <- package[grepl("package:", package)][1]
        sub("package:", "", package)
      } else {
        NA
      }
    }, error = function(e) NA)
  })
  return(data.frame(Function = names(package_info), Package = package_info, stringsAsFactors = FALSE))
}

# 主函数：处理 Rmd 文件
process_rmd <- function(rmd_file) {
  cat("Processing:", rmd_file, "\n")
  r_code <- extract_r_code(rmd_file)
  functions <- extract_functions(r_code)
  package_info <- identify_packages(functions)
  return(package_info)
}

# 处理文件夹内所有 Rmd 文件
process_rmd_folder <- function(folder_path) {
  rmd_files <- list.files(folder_path, pattern = "\\.Rmd$", full.names = TRUE)
  result <- lapply(rmd_files, process_rmd)
  names(result) <- basename(rmd_files)
  return(result)
}

# 示例：处理当前文件夹下的所有 Rmd 文件
# 修改为您的文件夹路径
result <- process_rmd_folder("path/to/your/rmd/folder")

# 输出结果
print(result)

# 保存到 CSV 文件
write.csv(bind_rows(result, .id = "Filename"), "rmd_functions_packages.csv", row.names = FALSE)
