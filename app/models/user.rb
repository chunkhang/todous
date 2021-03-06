class User < ApplicationRecord
  mount_uploader :image, PictureUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
#         :omniauthable, :omniauth_providers => [:facebook]
  has_many :tasks

  def done_for(date) 
    self.tasks.where("done_at >= ?", date)
  end

  def done_tasks
    tasks.where(completed: true)
  end

  def incompleted_tasks
    tasks.where(completed: false)
  end

  def done_tasks_count
    done_tasks.count 
  end

  def incompleted_tasks_count
    incompleted_tasks.count
  end

  # MARK: Authentication
  # Override
  def self.new_with_session(params, session) 

  	super.tap do |user|
  		if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
  			user.email = data["email"] if user.email.blank?
  		end
  	end

  end

  def self.from_omniauth(auth)
  	where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  		user.email = auth.info.email
  		user.password = Devise.friendly_token[0, 20] 
  		user.name = auth.info.name 
  		user.image = auth.info.image
  	end
  end
end
