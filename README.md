# HPC Systems Simulation Workbook

Lab notes for laboratory exercises on HPC systems built with the [Structural Simulation Toolkit (SST)](https://sst-simulator.org/sst-docs/), written as a [Quarto](https://quarto.org/) book.

## Build

Requires Quarto and Tectonic (`brew install --cask quarto`, `brew install tectonic`).

```bash
make html      # HTML -> _book/
make pdf       # PDF  -> _book/
make preview   # live-reload dev server
make clean
```

## Layout

- `_quarto.yml`: book config and chapter order
- `index.qmd`: preface
- `chapters/NN-slug.qmd`: one file per exercise (`chapters/_template.qmd` is the starting point)
- `code/NN_slug/`: starter files, packed into `_book/code/NN_slug.tar.gz` on render
- `img/NN/`: images per exercise
