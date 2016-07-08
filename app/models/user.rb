class User < ActiveRecord::Base
	attr_accessor :remember_token
	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	
	# Validating the presence of a name attribute using presence: true
	validates :name,	presence: true,	length: {maximum: 50}
	
	before_save {email.downcase!}
	validates :email,	presence: true,	length: {maximum: 255},	
				format: {with: VALID_EMAIL_REGEX},
				uniqueness: {case_sensitive: false}			# Rails infers that uniqueness should be true as well

	# same as  -> validates(:name, presence: true)

	validates :password,	presence: true,	length: {minimum: 6}, allow_nil: true

	# Include a hashed password
	has_secure_password
	
	# This is a way to define class methods
	class << self
		# Returns the hash digest of the given string
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)
		end
		
		# Returns a random token
		def new_token
			SecureRandom.urlsafe_base64
		end
	end
	
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end
	
	# Returns true if the given token matches the digest
	def authenticated?(remember_token)
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end
	
	# Forgets a user
	def forget
		update_attribute(:remember_digest, nil)
	end
end
