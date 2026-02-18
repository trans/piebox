require "../spec_helper"

describe Piebox::Manifest do
  sample_yaml = <<-YAML
    book_type: comic
    title: "Test Comic"
    page_width: 210.0
    page_height: 297.0
    margin: 10.0
    gutter: 5.0
    images:
      - path: "img/cover.png"
        significance: climax
        caption: "The adventure begins"
      - path: "img/fight.png"
        significance: normal
        modifiers: [action]
        action_style: split3
        description: "Hero punches villain"
      - path: "img/vista.png"
        significance: epic
        modifiers: [vista]
    YAML

  it "parses YAML manifest" do
    manifest = Piebox::Manifest.from_yaml(sample_yaml)
    manifest.book_type.should eq("comic")
    manifest.title.should eq("Test Comic")
    manifest.images.size.should eq(3)
  end

  it "parses book type correctly" do
    manifest = Piebox::Manifest.from_yaml(sample_yaml)
    manifest.parsed_book_type.should eq(Piebox::BookType::Comic)
  end

  it "converts to image tags" do
    manifest = Piebox::Manifest.from_yaml(sample_yaml)
    tags = manifest.to_image_tags
    tags.size.should eq(3)

    tags[0].significance.should eq(Piebox::Significance::Climax)
    tags[0].caption.should eq("The adventure begins")

    tags[1].action?.should be_true
    tags[1].action_style.should eq(Piebox::ActionStyle::Split3)

    tags[2].vista?.should be_true
    tags[2].significance.should eq(Piebox::Significance::Epic)
  end

  it "handles AI config" do
    yaml_with_ai = <<-YAML
      book_type: comic
      title: "AI Comic"
      ai:
        backend: ollama
        model: llama3
      images:
        - path: "img/test.png"
          significance: normal
      YAML

    manifest = Piebox::Manifest.from_yaml(yaml_with_ai)
    manifest.ai.should_not be_nil
    manifest.ai.not_nil!.backend.should eq("ollama")
    manifest.ai.not_nil!.model.should eq("llama3")
  end

  it "accepts integer values for dimensions" do
    int_yaml = <<-YAML
      page_width: 210
      page_height: 297
      margin: 10
      gutter: 5
      images:
        - path: "img/test.png"
      YAML

    manifest = Piebox::Manifest.from_yaml(int_yaml)
    manifest.page_width.should eq(210.0)
    manifest.margin.should eq(10.0)
  end

  it "handles missing optional fields" do
    minimal_yaml = <<-YAML
      images:
        - path: "img/test.png"
      YAML

    manifest = Piebox::Manifest.from_yaml(minimal_yaml)
    manifest.title.should eq("Untitled")
    manifest.ai.should be_nil
    manifest.images.size.should eq(1)
  end
end
