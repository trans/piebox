module Piebox
  # A page pairs a layout with assigned images.
  # Each slot maps a cell index to an ImageTag (or nil for empty cells).
  class Page
    getter layout : Layout
    getter assignments : Array(ImageTag?)

    def initialize(@layout)
      @assignments = Array(ImageTag?).new(layout.cell_count, nil)
    end

    def assign(cell_index : Int32, image : ImageTag)
      @assignments[cell_index] = image
    end

    def full? : Bool
      @assignments.none?(&.nil?)
    end

    def empty_slots : Int32
      @assignments.count(&.nil?)
    end

    def assigned_count : Int32
      @assignments.count { |a| !a.nil? }
    end
  end
end
