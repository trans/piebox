module Piebox
  # An image entry with its tags, parsed from the manifest.
  class ImageTag
    property path : String
    property significance : Significance
    property modifiers : Modifier
    property action_style : ActionStyle?
    property caption : String?
    property description : String?
    property ai_text : String?

    def initialize(
      @path,
      @significance = Significance::Normal,
      @modifiers = Modifier::None,
      @action_style = nil,
      @caption = nil,
      @description = nil
    )
    end

    def vista? : Bool
      modifiers.vista?
    end

    def action? : Bool
      modifiers.action?
    end

    # How many grid cells this image needs when action-expanded.
    def cells_needed : Int32
      if action?
        case action_style
        when ActionStyle::Split3      then 3
        when ActionStyle::ZoomIn      then 3
        when ActionStyle::MotionLines then 1
        else                               1
        end
      else
        1
      end
    end
  end
end
