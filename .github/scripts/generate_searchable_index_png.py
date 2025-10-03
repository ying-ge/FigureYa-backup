import os
import re
import json
from bs4 import BeautifulSoup

PUBLISH_DIR = "."  # 输出到根目录

def extract_number(s):
    m = re.search(r'(\d+)', s)
    return int(m.group(1)) if m else 999999

def extract_gallery_base(foldername):
    m = re.match(r'(FigureYa\d+)', foldername)
    return m.group(1) if m else None

def strip_outputs_and_images(raw_html):
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
    folders = [f for f in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, f)) and not f.startswith('.')]
    folders_sorted = sorted(folders, key=extract_number)
    for folder in folders_sorted:
        folder_path = os.path.join(base_path, folder)
        html_files = [f for f in os.listdir(folder_path) if f.endswith('.html')]
        html_files_sorted = sorted(html_files, key=extract_number)
        if html_files_sorted:
            gallery_base = extract_gallery_base(folder)
            thumb_path = f"gallery_compress/{gallery_base}.webp" if gallery_base else None  # 修改为 webp
            if thumb_path and not os.path.isfile(os.path.join(PUBLISH_DIR, thumb_path)):
                thumb_path = None
            for fname in html_files_sorted:
                rel_path = os.path.relpath(os.path.join(folder_path, fname), PUBLISH_DIR)
                chap_id = f"{branch_label}_{folder}_{fname}".replace(" ", "_").replace(".html", "")
                with open(os.path.join(folder_path, fname), encoding='utf-8') as f:
                    raw_html = f.read()
                    text = strip_outputs_and_images(raw_html)
                texts_dir = os.path.join(PUBLISH_DIR, "texts")
                os.makedirs(texts_dir, exist_ok=True)
                text_path = os.path.join("texts", f"{chap_id}.txt")  # relative to root
                abs_text_path = os.path.join(PUBLISH_DIR, text_path)
                with open(abs_text_path, "w", encoding="utf-8") as tf:
                    tf.write(text)
                chapters_meta.append({
                    "id": chap_id,
                    "title": f"{folder}/{fname}",
                    "html": rel_path,
                    "text": text_path,
                    "folder": folder,
                    "thumb": thumb_path
                })

chapters_meta = []
get_html_files(".", "main", chapters_meta)

# Write chapters.json to root
with open(os.path.join(PUBLISH_DIR, "chapters.json"), "w", encoding="utf-8") as jf:
    json.dump(chapters_meta, jf, ensure_ascii=False, indent=2)

# Write index.html with grid placeholder and CSS for card layout
html_output = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>FigureYa Results Browser</title>
  <script src="js/fuse.min.js"></script>
  <script src="js/search.js" defer></script>
  <style>
    body { font-family: sans-serif; }
    #searchResults { margin-top: 2em; }
    .result { margin-bottom: 1em; }
    .result-title { font-weight: bold; }
    .highlight { background: yellow; }
    .grid {
      display: flex;
      flex-wrap: wrap;
      gap: 22px;
      margin: 0 0 64px 0;
      padding: 0;
    }
    .card {
      flex: 1 0 210px;
      max-width: 250px;
      min-width: 180px;
      background: #fafaff;
      border-radius: 8px;
      padding: 12px;
      margin-bottom: 10px;
      box-shadow: 1px 1px 8px #eee;
      display: flex;
      flex-direction: column;
      align-items: center;
      transition: box-shadow .2s;
    }
    .card:hover {
      box-shadow: 2px 4px 20px #ccc;
    }
    .card img {
      width: 100%;
      max-width: 160px;
      max-height: 120px;
      border-radius: 6px;
      background: #fff;
      object-fit: contain;
      margin-bottom: 8px;
    }
    .card-title {
      font-weight: bold;
      font-size: 1.08em;
      margin-bottom: 0.4em;
      text-align: center;
      word-break: break-all;
    }
    .card-links {
      font-size: 0.97em;
      text-align: center;
      word-break: break-all;
    }
    @media (max-width: 1100px) {
      .card { flex-basis: 43%; }
    }
    @media (max-width: 700px) {
      .grid { gap: 15px; }
      .card { flex-basis: 97%; }
    }
  </style>
</head>
<body>

<div style="font-family: sans-serif; max-width: 800px; margin: 2em auto; padding: 1em; border: 1px solid #ddd; border-radius: 8px; background-color: #f9f9f9;">
    <h1 style="text-align: center;">FigureYa: Interactive Results Browser</h1>
    <p>Welcome! This page provides a searchable interface for all reports and figures generated by the <strong>FigureYa</strong> project. It's designed to help you quickly find and explore the results from our manuscript.</p>
    <hr>
    <h2>How to Use This Page</h2>
    <ul>
        <li><strong>Search Everything:</strong> Use the <strong>search box below</strong> to perform a full-text search across all reports. You can look for a gene name, an R package, a specific analysis, or any other keyword.</li>
        <li><strong>Browse Visually:</strong> Click on any of the <strong>thumbnails below</strong> to open and view an individual report directly in your browser.</li>
    </ul>
    <h2>Get the Code and Data</h2>
    <p>All input files, analysis code (Rmd), and results are publicly available in the <a href="https://github.com/ying-ge/FigureYa/" target="_blank">main GitHub repository</a>. You can browse the files online or download them for offline use.</p>
<h2>Citation</h2>
<p>Xiaofan Lu, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. <i>iMetaMed</i>. <a href="https://doi.org/10.1002/imm3.70005" target="_blank">https://doi.org/10.1002/imm3.70005</a></p>
</div>
<hr>

<h1>Search and Browse Reports</h1>
<input type="text" id="searchBox" placeholder="Enter keyword to search all FigureYa reports..." autocomplete="off" style="width:60%; font-size:1.1em;">
<button onclick="doSearch()">Search</button>
<button onclick="clearSearch()">Clear</button>
<div id="searchResults"></div>
<hr>
<div id="tocGrid" class="grid"></div>
<script>
  document.addEventListener("DOMContentLoaded", function() {
    document.getElementById("searchBox").addEventListener("keydown", function(e){
      if (e.key === "Enter") doSearch();
    });
  });
</script>
</body>
</html>
"""

with open(os.path.join(PUBLISH_DIR, "index.html"), "w", encoding="utf-8") as f:
    f.write(html_output)
