import os
import re

def extract_number(s):
    """提取字符串中第一个连续数字作为排序key，没有数字则返回极大值。"""
    m = re.search(r'(\d+)', s)
    return int(m.group(1)) if m else 999999

def get_html_files(base_path, branch_label):
    toc = []
    # 目录按数字排序
    folders = [f for f in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, f)) and not f.startswith('.')]
    folders_sorted = sorted(folders, key=extract_number)
    for folder in folders_sorted:
        folder_path = os.path.join(base_path, folder)
        # 文件也按数字排序
        html_files = [f for f in os.listdir(folder_path) if f.endswith('.html')]
        html_files_sorted = sorted(html_files, key=extract_number)
        if html_files_sorted:
            toc.append(f"<li><b>{branch_label}/{folder}</b><ul>")
            for fname in html_files_sorted:
                rel_path = os.path.relpath(os.path.join(folder_path, fname), ".")
                toc.append(f'<li><a href="{rel_path}">{fname}</a></li>')
            toc.append("</ul></li>")
    return toc

toc_entries = []
toc_entries.extend(get_html_files(".", "main"))
toc_entries.extend(get_html_files("master_dir", "master"))

html_output = f"""
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>目录 contents</title>
  <style>
    body {{ font-family: Arial, sans-serif; }}
    ul {{ list-style-type: none; }}
    li > ul {{ margin-left: 2em; }}
  </style>
</head>
<body>
<h1>目录 contents (main & master)</h1>
<ul>
  {''.join(toc_entries)}
</ul>
</body>
</html>
"""

with open("index.html", "w", encoding="utf-8") as f:
    f.write(html_output)
