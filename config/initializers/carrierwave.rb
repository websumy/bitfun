dir = Rails.root.join('lib', 'carrierwave/processing')
$LOAD_PATH.unshift(dir)
Dir[File.join(dir, "*.rb")].each {|file| require File.basename(file) }