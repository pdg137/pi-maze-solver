require 'spec_helper'

describe "GriddedMaze" do
  describe "#add_intersection" do
    let(:maze) { GriddedMaze.new }
    before do
      maze.add_node [0,0]
    end

    it "represents nodes as Point objects" do
      maze.nodes.to_a[0].is_a? Point
    end

    it "does nothing when adding an empty intersection" do
      maze.add_intersection(Point(0,0),[])
      expect(maze.connections[Point(0,0)]).to eq [].to_set
    end

    it "adds a connection when given some exits" do
      maze.add_intersection(Point(0,0),[Vector(1,0),Vector(0,1)])
      expect(maze.connections[Point(0,0)]).to eq [Point(1,0),Point(0,1)].to_set

      maze.add_intersection(Point(1,0),[Vector(1,0),Vector(0,1)])
      expect(maze.connections[Point(1,0)]).to eq [Point(0,0),Point(2,0),Point(1,1)].to_set

      expect(maze.nodes).to eq [[0,0],[1,0],[0,1],[1,1],[2,0]].map { |x| Point.new x }.to_set
    end

    it "adds multiple nodes when given a long vector" do
      maze.add_intersection(Point(0,0),[Vector(2,0)])
      expect(maze.nodes).to eq [[0,0],[1,0],[2,0]].map { |x| Point.new x }.to_set
    end

    it "does not duplicate nodes" do
      maze.add_intersection(Point(0,0),[Vector(0,2)])
      maze.add_intersection(Point(0,0),[Vector(0,1)])
      expect(maze.nodes).to eq [[0,0],[0,1],[0,2]].map { |x| Point.new x }.to_set
    end
  end

  context "simple gridded maze" do

    let(:maze) {
      GriddedMaze.from_s <<END
#-#-#
|   |
#-#-#
|
#-#
END
    }
    specify do
      expect(maze.get_path Point(0,0), Point(1,2)).to eq [[0,0],[0,1],[0,2],[1,2]].map { |x| Point.new x }
    end

    it "can solve a trivial path" do
      turning_path = maze.get_turning_path Vector(-1,0), Point(0,0), Point(0,0)
      expect(turning_path).to eq []
    end

    specify do
      turning_path = maze.get_turning_path Vector(-1,0), Point(1,0), Point(2,1)
      expect(turning_path).to eq [:straight, :right, :right, :none]
    end

    specify do
      turning_path = maze.get_turning_path Vector(0,1), Point(0,0), Point(1,2)
      expect(turning_path).to eq [:straight, :straight, :right]
    end

    specify do
      turning_path = maze.get_turning_path Vector(0,-1), Point(0,0), Point(1,2)
      expect(turning_path).to eq [:back, :straight, :right]
    end
  end

  context "more complicated maze" do
    let(:map) {
      <<END
#-#-#-#-# #
|   | |   |
#-# # #-# #
| | |   | |
# #-# X-#-#
END
    }
    let(:maze) { GriddedMaze.from_s map }

    specify do
      expect(maze.to_s).to eq map
    end

    specify do
      expect(maze.to_s(Point(1,1))).to eq <<END
#-#-#-#-# #
|   | |   |
#-@ # #-# #
| | |   | |
# #-# X-#-#
END
    end

    specify do
      turning_path = maze.get_turning_path Vector(0,1), Point(0,0), Point(5,2)
      expect(turning_path).to eq [:straight, :straight, :right, :none, :straight, :right, :left, :right, :left, :left, :none]
    end

    it "identifies the end" do
      expect(maze.end).to eq Point(3,0)
    end
  end

  context "maze with straightaways and zigzag options" do
    let(:maze) {
      GriddedMaze.from_s <<END
#-#-#-#
|   |
# #-#
| |
#-#-@
END
    }

    it "prefers straightaways" do
      turning_path = maze.get_turning_path Vector(-1,0), Point(2,0), Point(3,2)
      expect(turning_path).to eq [:straight, :straight, :right, :none, :right, :none, :straight]
    end
  end

  context "another maze with straightaway options" do
    let(:maze) {
      GriddedMaze.from_s <<END
  #-#
  | |
  # A-#-#
  |     |
@-#-#-#-#
END
    }

    it "prefers the straightaway to A" do
      turning_path = maze.get_turning_path Vector(1,0), Point(0,0), Point(2,1)
      expect(turning_path).to eq %i(straight straight none none left left none)
    end
  end

  context "much more complicated maze" do
    let(:maze) {
      GriddedMaze.from_s <<END
# # #-#-#-#-#
| | |       |
# # # #-# # #
| | | |   | |
# #-# # X-@ #
| | | |   | |
# # #-#-#-# #
| | | |     |
#-# # #     #
|   | |     |
#-#-#-#   ?-#
  | | |     |
#-# # #-#-#-#
END
    }

    it "finds the shortest path from @ to ?" do
      turning_path = maze.get_turning_path Vector(0,-1), Point(5,4), Point(5,1)
      expect(turning_path).to eq [:straight, :right, :none, :left, :none, :straight, :left, :none, :none, :left, :left]
    end
  end
end
