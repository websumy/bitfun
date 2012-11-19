class Fun < ActiveRecord::Base
  attr_accessible :name, :string, :tag_names

  attr_writer :tag_names

  # Associations
  has_and_belongs_to_many :tags
  belongs_to :user

  # Validation
  validates :user_id, :presence => true
  validates :name, :presence => true

  # Callbacks
  before_save :save_tag_names

  def tag_names
    @tag_names ||= tags.pluck(:name).join(", ")
  end

  def save_tag_names
    if @tag_names
      self.tags = @tag_names.split(",").map {|name| Tag.where(name: name.strip).first_or_create if name.present?}.compact
    end
  end

end