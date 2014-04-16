class AwesomeNestedTree

  attr_reader :all, :root

  def initialize(all)
    @all = all
    @root = []
    @children = {}

    @all.map do |item|
      if item.parent_id
        @children[item.parent_id] ||= []
        @children[item.parent_id] << item
      else
        @root << item
      end
    end
  end

  def children?(id)
    @children.key? id
  end

  def children(id)
    @children[id]
  end
end