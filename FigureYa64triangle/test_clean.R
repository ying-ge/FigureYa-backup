# 完全干净的测试脚本
# Clean test script

# 清除所有变量和函数
rm(list = ls(all.names = TRUE))

# 重新加载库
library(ggplot2)
library(grid)
library(proto)
library(plyr)
library(tidyverse)
library(scales)
library(directlabels)

Sys.setenv(LANGUAGE = 'en')
options(stringsAsFactors = FALSE)

cat('========================================\n')
cat('Clean Environment Test\n')
cat('========================================\n\n')

# 重新加载 ggtern 源码
cat('1. Loading ggtern source...\n')
source('load_ggtern_local.R')

cat('\n2. Testing theme_gray()...\n')
tryCatch({
  th <- theme_gray()
  cat('   ✓ theme_gray() works!\n')
}, error = function(e) {
  cat('   ❌ ERROR:', e$message, '\n')
  traceback()
  stop('Test failed')
})

cat('\n3. Testing complete workflow...\n')
tryCatch({
  df <- data.frame(x = 0.3, y = 0.3, z = 0.4)
  p <- ggtern(df, aes(x = x, y = y, z = z)) + 
    geom_point(size = 3, color = 'red') +
    theme_gray()
  cat('   ✓ Complete workflow works!\n')
}, error = function(e) {
  cat('   ❌ ERROR:', e$message, '\n')
  traceback()
  stop('Test failed')
})

cat('\n========================================\n')
cat('✅ All tests passed!\n')
cat('========================================\n')
