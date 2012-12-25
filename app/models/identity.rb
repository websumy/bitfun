class Identity < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user, :uid, :provider

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  class << self
    def find_with_omniauth(auth)
      find_by_provider_and_uid(auth.provider, auth.uid)
    end

    def create_with_omniauth(auth)
      create(uid: auth.uid, provider: auth.provider)
    end
  end
end