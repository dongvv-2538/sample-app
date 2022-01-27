class User < ApplicationRecord
    has_many    :microposts, dependent: :destroy
    # public accessor (same as getter/setter)
    attr_accessor   :remember_token, :activation_token, :reset_token
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    # email in database should be lowercase
    before_save :downcase_email 
    # create activation digest for user when created
    before_create   :create_activation_digest 

    validates   :name, presence: true, length: {maximum: 50} 
    validates   :email, presence: true, 
                        length: {maximum: 255}, 
                        format: {with: VALID_EMAIL_REGEX}, 
                        uniqueness: {case_sensitive: false}

    validates   :password, length: {minimum: 6}
    # save password into database in form of hashed digest
    has_secure_password

    # generate digest from a given string
    def User.digest(string) 
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # generate random token using SecureRandom.urlsafe_base64
    def User.generate_token 
        SecureRandom.urlsafe_base64
    end

    # add a remember digest to the database
    def remember 
        self.remember_token = User.generate_token
        update_attribute(:remember_digest, User.digest(self.remember_token))
    end

    # authenticate the given token with the expected attribute digest in the database
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # remove remember digest from user in the database
    def forget 
        update_attribute(:remember_digest, nil)
    end

    # lower case email
    def downcase_email
        self.email = email.downcase
    end

    # generate activation digest
    def create_activation_digest
        self.activation_token   =   User.generate_token
        self.activation_digest  =   User.digest(activation_token)
    end

    # update activation status 
    def activate 
        user.update_attribute(:activated, true)
        user.update_attribute(:activated_at, Time.zone.now)
    end

    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # generate a reset token and save to the database
    def create_reset_digest
        self.reset_token = User.generate_token
        self.update_attribute(:reset_digest, User.digest(self.reset_token))
        self.update_attribute(:reset_sent_at, Time.zone.now)
    end

    # send a reset password email to the user's email 
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # check expiration of the reset digest
    def password_reset_expired?
        self.reset_sent_at < 2.hours.ago 
    end

    # get all micropost of this user
    def feed
        Micropost.where("user_id=?", id)
    end
end
