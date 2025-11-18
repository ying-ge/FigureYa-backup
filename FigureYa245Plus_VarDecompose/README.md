# FigureYa245Plus 基因方差分解查询工具 | Gene Variance Decomposition Explorer

## 简介 | Introduction

这是一个交互式网页工具，用于分析和可视化基因在人类和小鼠之间的表达保守性，并为实验模型选择提供指导建议。

This is an interactive web tool for analyzing and visualizing gene expression conservation between humans and mice, providing guidance for experimental model selection.

## 文件列表 | File List

- `index.html` - 主网页应用 | Main web application
- `lmm_var_dcp_with_groups.csv` - 基因方差分解数据（14,803个基因对）| Gene variance decomposition data (14,803 gene pairs)
- `README.md` - 本说明文件 | This readme file

## 快速开始 | Quick Start

### 方法1：直接打开（推荐）| Method 1: Direct Open (Recommended)

```bash
# 双击 index.html 文件，或在终端运行：
# Double-click index.html file, or run in terminal:
open index.html
```

**操作步骤 | Steps:**
1. 打开网页后，点击上传区域 | After opening the page, click the upload area
2. 选择 `lmm_var_dcp_with_groups.csv` 文件 | Select `lmm_var_dcp_with_groups.csv` file
3. 等待数据加载完成（几秒钟）| Wait for data loading (a few seconds)
4. 在搜索框输入基因名（如 `Fox`）| Enter gene name in search box (e.g. `Fox`)
5. 查看结果和模型推荐 | View results and model recommendations

### 方法2：使用本地服务器 | Method 2: Using Local Server

```bash
# 在此目录启动服务器：
# Start server in this directory:
cd FigureYa245Plus_VarDecompose
python3 -m http.server 8000

# 然后在浏览器访问：
# Then open in browser:
# http://localhost:8000
```

## 功能特点 | Features

### 基因搜索 | Gene Search
- 支持模糊匹配 | Supports fuzzy matching
- 可搜索人类基因名、小鼠基因名或基因对 | Search by human gene, mouse gene, or gene pairs
- 实时高亮显示 | Real-time highlighting

### 数据可视化 | Data Visualization
- 交互式散点图 | Interactive scatter plot
- 三色区域分类 | Three-color region classification
  - 绿色：组织间差异大 | Green: High across tissues
  - 红色：物种间差异大 | Red: High across species
  - 蓝色：差异不显著 | Blue: Not significant
- 支持缩放、平移 | Supports zoom and pan

### 模型推荐 | Model Recommendations

#### 绿色区域基因 | Green Region Genes
**小鼠模型可靠，推荐使用 | Mouse model is reliable, recommended**
- 基因在组织间差异大，但人鼠间保守 | High tissue variance but conserved between species
- 小鼠研究结果可转化到人类 | Mouse results translate well to humans

#### 红色区域基因 | Red Region Genes
**考虑类器官或人源化模型 | Consider organoids or humanized models**
- 基因在人鼠间表达差异显著 | Significant species variance
- 推荐人源类器官、人源化小鼠或临床样本 | Recommend human organoids, humanized mice, or clinical samples

#### 蓝色区域基因 | Blue Region Genes
**两种模型都可以，看研究需求 | Either model works, depends on needs**
- 组织间和物种间差异都不显著 | Neither tissue nor species variance is dominant
- 根据实验条件选择 | Choose based on experimental conditions

## 数据说明 | Data Description

### 数据来源 | Data Source
- 人类和小鼠10个组织的RNA-seq数据 | RNA-seq data from 10 tissues in humans and mice
- 线性混合模型（LMM）方差分解 | Linear mixed model (LMM) variance decomposition
- 14,803个直系同源基因对 | 14,803 orthologous gene pairs

### 方差组成 | Variance Components
每个基因的表达方差分解为三个部分：
- **组织效应** | Tissue effect: 不同组织间的差异 | Variance across tissues
- **物种效应** | Species effect: 人鼠间的差异 | Variance between species
- **残差** | Residual: 其他未解释的方差 | Unexplained variance

### 统计信息 | Statistics
- 总基因对数 | Total gene pairs: 14,803
- 组织间差异大 | High across tissues: 3,701 (25%)
- 物种间差异大 | High across species: 3,701 (25%)
- 差异不显著 | Not significant: 7,401 (50%)

## 使用示例 | Usage Examples

### 示例1：搜索单个基因 | Example 1: Search Single Gene
```
输入 | Input: EMC10_Emc10
结果 | Result: 显示 EMC10_Emc10 的位置和模型推荐
         Shows EMC10_Emc10 location and model recommendation
```

### 示例2：搜索另一个基因 | Example 2: Search Another Gene
```
输入 | Input: LRRIQ3_Lrriq3
结果 | Result: 显示 LRRIQ3_Lrriq3 的保守性分析
         Shows LRRIQ3_Lrriq3 conservation analysis
```

### 示例3：搜索基因家族 | Example 3: Search Gene Family
```
输入 | Input: EMC
结果 | Result: 显示所有EMC家族基因（EMC1, EMC10等）
         Shows all EMC family genes (EMC1, EMC10, etc.)
```

## 技术栈 | Technology Stack

- **Plotly.js** - 交互式图表库 | Interactive plotting library
- **Papa Parse** - CSV解析库 | CSV parsing library
- **Google Material Design** - 界面设计规范 | UI design guidelines
- **纯HTML/CSS/JavaScript** - 无需服务器端 | No server-side required

## 浏览器兼容性 | Browser Compatibility

推荐使用 | Recommended:
- Chrome/Edge ✅
- Firefox ✅
- Safari ✅

不支持 | Not supported:
- Internet Explorer ❌

## 学术引用 | Citation

如果使用此工具，请引用：| If you use this tool, please cite:

**FigureYa框架 | FigureYa Framework:**
```
Xiaofan Lu, et al. (2025). FigureYa: A Standardized Visualization Framework 
for Enhancing Biomedical Data Interpretation and Research Efficiency. 
iMetaMed. https://doi.org/10.1002/imm3.70005
```

**方差分解方法 | Variance Decomposition Method:**
```
Lin, S. et al. (2014). Comparison of the transcriptional landscapes 
between human and mouse tissues. PNAS. 
https://doi.org/10.1073/pnas.1413624111
```

## 常见问题 | FAQ

### Q1: 数据加载失败怎么办？| Data loading failed?
A: 确保 `lmm_var_dcp_with_groups.csv` 文件与 `index.html` 在同一目录下。
Ensure `lmm_var_dcp_with_groups.csv` is in the same directory as `index.html`.

### Q2: 搜索没有结果？| No search results?
A: 检查基因名拼写，或尝试只输入部分名称（模糊匹配）。
Check gene name spelling, or try partial name (fuzzy matching).

### Q3: 可以离线使用吗？| Can I use offline?
A: 可以！除了CDN库（首次需要网络），其他完全离线。
Yes! Except CDN libraries (require network first time), everything works offline.

### Q4: 如何导出图表？| How to export plots?
A: 点击图表右上角的相机图标，可下载PNG格式图片。
Click the camera icon at top-right of the plot to download PNG image.

## 版本信息 | Version Info

- **版本 | Version**: 1.0
- **发布日期 | Release Date**: 2025-10-31
- **作者 | Author**: 基于 FigureYa245VarDecompose 改编 | Adapted from FigureYa245VarDecompose

## 许可证 | License

本工具遵循 FigureYa 框架的许可证：Creative Commons Attribution-NonCommercial-ShareAlike 4.0

This tool follows the FigureYa framework license: Creative Commons Attribution-NonCommercial-ShareAlike 4.0

---

**联系方式 | Contact**

如有问题或建议，请访问 FigureYa 官方文档或GitHub仓库。

For questions or suggestions, please visit FigureYa official documentation or GitHub repository.

