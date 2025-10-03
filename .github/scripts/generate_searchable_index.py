import os
import re
import json
from bs4 import BeautifulSoup

PUBLISH_DIR = "."  # 输出到根目录

def extract_number(s):
    m = re.search(r'(\d+)', s)
    return int(m.group(1)) if m else 999999

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
    toc = []
    folders = [f for f in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, f)) and not f.startswith('.')]
    folders_sorted = sorted(folders, key=extract_number)
    for folder in folders_sorted:
        folder_path = os.path.join(base_path, folder)
        html_files = [f for f in os.listdir(folder_path) if f.endswith('.html')]
        html_files_sorted = sorted(html_files, key=extract_number)
        if html_files_sorted:
            toc.append(f"<li><b>{folder}</b><ul>")
            for fname in html_files_sorted:
                rel_path = os.path.relpath(os.path.join(folder_path, fname), PUBLISH_DIR)
                chap_id = f"{branch_label}_{folder}_{fname}".replace(" ", "_").replace(".html", "")
                toc.append(f'<li><a href="{rel_path}">{fname}</a></li>')
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
                    "text": text_path
                })
            toc.append("</ul></li>")
    return toc

toc_entries = []
chapters_meta = []
toc_entries.extend(get_html_files(".", "main", chapters_meta))

# Write chapters.json to root
with open(os.path.join(PUBLISH_DIR, "chapters.json"), "w", encoding="utf-8") as jf:
    json.dump(chapters_meta, jf, ensure_ascii=False, indent=2)

# English lite.html with search box and JS, write to root
html_output = f"""
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Contents Directory</title>
  <script src="js/fuse.min.js"></script>
  <script src="js/search.js" defer></script>
  <style>
    body {{ font-family: Arial, sans-serif; }}
    ul {{ list-style-type: none; }}
    li > ul {{ margin-left: 2em; }}
    #searchResults {{ margin-top: 2em; }}
    .result {{ margin-bottom: 1em; }}
    .result-title {{ font-weight: bold; }}
    .highlight {{ background: yellow; }}
  </style>
</head>
<body>
<h1>Contents Directory (main)</h1>
<input type="text" id="searchBox" placeholder="Enter keyword to search all chapters..." autocomplete="off" style="width:60%; font-size:1.1em;">
<button onclick="doSearch()">Search</button>
<button onclick="clearSearch()">Clear</button>
<div id="searchResults"></div>
<hr>
<ul>
  {''.join(toc_entries)}
</ul>
<script>
  document.addEventListener("DOMContentLoaded", function() {{
    document.getElementById("searchBox").addEventListener("keydown", function(e){{
      if (e.key === "Enter") doSearch();
    }});
  }});
</script>
</body>
</html>
"""

with open(os.path.join(PUBLISH_DIR, "lite.html"), "w", encoding="utf-8") as f:
    f.write(html_output)
