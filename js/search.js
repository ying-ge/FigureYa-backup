let chapters = [];
let chapterTexts = [];

function highlight(text, terms) {
  const re = new RegExp("(" + terms.map(t => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|') + ")", "gi");
  return text.replace(re, `<span class="highlight">$1</span>`);
}

function getContextSnippet(text, query, contextLength = 50) {
  const queryLower = query.toLowerCase();
  const textLower = text.toLowerCase();

  // Find first occurrence of query in text
  const index = textLower.indexOf(queryLower);
  if (index === -1) return '';

  // Calculate context boundaries
  const start = Math.max(0, index - contextLength);
  const end = Math.min(text.length, index + query.length + contextLength);

  // Extract context
  let context = text.substring(start, end);

  // Add ellipsis if truncated
  if (start > 0) context = '...' + context;
  if (end < text.length) context = context + '...';

  return context;
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
  const tocGrid = document.getElementById("tocGrid");

  if (!q) {
    resultsDiv.innerHTML = "";
    tocGrid.style.display = "flex";
    return;
  }

  const results = fuse.search(q);

  if (results.length === 0) {
    resultsDiv.innerHTML = `<p>No results found for "${q}"</p>`;
    tocGrid.style.display = "none";
    return;
  }

  // 获取匹配的文件夹并保持去重和顺序
  const matchedFolders = new Set();
  results.forEach(r => {
    matchedFolders.add(r.item.folder);
  });

  // 筛选出匹配的文件夹数据
  const filteredFolders = [];
  const folderMap = {};

  // 重新构建文件夹映射，但只包含匹配的文件夹
  chapters.forEach(item => {
    if (matchedFolders.has(item.folder)) {
      if (!folderMap[item.folder]) {
        folderMap[item.folder] = { ...item, htmls: [] };
        filteredFolders.push(folderMap[item.folder]);
      }
      folderMap[item.folder].htmls.push({ name: item.html.split("/").pop(), href: item.html });
    }
  });

  resultsDiv.innerHTML = `<p>${results.length} result${results.length === 1 ? '' : 's'} found in ${filteredFolders.length} module${filteredFolders.length === 1 ? '' : 's'}:</p>`;

  // 隐藏原来的网格，显示筛选后的结果
  tocGrid.style.display = "none";

  // 创建筛选后的结果网格
  let filteredHtml = '';
  filteredFolders.forEach(folderData => {
    const thumb = folderData.thumb;

    // Find the first matching result for this folder to get context
    const matchingResult = results.find(r => r.item.folder === folderData.folder);
    let contextSnippet = '';
    if (matchingResult) {
      contextSnippet = getContextSnippet(matchingResult.item.text, q);
      if (contextSnippet) {
        // Highlight the search terms in the context
        const terms = q.split(/\s+/).filter(t => t.length > 0);
        contextSnippet = highlight(contextSnippet, terms);
      }
    }

    filteredHtml += `<div class="card">`;
    filteredHtml += thumb
      ? `<img src="${thumb}" alt="${folderData.folder}" loading="lazy">`
      : `<div style="width:100%;height:80px;background:#eee;border-radius:6px;margin-bottom:8px;"></div>`;

    filteredHtml += `<div class="card-title">${folderData.folder}</div>`;
    filteredHtml += `<div class="card-links">`;
    folderData.htmls.forEach(h => {
      filteredHtml += `<a href="${h.href}" target="_blank" style="display:inline-block;margin:0 3px 2px 0">${h.name}</a>`;
    });
    filteredHtml += `</div>`;

    if (contextSnippet) {
      filteredHtml += `<div class="card-context">${contextSnippet}</div>`;
    }

    filteredHtml += `</div>`;
  });

  // 创建新的结果网格容器
  let resultsGrid = document.getElementById("resultsGrid");
  if (!resultsGrid) {
    resultsGrid = document.createElement("div");
    resultsGrid.id = "resultsGrid";
    resultsGrid.className = "grid";
    resultsDiv.parentNode.insertBefore(resultsGrid, resultsDiv.nextSibling);
  }

  resultsGrid.innerHTML = filteredHtml;
  resultsGrid.style.display = "flex";
}

function clearSearch() {
  document.getElementById("searchBox").value = "";
  document.getElementById("searchResults").innerHTML = "";

  // 显示原始网格并隐藏筛选网格
  const tocGrid = document.getElementById("tocGrid");
  const resultsGrid = document.getElementById("resultsGrid");

  if (tocGrid) {
    tocGrid.style.display = "flex";
  }

  if (resultsGrid) {
    resultsGrid.style.display = "none";
  }
}

window.addEventListener('DOMContentLoaded', () => {
    loadAllChapters(() => {
        buildIndex();
        renderToc();
    });
});
