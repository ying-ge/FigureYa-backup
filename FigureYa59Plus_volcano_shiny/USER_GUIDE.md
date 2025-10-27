# FigureYa59volcanoV2 Shiny App 使用指南
# User Guide for FigureYa59volcanoV2 Shiny App

## 🚀 快速开始 | Quick Start

### 1. 启动应用 | Start Application

打开终端，在应用目录中运行：

```bash
# 方法 1: 使用启动脚本
./run_shiny.R

# 方法 2: 直接运行
Rscript app.R

# 方法 3: 在 R 中运行
R
# 然后输入:
shiny::runApp(appDir = ".")
```

### 2. 访问应用 | Access Application

应用启动后，在浏览器中打开以下任一地址：
- http://localhost:3838
- http://127.0.0.1:3838

## 📊 界面介绍 | Interface Overview

### 左侧控制面板 | Left Control Panel

#### 📁 数据上传 | Data Upload
- **Use example data**: 勾选使用内置示例数据
- **Main Data File (CSV)**: 上传主要差异表达数据文件
- **Selected Genes File (CSV, optional)**: 上传需要高亮的基因列表

#### ⚙️ 绘图参数 | Plot Parameters
- **Plot Mode**: 选择 Classic（经典）或 Advanced（高级）模式
- **Log2 Fold Change Cutoff**: 设置倍数变化阈值
- **P-value Cutoff**: 设置显著性阈值
- **高级模式参数**: 仅在 Advanced 模式下显示额外的阈值设置

#### 🎨 显示选项 | Display Options
- **Show gene names for |log2FC| >**: 设置显示基因名的最小倍数变化值

#### 💾 下载按钮 | Download Button
- **Download Plot (PDF)**: 下载当前火山图的 PDF 文件

### 右侧主显示区 | Right Main Display Area

#### 📈 火山图标签页 | Volcano Plot Tab
- 显示交互式火山图
- 实时响应参数调整
- 支持缩放和平移

#### 📋 数据预览标签页 | Data Preview Tabs
- **Data Preview**: 查看主要数据文件内容
- **Selected Genes**: 查看上传的基因列表
- **About**: 查看应用说明和引用信息

## 📝 数据文件格式 | Data File Format

### 主要数据文件 | Main Data File
必须包含以下列：
- `logFC`: log2 倍变化
- `P.Value`: P 值
- 基因名：`X` 或 `gene` 列（推荐）

示例格式：
```csv
X,logFC,AveExpr,t,P.Value,adj.P.Val,B
KLK10,8.78,10.51,111.58,3.80e-11,1.76e-07,15.42
FXYD3,7.75,10.46,107.27,4.81e-11,1.76e-07,15.30
KLK7,9.14,10.60,102.66,6.25e-11,1.76e-07,15.16
```

### 基因列表文件 | Selected Genes File
必须包含：
- `gsym`: 基因名称（第一列）
- `pathway`: 基因所属通路（可选，用于颜色分类）

示例格式：
```csv
gsym,pathway
KLK10,pathway1
KLK7,pathway1
KRT16,pathway2
KCTD12,pathway3
```

## 🎯 使用步骤 | Usage Steps

### 方法 1: 使用示例数据 | Using Example Data

1. **启动应用**
   ```bash
   ./run_shiny.R
   ```

2. **打开浏览器**访问 http://localhost:3838

3. **确认参数**：
   - 确保 "Use example data" 已勾选
   - 选择 Plot Mode（建议 Advanced 模式）
   - 调整阈值参数

4. **查看结果**：
   - 火山图自动显示
   - 左侧会显示 pathway 图例
   - 可以看到高亮标记的基因

5. **下载图片**：
   - 点击 "Download Plot (PDF)" 按钮
   - 浏览器自动下载 PDF 文件

### 方法 2: 使用自己的数据 | Using Your Own Data

1. **准备数据文件**：
   - 按照上述格式准备 CSV 文件
   - 确保包含必需的列

2. **启动应用**：
   ```bash
   ./run_shiny.R
   ```

3. **取消勾选** "Use example data"

4. **上传文件**：
   - 点击 "Main Data File" 上传主要数据
   - 点击 "Selected Genes File" 上传基因列表（可选）

5. **调整参数**：
   - 根据数据特点调整阈值
   - 选择合适的绘图模式

6. **查看和下载**：同方法 1

## ⚙️ 参数说明 | Parameter Description

### 基础参数 | Basic Parameters

- **Log2 Fold Change Cutoff**:
  - 含义：差异表达基因的最小倍数变化
  - 推荐：1.5-2.0
  - 效果：控制左右两条垂直线位置

- **P-value Cutoff**:
  - 含义：统计显著性阈值
  - 推荐：0.05 或 0.01
  - 效果：控制水平线位置

### 高级模式参数 | Advanced Mode Parameters

- **Log2 Fold Change Cutoff 2/3**: 二级/三级倍数变化阈值
- **P-value Cutoff 2/3**: 二级/三级显著性阈值
- **用途**: 创建多层次的视觉效果

### 显示参数 | Display Parameters

- **Show gene names for |log2FC| >**:
  - 含义：显示基因名的最小倍数变化要求
  - 用途：控制基因标注的密度

## 🎨 可视化模式 | Visualization Modes

### Classic Mode | 经典模式
- **颜色方案**: 红色（上调）、蓝色（下调）、灰色（不显著）
- **适用场景**: 简单直观的差异表达分析
- **优点**: 清晰易读，适合报告和演示

### Advanced Mode | 高级模式
- **颜色方案**: 多层次的粉红/绿色系
- **尺寸变化**: 不同显著级别的点大小不同
- **适用场景**: 详细的多层次分析
- **优点**: 信息丰富，适合深入分析

## 🔧 常见问题 | Troubleshooting

### 应用无法启动
- **检查 R 版本**: 需要 R 4.0+
- **安装依赖**: R 会自动安装缺失的包
- **端口占用**: 如果 3838 端口被占用，修改 `run_shiny.R` 中的端口号

### 文件上传失败
- **检查格式**: 确保是 CSV 格式
- **检查列名**: 确保包含必需的列名（logFC, P.Value）
- **检查数据**: 确保数值列没有非数字字符

### 图表不显示
- **检查数据**: 确保数据加载成功
- **检查参数**: 确保参数设置合理
- **查看错误**: 检查控制台错误信息

### 下载失败
- **等待渲染**: 确保图表完全显示后再点击下载
- **检查权限**: 确保浏览器允许下载文件
- **重试**: 有时需要点击多次

## 💡 使用技巧 | Tips

### 参数调优
1. **从默认值开始**：先使用默认参数查看整体效果
2. **逐步调整**：一次只调整一个参数，观察变化
3. **交叉验证**：结合生物学意义和统计显著性

### 数据可视化
1. **对比分析**：尝试不同阈值组合，寻找最佳可视化效果
2. **突出重点**：使用基因高亮功能强调关键基因
3. **导出多版本**：为不同用途调整参数并分别下载

### 工作流程建议
1. **数据准备** → 2. **参数设置** → 3. **效果评估** → 4. **优化调整** → 5. **结果导出**

## 📞 获取帮助 | Getting Help

- **查看 About 标签页**: 获取应用详细信息
- **检查控制台输出**: 查看启动和运行时的信息
- **查阅文档**: 参考 `README.md` 和 `DOWNLOAD_FIX.md`

---

更新日期：2025-10-25
Updated: 2025-10-25