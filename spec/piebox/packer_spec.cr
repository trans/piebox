require "../spec_helper"

describe Piebox::Packer do
  describe "#pack" do
    it "puts a climax image on its own page" do
      packer = Piebox::Packer.new(Piebox::BookType::Comic)
      images = [
        Piebox::ImageTag.new("climax.png", significance: Piebox::Significance::Climax),
      ]
      pages = packer.pack(images)
      pages.size.should eq(1)
      pages[0].layout.cell_count.should eq(1)
      pages[0].assignments[0].not_nil!.path.should eq("climax.png")
    end

    it "groups normal images together" do
      packer = Piebox::Packer.new(Piebox::BookType::PictureBook)
      images = (1..4).map do |i|
        Piebox::ImageTag.new("img#{i}.png", significance: Piebox::Significance::Normal)
      end
      pages = packer.pack(images)
      # Should fit on 1 page
      pages.size.should eq(1)
      pages[0].assigned_count.should eq(4)
    end

    it "separates climax from normal images" do
      packer = Piebox::Packer.new(Piebox::BookType::Comic)
      images = [
        Piebox::ImageTag.new("normal1.png"),
        Piebox::ImageTag.new("normal2.png"),
        Piebox::ImageTag.new("climax.png", significance: Piebox::Significance::Climax),
        Piebox::ImageTag.new("normal3.png"),
      ]
      pages = packer.pack(images)
      pages.size.should be >= 2

      # The climax page should have exactly 1 cell
      climax_page = pages.find { |p| p.assignments.any? { |a| a.try(&.significance.climax?) } }
      climax_page.should_not be_nil
      climax_page.not_nil!.layout.cell_count.should eq(1)
    end

    it "handles epic images" do
      packer = Piebox::Packer.new(Piebox::BookType::PictureBook)
      images = [
        Piebox::ImageTag.new("epic1.png", significance: Piebox::Significance::Epic),
        Piebox::ImageTag.new("normal1.png"),
      ]
      pages = packer.pack(images)
      pages.size.should be >= 1
    end

    it "handles a single normal image" do
      packer = Piebox::Packer.new(Piebox::BookType::Comic)
      images = [Piebox::ImageTag.new("solo.png")]
      pages = packer.pack(images)
      pages.size.should eq(1)
      pages[0].assigned_count.should eq(1)
    end

    it "handles many images across multiple pages" do
      packer = Piebox::Packer.new(Piebox::BookType::PictureBook)
      images = (1..12).map do |i|
        Piebox::ImageTag.new("img#{i}.png")
      end
      pages = packer.pack(images)
      pages.size.should be >= 2
      total_assigned = pages.sum(&.assigned_count)
      total_assigned.should eq(12)
    end

    it "respects comic mode layout filtering" do
      packer = Piebox::Packer.new(Piebox::BookType::Comic)
      images = (1..6).map do |i|
        Piebox::ImageTag.new("img#{i}.png")
      end
      pages = packer.pack(images)
      pages.each do |page|
        page.layout.comic_compatible.should be_true
      end
    end
  end
end
