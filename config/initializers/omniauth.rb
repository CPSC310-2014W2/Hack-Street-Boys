OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '141435754076-rpp5fh3hb0k2feho5aqroi9n7k6nhe36.apps.googleusercontent.com', 'zZjdmOXje9U61iWWtQXvS8kt', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end