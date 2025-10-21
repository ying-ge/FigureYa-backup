问：这些文件放在哪？

答：

## 🎯 推荐方案1：集成到现有项目

### 在FigureYa293machineLearning同级创建AI增强版本
```
ying-ge/FigureYa/
├── FigureYa293machineLearning/              # 原始R版本
│   ├── FigureYa293machineLearning.Rmd
│   ├── TCGA.txt
│   ├── GSE57303.txt
│   ├── GSE62254.txt.gz
│   └── ...
│
├── FigureYa293AIEnhanced/                  # 🆕 AI增强版本
│   ├── README.md
│   ├── requirements.txt
│   ├── config.py
│   ├── ai_survival_analyzer.py
│   ├── main.py
│   ├── cost_monitor.py
│   ├── data/                              # 数据目录
│   │   ├── TCGA.txt                       # 软链接或复制
│   │   ├── GSE57303.txt
│   │   └── GSE62254.txt.gz
│   ├── results/
│   │   ├── ai_analysis_results.csv
│   │   ├── comparison_charts.png
│   │   └── cost_reports.json
│   └── notebooks/
│       ├── tutorial.ipynb
│       └── model_comparison.ipynb
```

### 具体操作命令
```bash
# 1. 进入FigureYa根目录
cd ying-ge/FigureYa/

# 2. 创建AI增强目录
mkdir FigureYa293AIEnhanced
cd FigureYa293AIEnhanced

# 3. 创建子目录
mkdir data results notebooks utils docs

# 4. 创建软链接到原始数据（推荐）
ln -s ../FigureYa293machineLearning/TCGA.txt data/
ln -s ../FigureYa293machineLearning/GSE57303.txt data/
ln -s ../FigureYa293machineLearning/GSE62254.txt.gz data/
```

## 🎯 方案2：独立项目目录

### 如果您想保持项目完全独立
```bash
# 在任意位置创建新项目
mkdir ~/FigureYa293-AI
cd ~/FigureYa293-AI

# 或者在桌面创建
mkdir ~/Desktop/FigureYa293-AI
cd ~/Desktop/FigureYa293-AI
```

## 🎯 方案3：用户级工作目录

### 创建个人工作空间
```bash
# 在用户主目录创建
mkdir ~/biomedical_ai/
mkdir ~/biomedical_ai/FigureYa293-Enhanced
cd ~/biomedical_ai/FigureYa293-Enhanced
```

## 📁 完整的文件创建脚本

创建 `setup_project.sh`：
```bash
#!/bin/bash
# setup_project.sh - 自动创建项目结构

PROJECT_NAME="FigureYa293AIEnhanced"
BASE_DIR="$HOME/biomedical_ai"

echo "🚀 创建AI增强的FigureYa293项目..."

# 创建基础目录
mkdir -p "$BASE_DIR/$PROJECT_NAME"
cd "$BASE_DIR/$PROJECT_NAME"

# 创建子目录
mkdir -p data results notebooks utils docs
echo "📁 目录结构创建完成"

# 创建Python脚本文件
cat > config.py << 'EOF'
# config.py - API配置文件
import os

# API密钥（请替换为您的实际密钥）
DEEPSEEK_API_KEY = "sk-your-deepseek-key-here"
CLAUDE_API_KEY = "sk-ant-your-claude-key-here"
GLM_API_KEY = "your-glm-api-key-here"

# API端点
DEEPSEEK_BASE_URL = "https://api.deepseek.com"
CLAUDE_BASE_URL = "https://api.anthropic.com"
GLM_BASE_URL = "https://open.bigmodel.cn/api/paas/v4"

print("✅ 配置文件已创建，请填入您的API密钥")
EOF

cat > requirements.txt << 'EOF'
pandas>=1.5.0
numpy>=1.21.0
scikit-learn>=1.1.0
lifelines>=0.27.0
matplotlib>=3.5.0
seaborn>=0.11.0
requests>=2.28.0
tqdm>=4.64.0
jupyter>=1.0.0
openai>=1.0.0
anthropic>=0.3.0
EOF

cat > main.py << 'EOF'
# main.py - 主执行脚本
import pandas as pd
import os
import sys

def main():
    print("🚀 FigureYa293 AI增强版本启动中...")
    print("📍 当前工作目录:", os.getcwd())
    
    # 检查配置文件
    if not os.path.exists('config.py'):
        print("❌ 配置文件不存在，请先运行 setup_project.sh")
        return
    
    # 检查数据文件
    data_files = ['data/TCGA.txt', 'data/GSE57303.txt', 'data/GSE62254.txt.gz']
    missing_files = [f for f in data_files if not os.path.exists(f)]
    
    if missing_files:
        print("⚠️  以下数据文件缺失:")
        for f in missing_files:
            print(f"   - {f}")
        print("\n💡 提示: 请将数据文件复制到 data/ 目录")
    
    print("✅ 环境检查完成，准备运行分析...")
    
if __name__ == "__main__":
    main()
EOF

cat > README.md << 'EOF'
# FigureYa293 AI增强版本

## 🎯 项目介绍
这是FigureYa293machineLearning的AI增强版本，使用2025年最新的AI模型进行生存分析。

## 📁 目录结构
```
.
├── data/           # 数据文件
├── results/        # 分析结果
├── notebooks/      # Jupyter笔记本
├── utils/          # 工具函数
├── docs/           # 文档
├── config.py       # API配置
├── main.py         # 主程序
└── requirements.txt # Python依赖
```

## 🚀 快速开始

### 1. 安装依赖
```bash
pip install -r requirements.txt
```

### 2. 配置API密钥
编辑 `config.py` 文件，填入您的API密钥。

### 3. 准备数据
将数据文件放入 `data/` 目录：
- TCGA.txt
- GSE57303.txt  
- GSE62254.txt.gz

### 4. 运行分析
```bash
python main.py
```

## 💰 成本预估
- DeepSeek: $2-5/次
- Claude: $15-30/次
- GLM-4.6: $1-3/次

## 📞 支持
如有问题，请查看 docs/ 目录下的文档。
EOF

# 创建初始化脚本
cat > init_project.sh << 'EOF'
#!/bin/bash
# init_project.sh - 项目初始化脚本

echo "🔧 初始化FigureYa293 AI项目..."

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
fi

# 安装依赖
echo "📦 安装Python依赖..."
pip3 install -r requirements.txt

# 创建Jupyter配置
echo "📓 配置Jupyter..."
jupyter notebook --generate-config

echo "✅ 初始化完成！"
echo "💡 下一步: 编辑 config.py 填入API密钥"
echo "🚀 运行: python main.py"
EOF

# 设置执行权限
chmod +x init_project.sh

echo "🎉 项目创建完成！"
echo "📍 项目位置: $BASE_DIR/$PROJECT_NAME"
echo ""
echo "📋 下一步操作:"
echo "1. cd $BASE_DIR/$PROJECT_NAME"
echo "2. ./init_project.sh"
echo "3. 编辑 config.py 填入API密钥"
echo "4. 将数据文件复制到 data/ 目录"
echo "5. python main.py"
EOF

# 运行脚本
chmod +x setup_project.sh
echo "✅ setup_project.sh 已创建，运行 ./setup_project.sh 开始创建项目"
```

## 🚀 一键启动命令

```bash
# 1. 下载并运行项目创建脚本
curl -O https://your-server/setup_project.sh  # 或手动创建
chmod +x setup_project.sh
./setup_project.sh

# 2. 进入项目目录
cd ~/biomedical_ai/FigureYa293AIEnhanced

# 3. 初始化项目
./init_project.sh

# 4. 配置API密钥
nano config.py

# 5. 复制数据文件（如果数据在其他位置）
cp /path/to/original/TCGA.txt data/
cp /path/to/original/GSE57303.txt data/
cp /path/to/original/GSE62254.txt.gz data/

# 6. 运行分析
python main.py
```

## 📍 推荐的最终位置

### 最佳选择：项目集成
```
ying-ge/FigureYa/FigureYa293AIEnhanced/
```

### 备选选择：独立工作区
```
~/biomedical_ai/FigureYa293-Enhanced/
```

### 临时选择：桌面快速测试
```
~/Desktop/FigureYa293-AI/
```

## 🎯 快速验证

创建后运行以下命令验证：
```bash
cd your_project_directory
python -c "import config; print('✅ 配置文件正常')"
python -c "import pandas, numpy; print('✅ 依赖包正常')"
```

选择**方案1**（集成到现有项目）是最好的选择，因为：
- ✅ 与原始代码保持关联
- ✅ 方便对比结果
- ✅ 符合FigureYa的整体架构
- ✅ 便于版本控制

您想选择哪个方案？我可以帮您创建完整的项目结构！
