# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**FigureYa** is a comprehensive biomedical data visualization framework providing 300+ standardized R Markdown templates for creating scientific figures. It's designed for genomic, transcriptomic, proteomic, and clinical biomedical research, emphasizing reproducibility and scientific best practices.

## Common Development Commands

### Running Individual Modules
Each module (FigureYaXXX directory) can be executed independently:

```bash
# Navigate to a specific module
cd FigureYa101PCA

# Install dependencies (automatic within RMD, but can be run manually)
Rscript install_dependencies.R

# Execute the analysis and generate HTML report
R -e "rmarkdown::render('FigureYa101PCA.Rmd')"
```

### Build and Automation Commands
The repository uses GitHub Actions for automation:

- **Search index generation**: Automatically runs on main branch pushes
- **Gallery compression**: Handles large image files
- **Repository synchronization**: Maintains file consistency

For local development of the search interface:
```bash
# Requires Python and beautifulsoup4
pip install beautifulsoup4
python .github/scripts/generate_searchable_index_png.py
```

## Repository Architecture

### Module Structure Pattern
Every FigureYaXXX directory follows this standardized structure:
```
FigureYaXXXname/
├── FigureYaXXXname.Rmd          # Main R Markdown analysis script
├── install_dependencies.R       # Automatic dependency installer
├── FigureYaXXXname.html         # Generated knitted report
├── easy_input_*.csv             # Standardized input data files
├── example*.png                 # Style reference images
├── *.pdf                        # Vector graphic outputs
└── output_*.txt                 # Results and tables
```

### Key Architectural Patterns

**1. Self-Contained Analysis Modules**
- Each module is completely independent with its own dependencies
- Automatic R/Bioconductor package installation via `install_dependencies.R`
- Standardized CSV input format for easy data substitution

**2. Reproducible Science Framework**
- R Markdown format ensures literate programming
- YAML headers parameterize analyses
- knitr generates reproducible HTML reports

**3. Multi-Language Support**
- Primary analysis in R/RMarkdown
- Python supplements in specific modules (e.g., FigureYa25Plus_Sankey_py)
- JavaScript for web interface and search functionality

**4. Dependency Management**
- CRAN and Bioconductor packages separated in installation scripts
- Error handling for failed package installations
- Version-agnostic approach for broad compatibility

### Data Flow Architecture
1. **Input Layer**: `easy_input_*.csv` files provide standardized data entry
2. **Processing Layer**: R scripts perform analysis using Bioconductor/CRAN packages
3. **Visualization Layer**: ggplot2-based plotting with publication-ready styling
4. **Output Layer**: HTML reports + PDF vector graphics + result tables

## Development Environment Setup

### Prerequisites
- **R/RStudio** (≥ 4.0) for primary development
- **Python 3.x** for supplementary scripts and search functionality
- **Git** for version control

### Module Development Workflow
1. **Choose or create module**: Navigate to `FigureYaXXX` directory
2. **Dependency setup**: Run `install_dependencies.R` to install required packages
3. **Data preparation**: Modify `easy_input_*.csv` files with your data
4. **Execute analysis**: `R -e "rmarkdown::render('FigureYaXXX.Rmd')"`
5. **Review outputs**: Check HTML report, PDF figures, and result tables

### Creating New Modules
1. Use `FigureYa000ContributionTemplate` as a template
2. Follow the standardized directory structure
3. Create `install_dependencies.R` with required packages
4. Design with `easy_input_*.csv` for data flexibility
5. Include `example*.png` for style reference
6. Test reproducibility with different datasets

## Testing Philosophy

FigureYa follows **validation through reproducibility** rather than formal unit testing:

- **Manual testing**: Each module should run successfully with provided example data
- **Output validation**: Generated plots should match style references (`example*.png`)
- **Reproducibility verification**: Same inputs should produce identical outputs
- **Cross-platform compatibility**: Modules should work across different R versions

## Search and Documentation System

The repository includes a sophisticated search interface:
- **Full-text search**: `index.html` with JavaScript-powered search across all modules
- **Search index**: `chapters.json` contains structured metadata
- **Text extraction**: `texts/` directory contains processed content
- **Interactive browsing**: Gallery with thumbnails and direct links

## Contribution Guidelines

### Code Standards
- **R code**: Follow Bioconductor coding standards, use meaningful variable names
- **Documentation**: Bilingual (English/Chinese) comments and explanations
- **RMarkdown**: Use proper YAML headers and knitr options
- **Visualization**: Follow ggplot2 best practices with scientific color schemes

### Module Categories
- **Basic plots**: PCA, volcano, heatmap, survival curves
- **Genomic analysis**: ChIP-seq, RNA-seq, methylation, CNV
- **Proteomics**: Protein interaction, modification analysis
- **Clinical**: Survival analysis, biomarker discovery
- **Multi-omics**: Integration analysis across data types
- **Single-cell**: scRNA-seq, spatial transcriptomics

## Important Notes

- **No formal testing framework**: This is a visualization library, not application software
- **Large file handling**: Some modules use Git LFS or external storage for data >100MB
- **License**: Creative Commons Attribution-NonCommercial-ShareAlike 4.0
- **Citation**: Please cite the FigureYa paper when using modules in research

## File Organization Philosophy

- **Modular design**: Each visualization type is a separate, self-contained module
- **Parameterized inputs**: Easy CSV files allow data swapping without code changes
- **Multiple outputs**: HTML reports, publication-ready PDFs, and result tables
- **Community-driven**: Extensive contribution guidelines and template system