require "option_parser"

module Piebox
  class CLI
    @output : String = "output.pdf"
    @no_ai : Bool = false
    @manifest_path : String? = nil

    def run(args : Array(String))
      parse_options(args)

      manifest_path = @manifest_path
      unless manifest_path
        STDERR.puts "Error: No manifest file specified."
        STDERR.puts "Usage: piebox [options] <manifest.yml>"
        exit 1
      end

      unless File.exists?(manifest_path)
        STDERR.puts "Error: File not found: #{manifest_path}"
        exit 1
      end

      manifest = Manifest.from_yaml(File.read(manifest_path))
      images = manifest.to_image_tags

      if images.empty?
        STDERR.puts "Error: No images in manifest."
        exit 1
      end

      # AI text generation
      unless @no_ai
        if ai_config = manifest.ai
          client = build_ai_client(ai_config)
          if client
            puts "Generating AI text..."
            generator = AI::TextGenerator.new(client, manifest.title)
            generator.generate_for(images)
          end
        end
      end

      # Pack images into pages
      puts "Packing #{images.size} images..."
      packer = Packer.new(manifest.parsed_book_type)
      pages = packer.pack(images)
      puts "Created #{pages.size} pages."

      # Render PDF
      puts "Rendering PDF to #{@output}..."
      renderer = Renderer.new(manifest)
      renderer.render(pages, @output)
      puts "Done!"
    end

    private def parse_options(args : Array(String))
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: piebox [options] <manifest.yml>"

        parser.on("-o FILE", "--output FILE", "Output PDF path (default: output.pdf)") do |file|
          @output = file
        end

        parser.on("-n", "--no-ai", "Skip AI text generation") do
          @no_ai = true
        end

        parser.on("-v", "--version", "Show version") do
          puts "piebox #{VERSION}"
          exit 0
        end

        parser.on("-h", "--help", "Show help") do
          puts parser
          exit 0
        end

        parser.unknown_args do |positional, _|
          if path = positional.first?
            @manifest_path = path
          end
        end
      end
    end

    private def build_ai_client(config : AIConfig) : AI::Client?
      case config.backend.downcase
      when "ollama"
        AI::OllamaClient.new(model: config.model)
      when "anthropic"
        if config.api_key.empty?
          STDERR.puts "Warning: No API key for Anthropic, skipping AI."
          nil
        else
          AI::AnthropicClient.new(api_key: config.api_key, model: config.model)
        end
      else
        STDERR.puts "Warning: Unknown AI backend '#{config.backend}', skipping AI."
        nil
      end
    end
  end
end
