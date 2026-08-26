# Windows-Spotlight-Extractor

# 🖼️ Windows 聚焦壁纸提取工具

一键提取 Windows 聚焦（Windows Spotlight）的精美壁纸，保存为可直接查看的 JPG 图片。

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## ✨ 功能特点

- 🔍 **自动定位** — 自动找到 Windows 聚焦壁纸的存储目录
- 🧠 **智能过滤** — 只提取大于 100KB 的文件（过滤缩略图/图标）
- 🏷️ **自动命名** — 为无扩展名的资源文件添加 `.jpg` 后缀
- 🔄 **去重跳过** — 已提取过的壁纸不会重复复制
- 📂 **自动打开** — 提取完成后自动打开目标文件夹
- 📦 **可打包为 EXE** — 支持打包为独立可执行文件

---

## 📥 下载使用

### 方法一：直接运行脚本（推荐）
1. 下载 `ExtractSpotlight.bat`
2. **双击运行** → 自动在当前目录创建 `Windows聚焦壁纸` 文件夹
3. 提取完成后自动打开文件夹

### 方法二：指定输出目录
将文件夹**拖放到脚本上**，或命令行运行：
```bat
ExtractSpotlight.bat D:\我的壁纸
