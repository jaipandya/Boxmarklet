require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'sinatra/jsonp'
require 'logger'
require './pdf-converter'
require './box-uploader'

BOX_API_KEY = settings.api_key
UPLOAD_FOLER_NAME = 'Web page PDFs'

# I exist!
get '/' do
  erb :index
end

# bookmarklet calls this function directly
#   Checks for presence of auth cookie first, if present the authenticates the auth_token inside
#   If cookie not present or auth_token is invalid, deletes the cookies
#   and returns the URL where the user can authenticate himself
#   If user is authorized, then creates a pdf version of the supplied URL
#   and uploads it to the respective account
get '/validate_and_save' do
  @authorized = false
  location = params[:url]
  title = params[:title]
  is_cookie_present = !cookies[:auth_token].nil? and !cookies[:auth_token].empty?
  if is_cookie_present
    @authorized = validate_auth_token(cookies[:auth_token])
  end
  unless @authorized and is_cookie_present
    cookies.delete(:auth_token)
  end
  if @authorized
    file_path = PDFConverter.convert_webpage_to_pdf(location, title)
    BoxUploader.upload_to_box(file_path, cookies[:auth_token])
    data = {:status => 'save_success', :message => 'Web page PDF has been successfully uploaded to your Box account.'}
  else
    data = {:status => 'unauthorized', :auth_url => box_auth_url, :message => 'The account is not authorized'}
  end
  jsonp data
end

# No called from the flow, but a handy function to generate auth url
get '/generate_auth_url' do
  '<a href="' + box_auth_url + '">Authenticate Yourself</a>'
end

# Callback URL after authorization by user
get '/authorization_callback' do
  if !params[:auth_token].nil? and !params[:auth_token].empty?
    if validate_auth_token(params[:auth_token])
      cookies[:auth_token] = params[:auth_token] 
      erb :authorization_callback
    else
      redirect box_auth_url
    end
  end
end

# Validates auth_token supplied by the user
def validate_auth_token(auth_token)
  account = Box::Account.new(BOX_API_KEY)
  account.authorize(:auth_token => auth_token)
end

# Generates authentication URL
# @todo Create for mobile
def box_auth_url
  account = Box::Account.new(BOX_API_KEY)
  ticket = account.ticket
  api = Box::Api.new(BOX_API_KEY)
  "#{ api.base_url }/auth/#{ ticket }"
end

helpers do
  def bookmarklet_link
    "javascript:(function(){if(window.boxmarklet!==undefined){boxmarklet();}else{document.body.appendChild(document.createElement('script')).src='https://boxmarklet.herokuapp.com/js/boxmarklet.js?r='+Math.random()*99999999;}})();"
  end
end