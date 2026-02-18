module Piebox
  class Packer
    getter pages : Array(Page)

    def initialize(@book_type : BookType)
      @pages = [] of Page
    end

    def pack(images : Array(ImageTag)) : Array(Page)
      @pages = [] of Page
      cursor = 0

      while cursor < images.size
        tag = images[cursor]

        if tag.significance.climax?
          # Climax always gets a full page
          layout = Catalog.for_count(1).first
          page = Page.new(layout)
          page.assign(0, tag)
          @pages << page
          cursor += 1
        else
          # Collect a window of upcoming non-climax tags (up to 6)
          window = collect_window(images, cursor)
          page = pack_window(window)
          @pages << page
          cursor += page.assigned_count
        end
      end

      @pages
    end

    private def collect_window(images : Array(ImageTag), start : Int32) : Array(ImageTag)
      window = [] of ImageTag
      total_cells = 0
      i = start

      while i < images.size && total_cells < GRID_UNITS
        tag = images[i]
        break if tag.significance.climax?
        needed = tag.cells_needed
        break if total_cells + needed > GRID_UNITS
        window << tag
        total_cells += needed
        i += 1
      end

      # Ensure we have at least one image
      if window.empty? && start < images.size
        window << images[start]
      end

      window
    end

    private def pack_window(window : Array(ImageTag)) : Page
      # Calculate total cells needed accounting for action expansion
      total_cells_needed = window.sum(&.cells_needed)
      comic = @book_type.comic?

      best_page : Page? = nil
      best_score = Int32::MIN

      # Try layout sizes from exact fit down to 1, then up to 6
      candidates = candidate_counts(total_cells_needed)

      candidates.each do |count|
        layouts = Catalog.for_count(count, comic: comic)
        layouts.each do |layout|
          page, score = try_layout(layout, window)
          if score > best_score
            best_score = score
            best_page = page
          end
        end
      end

      # Fallback: single image on full page
      if best_page.nil?
        layout = Catalog.for_count(1).first
        page = Page.new(layout)
        page.assign(0, window.first)
        best_page = page
      end

      best_page.not_nil!
    end

    private def candidate_counts(needed : Int32) : Array(Int32)
      # Try exact fit first, then nearby counts
      counts = [needed]
      (1..6).each do |c|
        counts << c unless counts.includes?(c)
      end
      counts.select { |c| c >= 1 && c <= 6 }
    end

    private def try_layout(layout : Layout, window : Array(ImageTag)) : Tuple(Page, Int32)
      page = Page.new(layout)
      score = 0
      cell_idx = 0
      img_idx = 0

      while cell_idx < layout.cell_count && img_idx < window.size
        tag = window[img_idx]
        cell = layout.cells[cell_idx]

        if tag.action? && tag.cells_needed > 1
          # Action images need consecutive cells in a row
          needed = tag.cells_needed
          if can_fit_action?(layout, cell_idx, needed)
            needed.times do |offset|
              page.assign(cell_idx + offset, tag)
            end
            cell_idx += needed
            img_idx += 1
            score += 10 + 3 # assigned + action bonus
            next
          else
            # Can't fit 3-cell action — downgrade to MotionLines (1 cell)
            tag.action_style = ActionStyle::MotionLines
          end
        end

        # Regular assignment
        page.assign(cell_idx, tag)
        score += 10 # tag assigned

        # Significance match scoring
        score += significance_score(tag, cell)

        # Vista bonus
        if tag.vista? && cell.landscape?
          score += 3
        end

        cell_idx += 1
        img_idx += 1
      end

      # Page fill bonus/penalty
      if page.full?
        score += 2
      else
        score -= 5 * page.empty_slots
      end

      {page, score}
    end

    private def significance_score(tag : ImageTag, cell : Cell) : Int32
      units = cell.units
      case tag.significance
      when .epic?
        # Epic wants 2-3 units
        if units >= 2 && units <= 3
          5
        elsif units == 4
          3
        else
          0
        end
      when .normal?
        # Normal wants 1 unit, can expand to 2
        if units == 1
          5
        elsif units == 2
          3
        else
          0
        end
      else
        0
      end
    end

    private def can_fit_action?(layout : Layout, start_idx : Int32, count : Int32) : Bool
      return false if start_idx + count > layout.cell_count

      # Check cells are in the same row
      first_row = layout.cells[start_idx].row
      count.times do |offset|
        cell = layout.cells[start_idx + offset]
        return false unless cell.row == first_row
        return false unless cell.units == 1
      end
      true
    end
  end
end
