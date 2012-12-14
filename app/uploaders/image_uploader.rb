# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    sub_dir = model.id % 100 # 100 dirs for all images
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{sub_dir}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Create different versions of your uploaded files:

  version :img do
    process :only_first_frame
    process :convert => 'png'
    process :strip
    process :resize_to_limit => [700, nil]
    process :quality => 90

    version :thumb do
      process :resize_to_limit => [500, nil]
    end

    version :small do
      process :resize_to_limit => [300, nil]
    end
  end

  version :gif, if: :gif? do
    process :resize_to_limit => [500, nil]
    process :quality => 80

    def filename
      "#{secure_token(10)}.gif" if original_filename.present?
    end

    def full_filename(for_file)
      ext = File.extname(for_file)
      [version_name, for_file.chomp(ext)].compact.join('_') + '.gif'
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{secure_token(10)}.png" if original_filename.present?
  end

  # Strips out all embedded information from the image
  def strip
    manipulate! do |img|
      img.strip!
      img = yield(img) if block_given?
      img
    end
  end

  # get only first frame from gif images
  def only_first_frame
    manipulate! do |img|
      if img.mime_type.match /gif/
        if img.scene == 0
          img = img.cur_image #Magick::ImageList.new( img.base_filename )[0]
        else
          img = nil # avoid concat all frames
        end
      end
      img
    end
  end

  # Reduces the quality of the image to the percentage given
  def quality(percentage)
    manipulate! do |img|
      img.write(current_path){ self.quality = percentage }
      img = yield(img) if block_given?
      img
    end
  end

  def gif?(new_file)
    new_file.content_type =~ /gif/
  end

  protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

end
