class Userrequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :request
end
