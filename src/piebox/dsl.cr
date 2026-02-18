module Piebox
  def self.build(output_path : String = "output.pdf", &)
    builder = DSL.new
    with builder yield
    builder.render(output_path)
  end

  class DSL
    @title : String = "Untitled"
    @book_type : BookType = BookType::PictureBook
    @page_width : Float64 = 210.0
    @page_height : Float64 = 297.0
    @margin : Float64 = 10.0
    @gutter : Float64 = 5.0
    @images : Array(ImageTag) = [] of ImageTag
    @ai_client : AI::Client? = nil

    def title(value : String)
      @title = value
    end

    def book_type(value : BookType)
      @book_type = value
    end

    def book_type(value : Symbol)
      @book_type = case value
                   when :comic        then BookType::Comic
                   when :picture_book then BookType::PictureBook
                   else                    raise "Unknown book type: #{value}"
                   end
    end

    def page_size(width : Number, height : Number)
      @page_width = width.to_f
      @page_height = height.to_f
    end

    def margin(value : Number)
      @margin = value.to_f
    end

    def gutter(value : Number)
      @gutter = value.to_f
    end

    def ai(client : AI::Client)
      @ai_client = client
    end

    def image(path : String, significance : Symbol = :normal, *modifiers : Symbol, action : Symbol? = nil, caption : String? = nil, description : String? = nil)
      sig = case significance
            when :climax then Significance::Climax
            when :epic   then Significance::Epic
            else              Significance::Normal
            end

      mods = Modifier::None
      modifiers.each do |m|
        case m
        when :vista  then mods |= Modifier::Vista
        when :action then mods |= Modifier::Action
        end
      end

      action_style = nil
      if action
        mods |= Modifier::Action
        action_style = case action
                       when :split3       then ActionStyle::Split3
                       when :zoom_in      then ActionStyle::ZoomIn
                       when :motion_lines then ActionStyle::MotionLines
                       else                    raise "Unknown action style: #{action}"
                       end
      end

      @images << ImageTag.new(
        path: path,
        significance: sig,
        modifiers: mods,
        action_style: action_style,
        caption: caption,
        description: description
      )
    end

    def render(output_path : String) : Array(Page)
      if client = @ai_client
        generator = AI::TextGenerator.new(client, @title)
        generator.generate_for(@images)
      end

      packer = Packer.new(@book_type)
      pages = packer.pack(@images)

      renderer = Renderer.new(
        page_width: @page_width,
        page_height: @page_height,
        margin: @margin,
        gutter: @gutter
      )
      renderer.render(pages, output_path)

      pages
    end
  end
end
