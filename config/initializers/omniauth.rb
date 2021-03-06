Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
      Rails.application.credentials.youtube[:client_id_2],
      Rails.application.credentials.youtube[:client_secret_2],
      {
        scope: "https://www.googleapis.com/auth/userinfo.email,
                https://www.googleapis.com/auth/userinfo.profile,
                https://www.googleapis.com/auth/youtube",
        prompt: "select_account",
        access_type: "offline",
      }
  end