# FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency

This repository provides the complete set of input files, analysis code, and results from the FigureYa manuscript.

## 🔎 Interactive Results Browser

All generated reports are hosted on a dedicated webpage, featuring a powerful full-text search.

**[https://ying-ge.github.io/FigureYa/](https://ying-ge.github.io/FigureYa/)**

**Note:** The initial page load may be slow depending on your network. Please allow a few seconds for the content to appear.

### Using the Search
The primary feature is the **search box** at the top of the page. You can use it to perform a full-text search across all HTML reports. The search results will display:
*   A snippet of **context** showing where your keyword appears.
*   A direct **link** to the specific FigureYa report containing the term.

This allows you to quickly pinpoint relevant information (e.g., a specific function name, R package, analysis title, or figure) across all FigureYa files.

### Manual Browsing
Alternatively, you can manually browse the reports by clicking on the thumbnails and HTML links for each FigureYa folder listed on the page.

---

## 📦 Getting the Code and Data

You have three options for accessing the files.

### 1. Download for Offline Use

All FigureYa modules are available as individually compressed zip files for convenient offline use. To download a specific module:

1.  Navigate to the [FigureYa-compressed](https://github.com/ying-ge/FigureYa-compressed) repository.
2.  Locate the zip file corresponding to the module you need (e.g., `FigureYa123mutVSexpr.zip`).
3.  Click on the file, then select the **Download** button.

**Note on File Availability:**
- [all_included.txt](https://github.com/ying-ge/FigureYa/blob/main/.github/docs/all_included.txt) contains a complete list of all available FigureYa modules.
- If a particular module is not listed in [all_included.txt](https://github.com/ying-ge/FigureYa/blob/main/.github/docs/all_included.txt), this indicates that its input files exceed GitHub's file size limitations.
- For these larger files: some Rmd files include direct download links for the required data files. For files without direct download links, please visit our [`Baidu Cloud`](https://pan.baidu.com) storage. Join the baidu group: **967269198** to access the download links.

### 2. Browse Online on GitHub
If you want to view the code, input or output files directly, you can browse them in the file browser at the top of this repository's main page.

#### 3. Download the Repository Using git or GitHub CLI
You can use `git` or [GitHub CLI (gh)](https://cli.github.com/) to download the repository to your computer.  
For step-by-step usage instructions, please visit the [wiki page](https://github.com/ying-ge/FigureYa/wiki).

---

## :file_folder: Structure of a FigureYa Directory
Each `FigureYa` directory follows a consistent structure:

1. **Core Files**
   - `*.Rmd`: The R Markdown script, containing the main analysis and plotting code.
   - `*.html`: The knitted report generated from the R Markdown file.
   - `install_dependencies.R`: A script automatically run by the .Rmd file to set up the required environment.
2. **Input Files**  
   - `easy_input_*`: Primary data/parameters (e.g., `easy_input_data.csv`)  
   - `example.png`: Reference image specifying plot requirements (style/layout)  
3. **Output Files**  
   - `*.pdf`: Vector graphic results (editable, publication-ready)  
   - `output_*`: Text/tables (e.g., `output_results.txt`)  

**Example (`FigureYa59volcanoV2`)**  
```plaintext
FigureYa59volcanoV2/
├── FigureYa59volcanoV2.Rmd          # Main analysis script
├── install_dependencies.R           # Automatic dependency installer
├── FigureYa59volcanoV2.html         # HTML report
├── easy_input_limma.csv             # Input data
├── easy_input_selected.csv          # Input data
├── Volcano_classic.pdf              # Vector graphic (PDF)
├── Volcano_advanced.pdf             # Vector graphic (PDF)
└── example.png                      # Style reference for plots
```

---

## ✍️ Usage and Citation

This project is licensed under the **[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/)**.

If you use this project in your research, please cite:

> Xiaofan Lu, et al. (2025). *FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency*. iMetaMed. [https://doi.org/10.1002/imm3.70005](https://doi.org/10.1002/imm3.70005)

*A pre-formatted BibTeX entry will be added here upon final publication.*

---

## 🌱 FigureYa Ecosystem

The FigureYa community has developed many extension tools based on this project.  
Visit our [ecosystem page](https://github.com/ying-ge/FigureYa/wiki/FigureYa-Ecosystem) to discover more related tools or contribute your own!  
The ecosystem includes various intelligent extensions and visualization plugins to empower research and data analysis.

---

## :handshake:To Be Continued

FigureYa is continuously being updated with improvements to existing modules and the addition of new ones. We welcome interested contributors to join the development of FigureYa. Contact us on WeChat: **epigenomics** for more information.
