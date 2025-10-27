# FigureYa59volcanoV2 Shiny App

## 概述 | Overview

基于 FigureYa59volcanoV2 的交互式火山图 Web 应用，提供实时参数调整和可视化功能。

Interactive volcano plot web application based on FigureYa59volcanoV2, providing real-time parameter adjustment and visualization.

## 功能特点 | Features

- **交互式参数调整**: 实时调整 Fold Change 和 P-value 阈值
- **多种可视化模式**: Classic 和 Advanced 两种绘图风格
- **自定义基因高亮**: 上传特定基因列表进行突出显示
- **实时数据预览**: 查看原始数据和选中的基因
- **PDF 导出**: 下载高质量 PDF 格式的火山图
- **响应式界面**: 适配不同屏幕尺寸

## 系统要求 | Requirements

- R (≥ 4.0)
- 必需的 R 包:
  - shiny
  - ggplot2
  - ggrepel
  - ggthemes
  - gridExtra
  - DT

## 快速开始 | Quick Start

### 方法 1: 使用启动脚本
```bash
# 在 FigureYa59volcanoV2 目录中
chmod +x run_shiny.R
./run_shiny.R
```

### 方法 2: 直接运行
```r
# 在 R 或 RStudio 中
shiny::runApp(appDir = ".", host = "0.0.0.0", port = 3838)
```

### 方法 3: 作为 R 脚本运行
```bash
Rscript app.R
```

## 数据格式 | Data Format

### 主要数据文件 (Main Data File)
必须包含的列:
- `logFC`: log2 倍变化
- `P.Value`: P 值

可选列:
- `X` 或 `gene`: 基因名称
- `adj.P.Val`: 校正后的 P 值

示例 CSV 格式:
```csv
logFC,AveExpr,t,P.Value,adj.P.Val,B
KLK10,8.78,10.51,111.58,3.80e-11,1.76e-07,15.42
FXYD3,7.75,10.46,107.27,4.81e-11,1.76e-07,15.30
```

### 选中基因文件 (Selected Genes File)
必须包含的列:
- 第一列: 基因名称 (gsym)

可选列:
- `pathway`: 基因所属的通路，用于颜色分类

示例 CSV 格式:
```csv
gsym,pathway
KLK10,Kallikreins
FXYD3,Membrane Transport
```

## 使用说明 | Usage

1. **启动应用**: 运行应用后，在浏览器中打开显示的地址
2. **加载数据**:
   - 勾选 "Use example data" 使用内置示例数据
   - 或上传自己的 CSV 文件
3. **调整参数**:
   - 选择绘图模式 (Classic/Advanced)
   - 调整 Fold Change 和 P-value 阈值
   - 设置基因标注阈值
4. **基因高亮**:
   - 上传包含要突出显示基因的 CSV 文件
5. **查看结果**:
   - 实时查看火山图变化
   - 预览数据表格
5. **导出图片**: 点击 "Download Plot (PDF)" 下载图片

## 参数说明 | Parameters

### 基础参数
- **Log2 Fold Change Cutoff**: 差异表达基因的倍数变化阈值
- **P-value Cutoff**: 统计显著性阈值

### 高级模式参数 (Advanced Mode)
- **Log2 Fold Change Cutoff 2/3**: 二级/三级倍数变化阈值
- **P-value Cutoff 2/3**: 二级/三级显著性阈值

### 显示选项
- **Show gene names for |log2FC| >**: 显示特定倍数变化以上基因的名称

## 故障排除 | Troubleshooting

### 常见问题
1. **应用无法启动**: 检查是否安装了所有必需的 R 包
2. **数据上传失败**: 确保 CSV 文件格式正确，包含必需的列
3. **图表不显示**: 检查数据中的 logFC 和 P.Value 是否为数值型
4. **基因标注不显示**: 确保基因名称格式与数据文件中的格式一致

### 错误信息
- "The main data file must contain columns: logFC, P.Value": 主要数据文件缺少必需列
- "No data available": 没有上传数据或数据格式错误

## 技术细节 | Technical Details

### 绘图模式
- **Classic**: 简单的红蓝灰三色模式
- **Advanced**: 多层次的颜色和大小系统，提供更丰富的视觉信息

### 颜色系统
Advanced 模式使用以下颜色编码:
- 上调基因: 粉红色系 (#FB9A99, #ED4F4F)
- 下调基因: 绿色系 (#B2DF8A, #329E3F)
- 非显著基因: 灰色

### 引用 | Citation
如果使用此工具，请引用:
```
Xiaofan Lu, et al. (2025). FigureYa: A Standardized Visualization Framework
for Enhancing Biomedical Data Interpretation and Research Efficiency.
iMetaMed. https://doi.org/10.1002/imm3.70005
```

## 许可证 | License

本项目遵循 FigureYa 框架的许可证: Creative Commons Attribution-NonCommercial-ShareAlike 4.0

## 贡献 | Contributing

欢迎提交 Issue 和 Pull Request 来改进这个工具。

## 联系方式 | Contact

如有问题，请通过以下方式联系:
- 项目 GitHub 仓库的 Issue 系统
- FigureYa 官方文档和支持