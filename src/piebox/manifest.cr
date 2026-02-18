require "yaml"

module Piebox
  # Converter that accepts both integer and float YAML scalars as Float64.
  module YAMLFloat
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node) : Float64
      unless node.is_a?(YAML::Nodes::Scalar)
        node.raise "Expected scalar for Float64"
      end
      node.value.to_f64
    end

    def self.to_yaml(value : Float64, yaml : YAML::Nodes::Builder)
      yaml.scalar(value.to_s)
    end
  end

  class Manifest
    include YAML::Serializable

    property book_type : String = "comic"
    property title : String = "Untitled"

    @[YAML::Field(converter: Piebox::YAMLFloat)]
    property page_width : Float64 = 210.0

    @[YAML::Field(converter: Piebox::YAMLFloat)]
    property page_height : Float64 = 297.0

    @[YAML::Field(converter: Piebox::YAMLFloat)]
    property margin : Float64 = 10.0

    @[YAML::Field(converter: Piebox::YAMLFloat)]
    property gutter : Float64 = 5.0

    property ai : AIConfig? = nil
    property images : Array(ImageEntry) = [] of ImageEntry

    def parsed_book_type : BookType
      case book_type.downcase
      when "comic"        then BookType::Comic
      when "picture_book" then BookType::PictureBook
      else                     BookType::PictureBook
      end
    end

    def to_image_tags : Array(ImageTag)
      images.map do |entry|
        modifiers = Modifier::None
        entry.modifiers.try do |mods|
          mods.each do |m|
            case m.downcase
            when "vista"  then modifiers |= Modifier::Vista
            when "action" then modifiers |= Modifier::Action
            end
          end
        end

        action_style = entry.action_style.try do |s|
          case s.downcase
          when "split3"       then ActionStyle::Split3
          when "zoom_in"      then ActionStyle::ZoomIn
          when "motion_lines" then ActionStyle::MotionLines
          else                     nil
          end
        end

        significance = case entry.significance.downcase
                       when "climax" then Significance::Climax
                       when "epic"   then Significance::Epic
                       else               Significance::Normal
                       end

        ImageTag.new(
          path: entry.path,
          significance: significance,
          modifiers: modifiers,
          action_style: action_style,
          caption: entry.caption,
          description: entry.description
        )
      end
    end
  end

  class AIConfig
    include YAML::Serializable

    property backend : String = "ollama"
    property model : String = "llama3"
    property api_key : String = ""
  end

  class ImageEntry
    include YAML::Serializable

    property path : String
    property significance : String = "normal"
    property modifiers : Array(String)? = nil
    property action_style : String? = nil
    property caption : String? = nil
    property description : String? = nil
  end
end
