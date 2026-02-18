module Piebox
  module Catalog
    # All valid layouts for the 2x3 grid, enumerated from DESIGN.md.
    # Grid is 2 columns (0-1), 3 rows (0-2).

    LAYOUTS = build_layouts

    private def self.build_layouts : Array(Layout)
      layouts = [] of Layout

      # === 1 Cell (1 option) ===
      # Full page
      layouts << Layout.new("1a", [
        Cell.new(0, 0, 2, 3),
      ])

      # === 2 Cells (2 options) ===
      # Top half / bottom half (horizontal split)
      # |___|
      # |   |
      layouts << Layout.new("2a", [
        Cell.new(0, 0, 2, 1),
        Cell.new(0, 1, 2, 2),
      ])

      # Left / right (vertical split)
      # | | |
      # | | |
      layouts << Layout.new("2b", [
        Cell.new(0, 0, 1, 3),
        Cell.new(1, 0, 1, 3),
      ])

      # === 3 Cells (4 options) ===
      # Top wide, bottom two
      # |___|
      # | | |
      layouts << Layout.new("3a", [
        Cell.new(0, 0, 2, 1),
        Cell.new(0, 1, 1, 2),
        Cell.new(1, 1, 1, 2),
      ])

      # Top two, bottom wide
      # |_|_|
      # |   |
      layouts << Layout.new("3b", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 2, 2),
      ])

      # Left tall, right column split
      # |_| |
      # | | |
      layouts << Layout.new("3c", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 3),
        Cell.new(0, 1, 1, 2),
      ], comic_compatible: true)

      # Right tall, left column split
      # | |_|
      # | | |
      layouts << Layout.new("3d", [
        Cell.new(0, 0, 1, 3),
        Cell.new(1, 0, 1, 1),
        Cell.new(1, 1, 1, 2),
      ], comic_compatible: true)

      # === 4 Cells (various options) ===

      # 2x2 even grid (top 2 rows), bottom wide
      # |_|_|
      # | | |
      # This is ambiguous from DESIGN.md — interpreting as 4 equal quadrants
      # Actually: top row split, bottom 2 rows split
      # |_|_|
      # | | |
      # means top 1 row has 2 cells, bottom 2 rows have 2 cells
      layouts << Layout.new("4a", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 1, 2),
        Cell.new(1, 1, 1, 2),
      ])

      # Left tall, right column 3-split (only last is comic-compatible per DESIGN.md)
      # |_| |
      # |_| |
      # | | |
      layouts << Layout.new("4b", [
        Cell.new(0, 0, 1, 1),
        Cell.new(0, 1, 1, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 0, 1, 3),
      ], comic_compatible: false)

      # Right tall, left column 3-split
      # | |_|
      # | |_|
      # | | |
      layouts << Layout.new("4c", [
        Cell.new(0, 0, 1, 3),
        Cell.new(1, 0, 1, 1),
        Cell.new(1, 1, 1, 1),
        Cell.new(1, 2, 1, 1),
      ], comic_compatible: false)

      # Zigzag: top-right tall, bottom-left tall
      # | |_|
      # |_| |
      # | | |
      layouts << Layout.new("4d", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 2),
        Cell.new(0, 1, 1, 2),
        Cell.new(1, 2, 1, 1),
      ], comic_compatible: false)

      # Zigzag reverse
      # |_| |
      # | |_|
      # | | |
      layouts << Layout.new("4e", [
        Cell.new(0, 0, 1, 2),
        Cell.new(1, 0, 1, 1),
        Cell.new(1, 1, 1, 2),
        Cell.new(0, 2, 1, 1),
      ], comic_compatible: true)

      # Top wide, middle two, bottom wide
      # |___|
      # |___|
      # | | |
      layouts << Layout.new("4f", [
        Cell.new(0, 0, 2, 1),
        Cell.new(0, 1, 2, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 2, 1, 1),
      ])

      # Top wide, middle split, bottom wide
      # |___|
      # |_|_|
      # |   |
      layouts << Layout.new("4g", [
        Cell.new(0, 0, 2, 1),
        Cell.new(0, 1, 1, 1),
        Cell.new(1, 1, 1, 1),
        Cell.new(0, 2, 2, 1),
      ])

      # Top split, middle wide, bottom wide
      # |_|_|
      # |___|
      # |   |
      layouts << Layout.new("4h", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 2, 1),
        Cell.new(0, 2, 2, 1),
      ])

      # === 5 Cells ===
      # Top wide, middle split, bottom split
      # |___|
      # |_|_|
      # |_|_|
      layouts << Layout.new("5a", [
        Cell.new(0, 0, 2, 1),
        Cell.new(0, 1, 1, 1),
        Cell.new(1, 1, 1, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 2, 1, 1),
      ])

      # Top split, middle wide, bottom split
      # |_|_|
      # |___|
      # |_|_|
      layouts << Layout.new("5b", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 2, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 2, 1, 1),
      ])

      # Top split, middle split, bottom wide
      # |_|_|
      # |_|_|
      # |   |
      layouts << Layout.new("5c", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 1, 1),
        Cell.new(1, 1, 1, 1),
        Cell.new(0, 2, 2, 1),
      ])

      # Not comic compatible 5-cell layouts
      # |_|_|
      # |_| |
      # |_| |
      layouts << Layout.new("5d", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 1, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 1, 1, 2),
      ], comic_compatible: false)

      # |_|_|
      # | |_|
      # | |_|
      layouts << Layout.new("5e", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 1, 2),
        Cell.new(1, 1, 1, 1),
        Cell.new(1, 2, 1, 1),
      ], comic_compatible: false)

      # | |_|
      # |_|_|
      # | | |
      layouts << Layout.new("5f", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 2),
        Cell.new(0, 1, 1, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 2, 1, 1),
      ], comic_compatible: false)

      # |_| |
      # |_|_|
      # | | |
      layouts << Layout.new("5g", [
        Cell.new(0, 0, 1, 2),
        Cell.new(1, 0, 1, 1),
        Cell.new(1, 1, 1, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 2, 1, 1),
      ], comic_compatible: false)

      # === 6 Cells (1 option) ===
      # Full 2x3 grid
      # |_|_|
      # |_|_|
      # | | |
      layouts << Layout.new("6a", [
        Cell.new(0, 0, 1, 1),
        Cell.new(1, 0, 1, 1),
        Cell.new(0, 1, 1, 1),
        Cell.new(1, 1, 1, 1),
        Cell.new(0, 2, 1, 1),
        Cell.new(1, 2, 1, 1),
      ])

      layouts
    end

    # Filter layouts by cell count and optional comic compatibility.
    def self.for_count(count : Int32, comic : Bool = false) : Array(Layout)
      LAYOUTS.select do |layout|
        layout.cell_count == count && (!comic || layout.comic_compatible)
      end
    end

    # Get all layouts, optionally filtered by comic compatibility.
    def self.all(comic : Bool = false) : Array(Layout)
      if comic
        LAYOUTS.select(&.comic_compatible)
      else
        LAYOUTS
      end
    end
  end
end
