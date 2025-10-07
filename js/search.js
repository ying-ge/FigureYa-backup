let chapters = [];
let chapterTexts = [];

function highlight(text, terms) {
  const re = new RegExp("(" + terms.map(t => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|') + ")", "gi");
  return text.replace(re, `<span class="highlight">$1</span>`);
}

function renderToc() {
  const tocGrid = document.getElementById("tocGrid");
  if (!tocGrid) return;

  // 1. 按文件夹分组，并保留每个文件夹的第一个条目作为代表，用于后续排序
  const folderMap = {};
  chapters.forEach(item => {
    if (!folderMap[item.folder]) {
      // 直接使用 item 对象作为基础，它包含了所有需要的信息（folder, thumb）
      folderMap[item.folder] = { ...item, htmls: [] };
    }
    folderMap[item.folder].htmls.push({ name: item.html.split("/").pop(), href: item.html });
  });

  // 2. 将 folderMap 转换为数组并排序
  // chapters.json 已经有序，所以 folderMap 的键的插入顺序也是有序的。
  // Object.values() 在现代浏览器中会保留这个顺序，所以这一步确保了最终的显示顺序。
  const sortedFolders = Object.values(folderMap);

  // 3. 渲染
  let html = '';
  sortedFolders.forEach(folderData => {
    // 直接使用从 chapters.json 继承来的 thumb 路径
    const thumb = folderData.thumb; 
    
    html += `<div class="card">`;
    html += thumb 
      ? `<img src="${thumb}" alt="${folderData.folder}" loading="lazy">`
      : `<div style="width:100%;height:80px;background:#eee;border-radius:6px;margin-bottom:8px;"></div>`;
    
    html += `<div class="card-title">${folderData.folder}</div>`;
    html += `<div class="card-links">`;
    folderData.htmls.forEach(h => {
      html += `<a href="${h.href}" target="_blank" style="display:inline-block;margin:0 3px 2px 0">${h.name}</a>`;
    });
    html += `</div></div>`;
  });
  tocGrid.innerHTML = html;
}

function loadAllChapters(callback) {
  fetch('chapters.json')
    .then(res => res.json())
    .then(list => {
      chapters = list;
      const loadedPromises = chapters.map((chap, i) => 
        fetch(chap.text)
          .then(res => res.text())
          .then(text => ({ ...chap, text }))
          .catch(() => ({ ...chap, text: "[Failed to load text]" }))
      );
      
      Promise.all(loadedPromises).then(results => {
        chapterTexts = results;
        callback();
      });
    })
    .catch(() => {
      const resultsDiv = document.getElementById("searchResults");
      if (resultsDiv) {
        resultsDiv.innerHTML = "<p style='color:red'>Failed to load chapters.json. Please check the file and network.</p>";
      }
    });
}

let fuse = null;
function buildIndex() {
  fuse = new Fuse(chapterTexts, {
    keys: ["title", "text"],
    includeMatches: true,
    threshold: 0.4,
    minMatchCharLength: 2,
    ignoreLocation: true,
  });
}

function doSearch() {
  const q = document.getElementById("searchBox").value.trim();
  const resultsDiv = document.getElementById("searchResults");
  if (!q) {
    resultsDiv.innerHTML = "";
    return;
  }
  
  const results = fuse.search(q);
  let html = `<p>${results.length} result${results.length === 1 ? '' : 's'} found:</p>`;
  
  results.forEach(r => {
    let snippet = r.item.text;
    const firstTerm = q.split(/\s+/)[0].toLowerCase();
    let idx = snippet.toLowerCase().indexOf(firstTerm);
    
    if (idx > 30) idx -= 30;
    if (idx < 0) idx = 0;
    
    snippet = snippet.substr(idx, 120).replace(/\n/g, " ");
    snippet = highlight(snippet, q.split(/\s+/));

    html += `<div class="result">
      <div class="result-title"><a href="${r.item.html}" target="_blank">${r.item.title}</a></div>
      <div class="result-snippet">...${snippet}...</div>
    </div>`;
  });
  resultsDiv.innerHTML = html;
}

function clearSearch() {
  document.getElementById("searchBox").value = "";
  document.getElementById("searchResults").innerHTML = "";
}

window.addEventListener('DOMContentLoaded', (event) => {
    loadAllChapters(() => {
        buildIndex();
        renderToc();
    });
});
