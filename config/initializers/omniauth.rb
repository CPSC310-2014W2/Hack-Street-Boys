OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '141435754076-rpp5fh3hb0k2feho5aqroi9n7k6nhe36.apps.googleusercontent.com', 'zZjdmOXje9U61iWWtQXvS8kt', 
  {client_options: 
    {ssl: 
      {ca_file: Rails.root.join("cacert.pem").to_s}
    },
    :prompt => "select_account"
  }

  provider :facebook, "1580886888863240", "ae3fb5bb852f674054d34fdb0801463f"
end