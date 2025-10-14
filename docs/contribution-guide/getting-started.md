# Getting Started Guide

## 🎯 Objectives
Through this guide, you will learn to:
- Fork and Clone the FigureYa repository
- Create your first Pull Request
- Understand project structure and contribution workflow

## 📚 Prerequisites
- Basic Git operations
- R or Python basics (depending on your contribution)
- GitHub account

## 🚀 Hands-on Practice: Fix a Simple Issue

### Step 1: Choose a Simple Task
We recommend starting with these simple tasks:
1. Fix hardcoded colors in FigureYa196PanPie
2. Add error handling to FigureYa261circGene
3. Improve comments in any module

### Step 2: Fork the Repository
1. Visit [FigureYa Repository](https://github.com/ying-ge/FigureYa)
2. Click the "Fork" button in the top right
3. Wait for the fork to complete

### Step 3: Clone Locally
```bash
# Replace YOUR_USERNAME with your GitHub username
git clone https://github.com/YOUR_USERNAME/FigureYa.git
cd FigureYa
```

### Step 4: Create Branch
```bash
# Create and switch to new branch
git checkout -b fix/improve-figureya196-colors

# Check current branch
git branch
```

### Step 5: Make Changes
Example: Fixing FigureYa196PanPie:

1. Open `FigureYa196PanPie/FigureYa196PanPie.Rmd`
2. Find hardcoded color definitions (lines 110-122):
```r
# Original hardcoded version
black  <- "#1E1E1B"
blue   <- "#3C4E98"
yellow <- "#E4DB36"
```

3. Improve to configurable approach:
```r
# Improved version: configurable color scheme
default_colors <- list(
  black  = "#1E1E1B",
  blue   = "#3C4E98", 
  yellow = "#E4DB36",
  orange = "#E19143",
  green  = "#57A12B",
  cherry = "#8D3A86"
)

# Allow user customization
custom_colors <- list() # Users can override defaults here
colors <- modifyList(default_colors, custom_colors)
```

### Step 6: Test Changes
```bash
# Test your changes in R
cd FigureYa196PanPie
R
# Run knit("FigureYa196PanPie.Rmd") for testing
```

### Step 7: Commit Changes
```bash
git add .
git commit -m "feat: make colors configurable in FigureYa196PanPie

- Replace hardcoded colors with configurable color scheme
- Allow users to customize colors via custom_colors list
- Maintain backward compatibility with default colors"
```

### Step 8: Push Branch
```bash
git push origin fix/improve-figureya196-colors
```

### Step 9: Create Pull Request
1. Visit your forked repository page
2. Click "Compare & pull request" button
3. Fill out the PR template:

```markdown
## 📝 Change Description
Improve color configuration system for FigureYa196PanPie module

## 🔧 Specific Changes
- Replace hardcoded colors with configurable color scheme
- Add custom_colors list for user customization
- Maintain backward compatibility

## ✅ Testing
- [x] Code runs successfully
- [x] Generated charts are correct
- [x] Backward compatibility maintained

## 📷 Visual Results
(Add screenshots if applicable)
```

4. Click "Create pull request"

## 🎉 Congratulations!
You've successfully submitted your first Pull Request!

## 📖 Next Steps
- Check [Challenge List](challenge-list.md) for more tasks
- Learn [Python Conversion Guide](python-conversion.md)
- Read [Visualization Best Practices](best-practices.md)

## ❓ FAQ

### Q: What if my changes are rejected?
A: Don't be discouraged! Review maintainer feedback, make suggested changes, and resubmit.

### Q: I'm not sure if my idea is valuable?
A: Create an Issue first to discuss your idea and get feedback before coding.

### Q: My English isn't great, can I contribute in Chinese only?
A: Yes! We welcome Chinese contributions, but try to add English translations for key parts.

---

# 新手入门指南 | Getting Started Guide

## 🎯 目标
通过这个指南，你将学会：
- Fork 和 Clone FigureYa 仓库
- 创建你的第一个 Pull Request
- 理解项目结构和贡献流程

## 📚 前置知识
- 基本的 Git 操作
- R 或 Python 基础（根据你要贡献的内容）
- GitHub 账户

## 🚀 实战演练：修复一个简单问题

### 第一步：选择一个简单任务
我们推荐从这些简单任务开始：
1. 修复 FigureYa196PanPie 中的硬编码颜色
2. 为 FigureYa261circGene 添加错误处理
3. 改进某个模块的注释

### 第二步：Fork 仓库
1. 访问 [FigureYa 仓库](https://github.com/ying-ge/FigureYa)
2. 点击右上角的 "Fork" 按钮
3. 等待 Fork 完成

### 第三步：Clone 到本地
```bash
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git clone https://github.com/YOUR_USERNAME/FigureYa.git
cd FigureYa
```

### 第四步：创建分支
```bash
# 创建并切换到新分支
git checkout -b fix/improve-figureya196-colors

# 查看当前分支
git branch
```

### 第五步：进行修改
以修复 FigureYa196PanPie 为例：

1. 打开 `FigureYa196PanPie/FigureYa196PanPie.Rmd`
2. 找到硬编码的颜色定义（第110-122行）：
```r
# 原来的硬编码
black  <- "#1E1E1B"
blue   <- "#3C4E98"
yellow <- "#E4DB36"
```

3. 改为可配置的方式：
```r
# 改进版：可配置的颜色方案
default_colors <- list(
  black  = "#1E1E1B",
  blue   = "#3C4E98", 
  yellow = "#E4DB36",
  orange = "#E19143",
  green  = "#57A12B",
  cherry = "#8D3A86"
)

# 允许用户自定义颜色
custom_colors <- list() # 用户可以在这里覆盖默认颜色
colors <- modifyList(default_colors, custom_colors)
```

### 第六步：测试修改
```bash
# 在 R 中测试你的修改
cd FigureYa196PanPie
R
# 运行 knit("FigureYa196PanPie.Rmd") 测试
```

### 第七步：提交修改
```bash
git add .
git commit -m "feat: make colors configurable in FigureYa196PanPie

- Replace hardcoded colors with configurable color scheme
- Allow users to customize colors via custom_colors list
- Maintain backward compatibility with default colors"
```

### 第八步：推送分支
```bash
git push origin fix/improve-figureya196-colors
```

### 第九步：创建 Pull Request
1. 访问你的 Fork 仓库页面
2. 点击 "Compare & pull request" 按钮
3. 填写 PR 模板：

```markdown
## 📝 修改描述
改进 FigureYa196PanPie 模块的颜色配置系统

## 🔧 具体改动
- 将硬编码颜色改为可配置的颜色方案
- 添加 custom_colors 列表允许用户自定义
- 保持向后兼容性

## ✅ 测试
- [x] 代码可以正常运行
- [x] 生成的图表正确
- [x] 向后兼容性良好

## 📷 效果展示
（如果有的话，添加截图）
```

4. 点击 "Create pull request"

## 🎉 恭喜！
你已经成功提交了第一个 Pull Request！

## 📖 下一步
- 查看 [贡献挑战列表](challenge-list.md) 寻找更多任务
- 学习 [Python转换指南](python-conversion.md)
- 阅读 [可视化最佳实践](best-practices.md)

## ❓ 常见问题

### Q: 我的修改被拒绝了怎么办？
A: 不要灰心！查看维护者的反馈，根据建议修改后重新提交。

### Q: 我不确定我的想法是否有价值？
A: 先创建一个 Issue 讨论你的想法，获得反馈后再开始编码。

### Q: 我的英文不好，可以只用中文吗？
A: 可以！我们欢迎中文贡献，但最好在重要部分添加英文翻译。
