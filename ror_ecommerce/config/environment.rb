# Load the rails application
require File.expand_path('../application', __FILE__)

# Load custom config file for current environment
begin
  raw_config = File.read("config/config.yml")
  HADEAN_CONFIG = YAML.load(raw_config)[Rails.env]
  module GlobalConstants
    VAT_TAX_SYSTEM = HADEAN_CONFIG['vat']
  end
rescue  Exception => e
  puts "#{ e } (#{ e.class })!"
  raise "
  ############################################################################################
  ############################################################################################
    You need to setup the config.yml
    copy config.yml.example to config.yml

    Make sure you personalize the passwords in this file and for security never check this file in.
  ############################################################################################
  ############################################################################################
  "
end

CIM_LOGIN_ID = HADEAN_CONFIG['authnet']['login']
CIM_TRANSACTION_KEY = HADEAN_CONFIG['authnet']['password']

require File.expand_path('../../lib/printing/invoice_printer', __FILE__)

Paperclip.options[:command_path] = "/usr/local/bin"

# Initialize the rails application
Hadean::Application.initialize!