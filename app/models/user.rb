class User < ApplicationRecord
    attr_accessor   :remember_token, :activation_token, :reset_token
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    before_save :downcase_email 
    before_create   :create_activation_digest 

    validates   :name, presence: true, length: {maximum: 50} 
    validates   :email, presence: true, 
                        length: {maximum: 255}, 
                        format: {with: VALID_EMAIL_REGEX}, 
                        uniqueness: {case_sensitive: false}

    validates   :password, length: {minimum: 6}

    has_secure_password

    def User.digest(string) 
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

        BCrypt::Password.create(string, cost: cost)
    end

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

    def forget 
        update_attribute(:remember_digest, nil)
    end

    def downcase_email
        self.email = email.downcase
    end

    def create_activation_digest
        self.activation_token   =   User.generate_token
        self.activation_digest  =   User.digest(activation_token)
    end

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

    # send a reset email to the user's email 
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # check expiration of the reset digest
    def password_reset_expired?
        self.reset_sent_at < 2.hours.ago 
    end
end
