dirs = [
    %w'lib acts_as_votable',
    %w'lib carrierwave processing'
]

dirs.each do |folders|
  dir = Rails.root.join *folders
  $LOAD_PATH.unshift(dir)
  Dir[File.join(dir, '*.rb')].each {|file| require File.basename(file) }
end