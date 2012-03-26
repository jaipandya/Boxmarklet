require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)

enable :logging
set :port, 80

configure(:production){ set :api_key, 'atx4vlr0bcv1um83jdyla092rrz2gfas' }
configure(:development){ set :api_key, 's2mprjcinm72gkk59xsaxfvoeb7njn7p' }

require './main'

run Sinatra::Application