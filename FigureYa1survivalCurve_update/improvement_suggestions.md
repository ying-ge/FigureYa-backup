# FigureYa1SurvivalCurve 医学统计学改进建议

## 1. 数据预处理改进

### 1.1 数据质量检查
```r
# 添加数据质量检查
check_data_quality <- function(data, time_col, status_col, group_col) {
  cat("=== 数据质量检查 ===\n")
  cat("总样本数:", nrow(data), "\n")
  cat("各组样本数:\n")
  print(table(data[[group_col]]))
  cat("事件数:\n")
  print(table(data[[status_col]]))
  cat("缺失值统计:\n")
  print(sapply(data[, c(time_col, status_col, group_col)], function(x) sum(is.na(x))))
  
  # 检查时间变量的合理性
  cat("随访时间统计:\n")
  print(summary(data[[time_col]]))
  
  # 检查删失比例
  censor_rate <- mean(data[[status_col]] == 0, na.rm = TRUE)
  cat("删失比例:", round(censor_rate * 100, 2), "%\n")
  
  return(list(total_n = nrow(data), 
              group_sizes = table(data[[group_col]]),
              event_rate = 1 - censor_rate))
}
```

### 1.2 规范分组逻辑
```r
# 建议使用定量阈值进行分组
create_expression_groups <- function(expression_data, method = "median") {
  if (method == "median") {
    threshold <- median(expression_data, na.rm = TRUE)
  } else if (method == "optimal") {
    # 使用maxstat包找最佳分割点
    library(maxstat)
    threshold <- maxstat.test(expression_data, surv_obj)$estimate
  }
  
  groups <- ifelse(expression_data > threshold, "high", "low")
  return(list(groups = factor(groups, levels = c("low", "high")), 
              threshold = threshold))
}
```

## 2. 生存分析假设检验

### 2.1 等比例风险假设检验
```r
check_ph_assumption <- function(fit, data, time_col, status_col, group_col) {
  library(survival)
  
  # Schoenfeld残差检验
  cox_fit <- coxph(Surv(data[[time_col]], data[[status_col]]) ~ data[[group_col]], data = data)
  ph_test <- cox.zph(cox_fit)
  
  cat("=== 等比例风险假设检验 ===\n")
  print(ph_test)
  
  if (ph_test$table[,"p"] < 0.05) {
    cat("警告：等比例风险假设被违反！\n")
    cat("建议：考虑时变系数模型或分层分析\n")
  }
  
  return(ph_test)
}
```

### 2.2 删失机制检查
```r
check_censoring <- function(data, time_col, status_col, group_col) {
  # 检查删失是否与分组相关
  censor_by_group <- table(data[[group_col]], data[[status_col]])
  cat("=== 删失模式检查 ===\n")
  print(censor_by_group)
  
  # 卡方检验
  censor_test <- chisq.test(censor_by_group)
  cat("删失与分组的关联性检验 p-value:", censor_test$p.value, "\n")
  
  if (censor_test$p.value < 0.05) {
    cat("警告：删失可能与分组相关，存在信息性删失风险\n")
  }
}
```

## 3. 统计检验改进

### 3.1 多重比较校正
```r
pairwise_survival_test <- function(data, time_col, status_col, group_col) {
  library(survminer)
  
  # 两两比较并校正
  pairwise_test <- pairwise_survdiff(
    Surv(data[[time_col]], data[[status_col]]) ~ data[[group_col]],
    data = data,
    p.adjust.method = "bonferroni"
  )
  
  cat("=== 两两比较结果（Bonferroni校正） ===\n")
  print(pairwise_test)
  
  return(pairwise_test)
}
```

### 3.2 效应量计算
```r
calculate_hazard_ratios <- function(data, time_col, status_col, group_col) {
  library(survival)
  
  # 计算风险比
  cox_fit <- coxph(Surv(data[[time_col]], data[[status_col]]) ~ data[[group_col]], data = data)
  
  cat("=== Cox回归结果 ===\n")
  summary_result <- summary(cox_fit)
  print(summary_result)
  
  # 提取HR和95%CI
  hr <- exp(coef(cox_fit))
  hr_ci <- exp(confint(cox_fit))
  
  cat("风险比 (HR):", round(hr, 3), "\n")
  cat("95%置信区间:", round(hr_ci[1], 3), "-", round(hr_ci[2], 3), "\n")
  
  return(list(hr = hr, ci = hr_ci, p_value = summary_result$coefficients[,"Pr(>|z|)"]))
}
```

## 4. 统计功效和样本量

### 4.1 功效分析
```r
power_analysis <- function(data, time_col, status_col, group_col, alpha = 0.05, power = 0.8) {
  library(powerSurvEpi)
  
  # 计算事件数
  n_events <- sum(data[[status_col]] == 1)
  n_total <- nrow(data)
  event_rate <- n_events / n_total
  
  # 各组样本量
  group_sizes <- table(data[[group_col]])
  prop1 <- group_sizes[1] / n_total
  prop2 <- group_sizes[2] / n_total
  
  cat("=== 功效分析 ===\n")
  cat("总样本数:", n_total, "\n")
  cat("事件数:", n_events, "\n")
  cat("事件率:", round(event_rate * 100, 2), "%\n")
  cat("各组样本比例:", round(prop1, 3), "vs", round(prop2, 3), "\n")
  
  # 估算可检测的最小HR
  if (length(group_sizes) == 2) {
    min_hr <- powerCT.default(n = n_total, p = prop1, psi = event_rate, 
                              alpha = alpha, power = power)$hr
    cat("当前样本量可检测的最小HR:", round(min_hr, 3), "\n")
  }
}
```

## 5. 改进的可视化

### 5.1 规范的生存曲线
```r
create_enhanced_survival_plot <- function(fit, data, time_col, status_col, group_col) {
  library(survminer)
  
  # 计算中位生存时间
  median_surv <- surv_median(fit)
  
  # 创建增强版生存曲线
  p <- ggsurvplot(
    fit,
    data = data,
    pval = TRUE,
    conf.int = TRUE,
    conf.int.style = "step",
    conf.int.alpha = 0.2,
    risk.table = TRUE,
    risk.table.col = "strata",
    risk.table.height = 0.25,
    tables.theme = theme_cleantable(),
    
    # 添加中位生存时间标注
    surv.median.line = "hv",
    
    # 改进图例和标签
    legend.title = "",
    legend.labs = levels(data[[group_col]]),
    legend.position = "right",
    
    # 添加样本量信息
    censor.size = 3,
    
    # 改进坐标轴
    xlab = "随访时间（月）",
    ylab = "生存概率",
    
    # 添加风险数表格标题
    risk.table.title = "风险数",
    
    # 添加事件数信息
    palette = "jco"
  )
  
  # 添加统计信息
  hr_result <- calculate_hazard_ratios(data, time_col, status_col, group_col)
  
  return(p)
}
```

## 6. 敏感性分析

### 6.1 亚组分析
```r
subgroup_analysis <- function(data, time_col, status_col, group_col, subgroup_vars) {
  results <- list()
  
  for (var in subgroup_vars) {
    if (var %in% colnames(data)) {
      cat("=== 亚组分析:", var, "===\n")
      
      for (level in unique(data[[var]][!is.na(data[[var]])])) {
        subgroup_data <- data[data[[var]] == level & !is.na(data[[var]]), ]
        
        if (nrow(subgroup_data) > 10) {  # 最小样本量要求
          cat("亚组:", level, "(n=", nrow(subgroup_data), ")\n")
          
          fit_sub <- survfit(Surv(subgroup_data[[time_col]], subgroup_data[[status_col]]) ~ 
                           subgroup_data[[group_col]], data = subgroup_data)
          
          logrank_test <- survdiff(Surv(subgroup_data[[time_col]], subgroup_data[[status_col]]) ~ 
                                 subgroup_data[[group_col]], data = subgroup_data)
          
          cat("Log-rank p-value:", 1 - pchisq(logrank_test$chisq, df = length(logrank_test$n) - 1), "\n")
        }
      }
    }
  }
}
```

## 7. 完整的分析流程建议

```r
complete_survival_analysis <- function(data, time_col, status_col, group_col) {
  # 1. 数据质量检查
  quality_check <- check_data_quality(data, time_col, status_col, group_col)
  
  # 2. 删失机制检查
  check_censoring(data, time_col, status_col, group_col)
  
  # 3. 生存拟合
  fit <- survfit(Surv(data[[time_col]], data[[status_col]]) ~ data[[group_col]], data = data)
  
  # 4. 等比例风险假设检验
  ph_test <- check_ph_assumption(fit, data, time_col, status_col, group_col)
  
  # 5. 统计检验
  if (length(unique(data[[group_col]])) > 2) {
    pairwise_test <- pairwise_survival_test(data, time_col, status_col, group_col)
  }
  
  # 6. 效应量计算
  hr_results <- calculate_hazard_ratios(data, time_col, status_col, group_col)
  
  # 7. 功效分析
  power_analysis(data, time_col, status_col, group_col)
  
  # 8. 可视化
  plot <- create_enhanced_survival_plot(fit, data, time_col, status_col, group_col)
  
  return(list(fit = fit, quality = quality_check, ph_test = ph_test, 
              hr = hr_results, plot = plot))
}
```

## 8. 报告规范建议

1. **方法部分应包括**：
   - 数据预处理详细步骤
   - 生存分析方法的选择理由
   - 假设检验结果
   - 缺失值处理策略

2. **结果部分应报告**：
   - 各组样本量和事件数
   - 中位生存时间及其95%CI
   - 风险比及其95%CI
   - Log-rank检验p值
   - 等比例风险假设检验结果

3. **图表要求**：
   - 清晰标注删失数据
   - 提供风险数表格
   - 报告统计检验结果
   - 注明样本量信息

这些改进将显著提高生存分析的严谨性和科学性。
