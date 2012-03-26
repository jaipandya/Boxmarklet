class BoxUploader

  # Uploads file at given path to the specified user's box account
  # @param [String] path_to_file the location of the file to be uploaded to box
  # @param [String] folder_name name of the dir on box where this file is to be uploaded
  # @param [String] auth_token indentifies the user to whose account the file is
  #   to be uploaded
  # @param [String] api_key API key for the application using this uploader module
  # @todo Handle error conditions
  def self.upload_to_box(path_to_file, auth_token)
    account = Box::Account.new(BOX_API_KEY)
    folder_name = UPLOAD_FOLER_NAME
    return unless account.authorize(:auth_token => auth_token)
    
    upload_dir = account.root.find(:name => folder_name,
                                   :recursive => true)[0]
    unless upload_dir
      root_folder = account.folder(0)
      upload_dir = root_folder.create(folder_name)
    end

    api = Box::Api.new(BOX_API_KEY)
    api.set_auth_token(auth_token)
    api.upload(path_to_file, upload_dir.id)
  end

end
