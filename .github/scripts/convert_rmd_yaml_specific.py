import re
import os

# 遍历整个仓库，查找所有 .rmd（大小写不敏感）文件
all_rmd_files = []
for root, dirs, files in os.walk('.'):
    for file in files:
        if file.lower().endswith('.rmd'):
            all_rmd_files.append(os.path.join(root, file))

# 正则：params下的date字段（允许有缩进/引号/空格）
date_line_pattern = re.compile(
    r'^(\s*date\s*:\s*)["\']?\d{4}-\d{2}-\d{2}["\']?\s*$'
)

for file in all_rmd_files:
    with open(file, encoding='utf-8') as f:
        lines = f.readlines()
    new_lines = []
    in_yaml = False
    yaml_count = 0
    for line in lines:
        if line.strip() == "---":
            yaml_count += 1
            if yaml_count <= 2:
                in_yaml = yaml_count == 1
            else:
                in_yaml = False
            new_lines.append(line)
            continue
        if in_yaml and date_line_pattern.match(line):
            # 替换为 R 代码格式
            indent = re.match(r'^(\s*)', line).group(1)
            line = f'{indent}date: "`r Sys.Date()`"\n'
        new_lines.append(line)
    with open(file, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
