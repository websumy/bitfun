class Contact
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email, :message, :name

  validates :email, presence: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }
  validates :name, presence: true
  validates :message, presence: true, length: { maximum: 5000 }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    UserMailer.contact_us(self).deliver if self.valid?
  end

  def persisted?
    false
  end
end
