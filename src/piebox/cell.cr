module Piebox
  # Represents a cell in a 2-column, 3-row grid.
  # col and row are 0-indexed. Spans default to 1.
  struct Cell
    getter col : Int32
    getter row : Int32
    getter col_span : Int32
    getter row_span : Int32

    def initialize(@col, @row, @col_span = 1, @row_span = 1)
    end

    # Number of grid units this cell occupies.
    def units : Int32
      col_span * row_span
    end

    # Whether the cell is wider than it is tall (in grid units).
    def landscape? : Bool
      col_span > row_span
    end

    # Returns set of {col, row} pairs this cell covers.
    def covered_positions : Array(Tuple(Int32, Int32))
      positions = [] of Tuple(Int32, Int32)
      row_span.times do |dr|
        col_span.times do |dc|
          positions << {col + dc, row + dr}
        end
      end
      positions
    end
  end
end
