module Piebox
  module AI
    class TextGenerator
      def initialize(@client : Client, @book_title : String = "")
      end

      def generate_for(images : Array(ImageTag))
        images.each do |tag|
          next unless tag.description || tag.caption
          tag.ai_text = generate_text(tag)
        end
      end

      private def generate_text(tag : ImageTag) : String
        context = String.build do |s|
          s << "You are writing short dialogue or narration for a comic/picture book"
          s << " titled \"#{@book_title}\"" unless @book_title.empty?
          s << ".\n\n"
          s << "Image description: #{tag.description}\n" if tag.description
          s << "Caption: #{tag.caption}\n" if tag.caption
          s << "Significance: #{tag.significance}\n"
          s << "\nWrite a brief, punchy line of dialogue or narration (1-2 sentences max) "
          s << "that would appear in a speech bubble or narration box for this scene. "
          s << "Keep it concise and dramatic. Return only the text, no quotes or labels."
        end

        @client.generate(context)
      rescue ex
        # If AI fails, fall back to caption or empty
        tag.caption || ""
      end
    end
  end
end
