require "../spec_helper"

describe Piebox::Catalog do
  describe "LAYOUTS" do
    it "has layouts" do
      Piebox::Catalog::LAYOUTS.size.should be > 0
    end

    it "every layout tiles the full 2x3 grid" do
      Piebox::Catalog::LAYOUTS.each do |layout|
        layout.valid?.should be_true, "Layout #{layout.id} is invalid"
      end
    end

    it "no layout has overlapping cells" do
      Piebox::Catalog::LAYOUTS.each do |layout|
        positions = Set(Tuple(Int32, Int32)).new
        layout.cells.each do |cell|
          cell.covered_positions.each do |pos|
            positions.includes?(pos).should be_false,
              "Layout #{layout.id} has overlapping cells at #{pos}"
            positions.add(pos)
          end
        end
      end
    end

    it "every layout covers exactly 6 units" do
      Piebox::Catalog::LAYOUTS.each do |layout|
        layout.total_units.should eq(6), "Layout #{layout.id} has #{layout.total_units} units"
      end
    end

    it "has layouts for cell counts 1 through 6" do
      (1..6).each do |count|
        layouts = Piebox::Catalog.for_count(count)
        layouts.size.should be > 0, "No layouts for count #{count}"
      end
    end
  end

  describe ".for_count" do
    it "returns only layouts with the specified cell count" do
      Piebox::Catalog.for_count(3).each do |layout|
        layout.cell_count.should eq(3)
      end
    end

    it "filters for comic compatibility" do
      comic_layouts = Piebox::Catalog.for_count(4, comic: true)
      comic_layouts.each do |layout|
        layout.comic_compatible.should be_true
      end
    end

    it "returns fewer or equal layouts for comic mode" do
      (1..6).each do |count|
        all = Piebox::Catalog.for_count(count)
        comic = Piebox::Catalog.for_count(count, comic: true)
        comic.size.should be <= all.size
      end
    end
  end
end
