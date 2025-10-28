# 🧠 FigureYa AI RAG系统

基于智谱AI GLM-4和OpenAI GPT的智能生物医学数据分析助手，为FigureYa 300+ 模块提供专业AI驱动的搜索和建议功能。

## 🚀 生产环境部署（推荐）

### 云服务器部署
所有AI功能现在通过云服务器提供真实API调用：

```
📁 独立部署目录: /Users/mypro/figureya-cloud-server/
├── frontend/figureya_ai_search_professional.html  # 前端界面（带语言切换）
├── backend/app.py                                # 生产环境后端
├── config/                                       # 完整配置文件
├── scripts/deploy.sh                             # 云服务器一键部署
└── scripts/start.sh                              # 本地测试启动
```

### 用户访问方式
- **云服务器**: https://your-domain.com
- **本地测试**: http://localhost:8080

### 快速部署
```bash
# 1. 进入云部署目录
cd /Users/mypro/figureya-cloud-server

# 2. 本地测试
./scripts/start.sh

# 3. 云服务器部署（上传后）
./scripts/deploy.sh
```

## 💰 成本估算
- **云服务器**: ¥50-100/月（2核4G配置）
- **API调用**: ¥0.01/次查询
- **总成本**: ¥60-150/月

## 🔑 API密钥配置

### 智谱AI（推荐）
1. 访问: https://bigmodel.cn/usercenter/proj-mgmt/apikeys
2. 创建API密钥并充值

### OpenAI
1. 访问: https://platform.openai.com/api-keys
2. 创建API密钥

## 🌐 功能特点

- ✅ **真实AI功能** - 支持智谱AI和OpenAI
- ✅ **语言切换** - 中英文界面自动切换
- ✅ **专业设计** - Google风格界面
- ✅ **安全可靠** - HTTPS加密，API密钥保护
- ✅ **高可用性** - Docker容器化部署
- ✅ **智能推荐** - 基于查询的模块推荐

## 📖 详细文档

完整部署指南请参考：
- 云部署使用说明: `/Users/mypro/figureya-cloud-server/使用说明.md`
- 英文部署指南: `/Users/mypro/figureya-cloud-server/README_DEPLOY.md`

---

🎉 **用户现在可以通过网址直接使用真正的AI功能了！**