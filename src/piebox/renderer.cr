require "cairo"

module Piebox
  class Renderer
    MM_TO_PT = 72.0 / 25.4 # 1mm ≈ 2.835pt

    getter page_width : Float64
    getter page_height : Float64
    getter margin : Float64
    getter gutter : Float64

    # Direct constructor with dimensions in mm.
    def initialize(@page_width = 210.0, @page_height = 297.0, @margin = 10.0, @gutter = 5.0)
    end

    # Convenience constructor from a Manifest.
    def self.new(manifest : Manifest)
      new(
        page_width: manifest.page_width,
        page_height: manifest.page_height,
        margin: manifest.margin,
        gutter: manifest.gutter
      )
    end

    def render(pages : Array(Page), output_path : String)
      width_pt = @page_width * MM_TO_PT
      height_pt = @page_height * MM_TO_PT

      surface = Cairo::PdfSurface.new(output_path, width_pt, height_pt)
      ctx = Cairo::Context.new(surface)

      pages.each_with_index do |page, page_idx|
        render_page(ctx, page, width_pt, height_pt)
        ctx.show_page unless page_idx == pages.size - 1
      end

      surface.finish
    end

    private def render_page(ctx : Cairo::Context, page : Page, width_pt : Float64, height_pt : Float64)
      margin = @margin * MM_TO_PT
      gutter = @gutter * MM_TO_PT

      # Usable area after margins
      usable_w = width_pt - 2 * margin
      usable_h = height_pt - 2 * margin

      # Cell dimensions (2 cols, 3 rows with gutters)
      cell_w = (usable_w - gutter) / GRID_COLS
      cell_h = (usable_h - 2 * gutter) / GRID_ROWS

      page.layout.cells.each_with_index do |cell, idx|
        image_tag = page.assignments[idx]?

        # Calculate cell rectangle
        x = margin + cell.col * (cell_w + gutter)
        y = margin + cell.row * (cell_h + gutter)
        w = cell.col_span * cell_w + (cell.col_span - 1) * gutter
        h = cell.row_span * cell_h + (cell.row_span - 1) * gutter

        # Draw cell border
        ctx.set_source_rgb(0.7, 0.7, 0.7)
        ctx.line_width = 0.5
        ctx.rectangle(x, y, w, h)
        ctx.stroke

        if tag = image_tag
          if tag.action? && tag.action_style
            render_action_cell(ctx, tag, x, y, w, h)
          else
            render_image_cell(ctx, tag, x, y, w, h)
          end

          # Render caption if present
          if caption = tag.caption
            render_caption(ctx, caption, x, y, w, h)
          end

          # Render AI text if present
          if ai_text = tag.ai_text
            render_speech_bubble(ctx, ai_text, x, y, w, h)
          end
        else
          # Empty cell — light fill
          ctx.set_source_rgb(0.95, 0.95, 0.95)
          ctx.rectangle(x, y, w, h)
          ctx.fill
        end
      end
    end

    private def render_image_cell(ctx : Cairo::Context, tag : ImageTag, x : Float64, y : Float64, w : Float64, h : Float64)
      return unless File.exists?(tag.path)

      img = Cairo::Surface.new(tag.path)
      img_w = img.width.to_f
      img_h = img.height.to_f

      # Letterbox: scale to fit, center
      scale_x = w / img_w
      scale_y = h / img_h
      scale = Math.min(scale_x, scale_y)

      scaled_w = img_w * scale
      scaled_h = img_h * scale
      offset_x = x + (w - scaled_w) / 2
      offset_y = y + (h - scaled_h) / 2

      ctx.save
      ctx.translate(offset_x, offset_y)
      ctx.scale(scale, scale)
      ctx.set_source_surface(img, 0, 0)
      ctx.paint
      ctx.restore
    end

    private def render_action_cell(ctx : Cairo::Context, tag : ImageTag, x : Float64, y : Float64, w : Float64, h : Float64)
      case tag.action_style
      when ActionStyle::Split3
        render_split3(ctx, tag, x, y, w, h)
      when ActionStyle::ZoomIn
        render_zoom_in(ctx, tag, x, y, w, h)
      when ActionStyle::MotionLines
        render_image_cell(ctx, tag, x, y, w, h)
        render_motion_lines(ctx, x, y, w, h)
      else
        render_image_cell(ctx, tag, x, y, w, h)
      end
    end

    private def render_split3(ctx : Cairo::Context, tag : ImageTag, x : Float64, y : Float64, w : Float64, h : Float64)
      return unless File.exists?(tag.path)

      img = Cairo::Surface.new(tag.path)
      img_w = img.width.to_f
      img_h = img.height.to_f
      pane_w = w / 3.0
      src_pane_w = img_w / 3.0

      3.times do |i|
        px = x + i * pane_w
        ctx.save
        ctx.rectangle(px, y, pane_w - 1, h)
        ctx.clip

        scale = h / img_h
        ctx.translate(px - i * src_pane_w * scale, y)
        ctx.scale(scale, scale)
        ctx.set_source_surface(img, 0, 0)
        ctx.paint
        ctx.restore
      end
    end

    private def render_zoom_in(ctx : Cairo::Context, tag : ImageTag, x : Float64, y : Float64, w : Float64, h : Float64)
      return unless File.exists?(tag.path)

      img = Cairo::Surface.new(tag.path)
      img_w = img.width.to_f
      img_h = img.height.to_f

      # Three progressive zoom levels
      pane_w = w / 3.0
      zooms = [1.0, 1.5, 2.5]

      zooms.each_with_index do |zoom, i|
        px = x + i * pane_w
        ctx.save
        ctx.rectangle(px, y, pane_w - 1, h)
        ctx.clip

        scale = (h / img_h) * zoom
        # Center the zoom on the middle of the image
        cx = img_w / 2.0 * scale
        cy = img_h / 2.0 * scale
        ctx.translate(px + pane_w / 2 - cx, y + h / 2 - cy)
        ctx.scale(scale, scale)
        ctx.set_source_surface(img, 0, 0)
        ctx.paint
        ctx.restore
      end
    end

    private def render_motion_lines(ctx : Cairo::Context, x : Float64, y : Float64, w : Float64, h : Float64)
      ctx.save
      ctx.set_source_rgba(0.0, 0.0, 0.0, 0.3)
      ctx.line_width = 1.5

      # Horizontal speed lines
      line_count = 8
      spacing = h / (line_count + 1)
      line_count.times do |i|
        ly = y + spacing * (i + 1) + (rand * 4 - 2)
        ctx.move_to(x + w * 0.1, ly)
        ctx.line_to(x + w * 0.9, ly)
        ctx.stroke
      end
      ctx.restore
    end

    private def render_caption(ctx : Cairo::Context, text : String, x : Float64, y : Float64, w : Float64, h : Float64)
      ctx.save
      font_size = 8.0
      ctx.font_size = font_size

      # Caption bar at bottom of cell
      bar_h = font_size + 6
      bar_y = y + h - bar_h

      ctx.set_source_rgba(1.0, 1.0, 1.0, 0.8)
      ctx.rectangle(x, bar_y, w, bar_h)
      ctx.fill

      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.move_to(x + 4, bar_y + font_size + 1)
      ctx.show_text(text)
      ctx.restore
    end

    private def render_speech_bubble(ctx : Cairo::Context, text : String, x : Float64, y : Float64, w : Float64, h : Float64)
      ctx.save
      font_size = 7.0
      ctx.font_size = font_size

      # Speech bubble in upper-right area of cell
      bubble_w = w * 0.5
      bubble_h = font_size * 3 + 8
      bx = x + w - bubble_w - 4
      by = y + 4

      # Bubble background
      ctx.set_source_rgba(1.0, 1.0, 1.0, 0.9)
      # Rounded rectangle approximation
      r = 4.0
      ctx.new_path
      ctx.arc(bx + r, by + r, r, Math::PI, 1.5 * Math::PI)
      ctx.arc(bx + bubble_w - r, by + r, r, 1.5 * Math::PI, 0.0)
      ctx.arc(bx + bubble_w - r, by + bubble_h - r, r, 0.0, 0.5 * Math::PI)
      ctx.arc(bx + r, by + bubble_h - r, r, 0.5 * Math::PI, Math::PI)
      ctx.close_path
      ctx.fill

      # Bubble border
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.line_width = 0.5
      ctx.new_path
      ctx.arc(bx + r, by + r, r, Math::PI, 1.5 * Math::PI)
      ctx.arc(bx + bubble_w - r, by + r, r, 1.5 * Math::PI, 0.0)
      ctx.arc(bx + bubble_w - r, by + bubble_h - r, r, 0.0, 0.5 * Math::PI)
      ctx.arc(bx + r, by + bubble_h - r, r, 0.5 * Math::PI, Math::PI)
      ctx.close_path
      ctx.stroke

      # Text (simple line wrapping)
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      words = text.split
      line = ""
      line_y = by + font_size + 4
      max_line_w = bubble_w - 8

      words.each do |word|
        test = line.empty? ? word : "#{line} #{word}"
        extents = ctx.text_extents(test)
        if extents.width > max_line_w && !line.empty?
          ctx.move_to(bx + 4, line_y)
          ctx.show_text(line)
          line = word
          line_y += font_size + 2
          break if line_y > by + bubble_h - 4
        else
          line = test
        end
      end

      unless line.empty?
        ctx.move_to(bx + 4, line_y)
        ctx.show_text(line)
      end

      ctx.restore
    end
  end
end
