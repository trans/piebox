# PieBox

A Crystal tool for creating picture books and comic books from tagged images. Given a YAML manifest of images with significance levels and modifiers, PieBox arranges them into page layouts on a 2x3 grid and renders to PDF.

## How It Works

1. You write a **YAML manifest** describing your images, their significance (`climax`, `epic`, `normal`), and optional modifiers (`vista`, `action`)
2. The **packer** groups images into pages, choosing from 20 predefined grid layouts that best fit the image mix
3. The **renderer** outputs a PDF with images placed in cells, scaled to fit (letterboxed), with optional captions and AI-generated dialogue

### Significance Levels

- **climax** — Full page (cover, centerfold, finale)
- **epic** — Large cell: 1/2, 1/3, or 1/4 of page
- **normal** — Standard cell: 1/6 of page, can expand to 1/3 to fill gaps

### Modifiers

- **vista** — Prefers landscape (wider-than-tall) cells
- **action** — Applies a visual effect preset:
  - `split3` — Crops image into 3 horizontal panes
  - `zoom_in` — Progressive zoom sequence (3 panes)
  - `motion_lines` — Overlay speed lines on the image

### Book Types

- **comic** — Left-to-right, top-to-bottom reading flow; only uses flow-compatible layouts
- **picture_book** — No flow constraint; uses all available layouts

### AI Text Generation (Optional)

PieBox can generate dialogue or narration for comic pages using either:
- **Ollama** — Local model (e.g. llama3)
- **Anthropic** — Claude Haiku API

Provide image descriptions in the manifest and PieBox generates short, punchy text for speech bubbles.

## Requirements

- Crystal >= 1.19.1
- `libcairo2-dev` (system package for PDF rendering)

## Installation

```sh
shards install
crystal build src/piebox_cli.cr -o bin/piebox
```

## Usage

### Create a manifest

```yaml
# piebox.yml
book_type: comic
title: "My Comic"
page_width: 210     # mm (A4 default)
page_height: 297
margin: 10
gutter: 5

# Optional AI config
ai:
  backend: ollama
  model: llama3

images:
  - path: img/cover.png
    significance: climax
    caption: "The adventure begins"

  - path: img/fight.png
    significance: normal
    modifiers: [action]
    action_style: split3
    description: "Hero punches villain"

  - path: img/landscape.png
    significance: epic
    modifiers: [vista]

  - path: img/panel1.png
    significance: normal

  - path: img/panel2.png
    significance: normal

  - path: img/finale.png
    significance: climax
    caption: "The end"
```

### Run

```sh
# Basic usage
piebox piebox.yml -o mycomic.pdf

# Skip AI text generation
piebox piebox.yml -o mycomic.pdf --no-ai

# Help
piebox --help
```

### Library Usage

```crystal
require "piebox"

manifest = Piebox::Manifest.from_yaml(File.read("piebox.yml"))
images = manifest.to_image_tags

packer = Piebox::Packer.new(manifest.parsed_book_type)
pages = packer.pack(images)

renderer = Piebox::Renderer.new(manifest)
renderer.render(pages, "output.pdf")
```

## Development

```sh
# Run specs
crystal spec

# Build
crystal build src/piebox_cli.cr
```

## Current Limitations (v0.1)

- PNG images only
- Fixed 2x3 grid (6 units per page)
- No custom fonts or text styling
- Speech bubbles use basic positioning (upper-right of cell)
- AI backends require external setup (running Ollama instance or Anthropic API key)

## License

MIT
