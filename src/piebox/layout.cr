module Piebox
  GRID_COLS = 2
  GRID_ROWS = 3
  GRID_UNITS = GRID_COLS * GRID_ROWS

  # A Layout is a pattern of cells that tiles the full 2x3 grid.
  struct Layout
    getter id : String
    getter cells : Array(Cell)
    getter comic_compatible : Bool

    def initialize(@id, @cells, @comic_compatible = true)
    end

    # Number of image slots in this layout.
    def cell_count : Int32
      cells.size
    end

    # Total units covered by all cells.
    def total_units : Int32
      cells.sum(&.units)
    end

    # Validates that cells tile the full grid without overlaps or gaps.
    def valid? : Bool
      return false unless total_units == GRID_UNITS

      covered = Set(Tuple(Int32, Int32)).new
      cells.each do |cell|
        cell.covered_positions.each do |pos|
          col, row = pos
          return false if col < 0 || col >= GRID_COLS
          return false if row < 0 || row >= GRID_ROWS
          return false if covered.includes?(pos)
          covered.add(pos)
        end
      end

      covered.size == GRID_UNITS
    end
  end
end
