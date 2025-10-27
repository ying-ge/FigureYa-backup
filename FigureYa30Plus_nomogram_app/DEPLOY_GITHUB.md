# 🚀 GitHub Pages 部署指南

## 📋 准备工作

### 1. 创建GitHub账号
1. 访问 https://github.com/signup
2. 注册新账号（免费）
3. 验证邮箱

### 2. 创建新仓库
1. 访问 https://github.com/new
2. 仓库名称: `nomogram-app` (或自定义)
3. 设为Public（公开）
4. 不要添加README、.gitignore等
5. 点击"Create repository"

### 3. 上传文件

#### 方法A: 网页上传（简单）
1. 在新创建的仓库页面，点击"Add file" → "Upload files"
2. 拖拽这些文件：
   - `index.html`
   - `manifest.json`
   - `sw.js`
   - `css/` 文件夹
   - `js/` 文件夹
   - `images/` 文件夹
   - `test-pwa.html`

#### 方法B: Git命令（推荐）
```bash
# 克隆仓库
git clone https://github.com/你的用户名/nomogram-app.git
cd nomogram-app

# 复制所有文件到仓库
cp -r /Users/mypro/Downloads/FigureYa/FigureYa30Plus_nomogram_app/* .

# 提交并推送
git add .
git commit -m "Initial commit: Nomogram PWA App"
git push origin main
```

### 4. 启用GitHub Pages

1. 在仓库页面，点击 **Settings**
2. 找到 **Pages** 选项（左侧菜单）
3. **Source**: 选择 **Deploy from a branch**
4. **Branch**: 选择 **main**
5. **Folder**: 选择 **/(root)**
6. 点击 **Save**

### 5. 获取链接

等待1-2分钟后，在Pages页面会显示：
```
🎉 Your site is live at https://你的用户名.github.io/nomogram-app/
```

## 📱 iPhone安装测试

1. 在iPhone Safari中访问你的GitHub Pages链接
2. 测试应用功能
3. 点击分享按钮 → "添加到主屏幕"
4. 永久可用的nomogram应用！

## ✅ 优势

- ✅ **完全免费**: 无需付费
- ✅ **永久有效**: 只要GitHub账号存在
- ✅ **自定义域名**: 可以绑定自己的域名
- ✅ **HTTPS自动**: 自动SSL证书
- ✅ **全球CDN**: GitHub提供全球加速
- ✅ **版本控制**: Git管理所有更改

## 🔄 更新应用

当需要更新应用时：
```bash
cd nomogram-app
git add .
git commit -m "Update nomogram app"
git push origin main
```
GitHub会自动更新网站！

## 🆘 常见问题

**Q: 网站没有显示？**
- 检查是否有index.html文件
- 确保仓库名设置正确
- 等待2-3分钟让GitHub处理

**Q: PWA功能不工作？**
- 确保manifest.json路径正确
- 检查Service Worker注册
- 在HTTPS环境下测试

**Q: 想要自定义域名？**
- 在仓库Settings → Pages中设置Custom Domain
- 按照GitHub的DNS配置说明操作