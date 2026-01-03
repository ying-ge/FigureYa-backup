import os
import re
import json
from bs4 import BeautifulSoup

PUBLISH_DIR = "."  # 输出到根目录

def extract_number(s):
    """从 'FigureYa101PCA' 这样的字符串中正确提取数字 101 用于排序"""
    m = re.search(r'FigureYa(\d+)', s)
    return int(m.group(1)) if m else 999999

def strip_outputs_and_images(raw_html):
    """从 HTML 中移除图片和输出块，提取纯文本"""
    soup = BeautifulSoup(raw_html, "html.parser")
    for img in soup.find_all("img"):
        img.decompose()
    for pre in soup.find_all("pre"):
        code = pre.find("code")
        if code and code.text.lstrip().startswith("##"):
            pre.decompose()
    for div in soup.find_all("div", class_=lambda x: x and any("output" in c for c in x)):
        div.decompose()
    for pre in soup.find_all("pre"):
        parent = pre.parent
        while parent:
            if parent.has_attr("class") and any("output" in c for c in parent["class"]):
                pre.decompose()
                break
            parent = parent.parent
    return soup.get_text(separator="\n", strip=True)

def get_html_files(base_path, branch_label, chapters_meta):
    """遍历文件夹，提取 HTML 文件信息并生成元数据"""
    folders = [f for f in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, f)) and not f.startswith('.')]
    
    # 使用修正后的 extract_number 函数进行排序
    folders_sorted = sorted(folders, key=extract_number)
    
    for folder in folders_sorted:
        folder_path = os.path.join(base_path, folder)
        html_files = [f for f in os.listdir(folder_path) if f.endswith('.html')]
        
        if not html_files:
            continue

        # 关键逻辑：对于每个文件夹，只确定一次缩略图路径
        # 直接使用文件夹名构建缩略图路径
        thumb_path = f"gallery_compress/{folder}.webp"
        if not os.path.isfile(os.path.join(PUBLISH_DIR, thumb_path)):
            thumb_path = None  # 如果文件不存在，则不设置缩略图

        # 对文件夹内的 HTML 文件进行排序
        html_files_sorted = sorted(html_files)
        
        for fname in html_files_sorted:
            rel_path = os.path.relpath(os.path.join(folder_path, fname), PUBLISH_DIR)
            chap_id = f"{branch_label}_{folder}_{fname}".replace(" ", "_").replace(".html", "")
            
            with open(os.path.join(folder_path, fname), encoding='utf-8') as f:
                raw_html = f.read()
                text = strip_outputs_and_images(raw_html)
            
            texts_dir = os.path.join(PUBLISH_DIR, "texts")
            os.makedirs(texts_dir, exist_ok=True)
            text_path = os.path.join("texts", f"{chap_id}.txt")
            abs_text_path = os.path.join(PUBLISH_DIR, text_path)
            
            with open(abs_text_path, "w", encoding="utf-8") as tf:
                tf.write(text)
                
            chapters_meta.append({
                "id": chap_id,
                "title": f"{folder}/{fname}",
                "html": rel_path,
                "text": text_path,
                "folder": folder,
                "thumb": thumb_path  # 为该文件夹下的所有HTML文件使用同一个缩略图
            })

# --- 主逻辑 ---
chapters_meta = []
get_html_files(".", "main", chapters_meta)

# 将章节元数据写入 chapters.json
with open(os.path.join(PUBLISH_DIR, "chapters.json"), "w", encoding="utf-8") as jf:
    json.dump(chapters_meta, jf, ensure_ascii=False, indent=2)

print(f"成功生成 {len(chapters_meta)} 个章节的索引数据")
print(f"- chapters.json: 章节元数据")
print(f"- texts/: 文本内容目录（用于全文搜索）")
print(f"index.html 现在是静态文件，不会被此脚本覆盖")
