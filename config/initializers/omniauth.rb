OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '1032049289308-o2khg6258kaebnaarc7iuqtqm8cgce5s.apps.googleusercontent.com', 'MdcSbtDr5ukCbLPv8WxHHxwW', 
  {client_options: 
    {ssl: 
      {ca_file: Rails.root.join("cacert.pem").to_s}
    },
    :prompt => "select_account"
  }
end