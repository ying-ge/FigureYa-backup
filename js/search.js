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

  // 显示加载动画
  tocGrid.innerHTML = `
    <div class="loading-container">
      <div class="loading-spinner"></div>
      <div class="loading-text">Loading ${chapters.length} modules...</div>
    </div>
  `;

  // 使用 requestAnimationFrame 确保加载动画先渲染
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
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

        html += `<div class="card" data-folder="${folderData.folder}">`;

        // 添加可点击的图片，带下载图标提示
        html += `<div class="card-image-wrapper" style="position:relative;cursor:pointer;" onclick="showDownloadModal('${folderData.folder}')">`;
        html += thumb
          ? `<img src="${thumb}" alt="${folderData.folder}" loading="lazy" style="opacity:0;transition:opacity 0.3s" onload="this.style.opacity=1" onerror="this.style.display='none';this.nextElementSibling.style.display='block'"><div style="width:100%;height:80px;background:#eee;border-radius:6px;margin-bottom:8px;display:none;"></div>`
          : `<div style="width:100%;height:80px;background:#eee;border-radius:6px;margin-bottom:8px;"></div>`;

        // 添加下载图标覆盖层
        html += `<div class="download-overlay" style="position:absolute;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);border-radius:8px;display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity 0.3s;">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
            <polyline points="7 10 12 15 17 10"></polyline>
            <line x1="12" y1="15" x2="12" y2="3"></line>
          </svg>
        </div>`;
        html += `</div>`;

        html += `<div class="card-title">${folderData.folder}</div>`;
        html += `<div class="card-links">`;
        folderData.htmls.forEach(h => {
          html += `<a href="${h.href}" target="_blank" style="display:inline-block;margin:0 3px 2px 0">${h.name}</a>`;
        });
        html += `</div></div>`;
      });
      tocGrid.innerHTML = html;

      // 添加卡片悬停效果
      setTimeout(() => {
        document.querySelectorAll('.card-image-wrapper').forEach(wrapper => {
          wrapper.addEventListener('mouseenter', function() {
            this.querySelector('.download-overlay').style.opacity = '1';
          });
          wrapper.addEventListener('mouseleave', function() {
            this.querySelector('.download-overlay').style.opacity = '0';
          });
        });
      }, 100);

      console.log(`✅ Rendered ${sortedFolders.length} modules in ${(performance.now() - loadAllChapters.startTime).toFixed(0)}ms`);
    });
  });
}

function loadAllChapters(callback) {
  loadAllChapters.startTime = performance.now();

  fetch('chapters.json')
    .then(res => res.json())
    .then(list => {
      chapters = list;
      console.log(`📦 Loaded chapters.json (${list.length} entries) in ${(performance.now() - loadAllChapters.startTime).toFixed(0)}ms`);

      // 立即渲染图片网格，不等待文本加载
      renderToc();

      // 在后台加载所有文本文件
      console.log('📄 Loading text files for search index...');
      const loadedPromises = chapters.map((chap, i) =>
        fetch(chap.text)
          .then(res => res.text())
          .then(text => ({ ...chap, text }))
          .catch(() => ({ ...chap, text: "[Failed to load text]" }))
      );

      Promise.all(loadedPromises).then(results => {
        chapterTexts = results;
        buildIndex();
        const loadTime = (performance.now() - loadAllChapters.startTime).toFixed(0);
        console.log(`✅ Search index built with ${results.length} modules in ${loadTime}ms`);
        // 回调函数现在只在搜索索引准备好时调用
        if (callback) callback();
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

  // 检查搜索索引是否已加载
  if (!fuse) {
    resultsDiv.innerHTML = `<p style="color:#e53e3e">Search index is still loading. Please wait a moment and try again.</p>`;
    tocGrid.style.display = "none";
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

    filteredHtml += `<div class="card" data-folder="${folderData.folder}">`;

    // 添加可点击的图片
    filteredHtml += `<div class="card-image-wrapper" style="position:relative;cursor:pointer;" onclick="showDownloadModal('${folderData.folder}')">`;
    filteredHtml += thumb
      ? `<img src="${thumb}" alt="${folderData.folder}" loading="lazy">`
      : `<div style="width:100%;height:80px;background:#eee;border-radius:6px;margin-bottom:8px;"></div>`;

    // 添加下载图标覆盖层
    filteredHtml += `<div class="download-overlay" style="position:absolute;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);border-radius:8px;display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity 0.3s;">
      <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
        <polyline points="7 10 12 15 17 10"></polyline>
        <line x1="12" y1="15" x2="12" y2="3"></line>
      </svg>
    </div>`;
    filteredHtml += `</div>`;

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

  // 添加卡片悬停效果
  document.querySelectorAll('#resultsGrid .card-image-wrapper').forEach(wrapper => {
    wrapper.addEventListener('mouseenter', function() {
      this.querySelector('.download-overlay').style.opacity = '1';
    });
    wrapper.addEventListener('mouseleave', function() {
      this.querySelector('.download-overlay').style.opacity = '0';
    });
  });
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
        // 搜索索引已准备好，可以显示搜索提示
        console.log('Search functionality is ready');
    });
});
