class User < ApplicationRecord
  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.find_for_google_oauth2(auth)
    user = User.find_by(email: auth.info.email)
    unless user
      user = User.create(
        name: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        access_token: auth.credentials.token,
        password: Devise.friendly_token[0, 20]
      )
    end
    user.update!(access_token: auth.credentials.token) unless user.valid_access_token?
    return user
  end

  def valid_access_token?
    now = DateTime.now
    return now.to_i - created_at.to_i <= 3600 && now.to_i - updated_at.to_i <= 3600
  end
end
