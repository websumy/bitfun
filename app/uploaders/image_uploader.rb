# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  include CarrierWave::SomeProcesses
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

  version :original do
    process :only_first_frame
    process convert: :jpg
    process :strip
    process resize_to_limit: [700, nil]
    process quality: 90
    def full_filename(f) md5_filename(f) end
  end

  version :full, if: :gif!, from_version: :original do
    process add_watermark: 700
    def full_filename(f) md5_filename(f) end
  end

  version :thumb, from_version: :original do
    process add_watermark: 500
    def full_filename(f) md5_filename(f) end
  end

  version :small, from_version: :original do
    process resize_to_limit: [218, nil]
    def full_filename(f) md5_filename(f) end
  end

   version :gif, if: :gif? do
    process add_watermark: 700
    def full_filename(f) md5_filename(f, 'gif') end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{secure_token(10)+File.extname(original_filename)}" if original_filename.present?
  end

  def gif?(new_file)
    new_file.content_type =~ /gif/
  end

  def gif!(new_file)
    ! gif?(new_file)
  end

  protected
  def md5_filename(for_file, extension = 'jpg')
    ext = File.extname(for_file)
    Digest::MD5.hexdigest([model.id.to_s, version_name, for_file.chomp(ext)].compact.join('_')) + '.' + extension
  end

  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

  def add_watermark(min_width)
    current_image = Magick::Image.read(current_path)
    processed_list = Magick::ImageList.new
    logo = Magick::Image.read("#{Rails.root}/app/assets/images/watermark.png").first

    frames = if current_image.size > 1
               coalesce_list = Magick::ImageList.new
               current_image.each do |frame|
                 coalesce_list << frame
               end
               coalesce_list.coalesce
             else
               current_image
             end

    frames.each do |frame|

      if frame.columns > min_width
        geometry = Magick::Geometry.new(min_width, nil, 0, 0, Magick::GreaterGeometry)
        frame = frame.change_geometry(geometry) do |new_width, new_height|
          frame.resize(new_width, new_height)
          end
      end

      filled = Magick::Image.new(frame.columns,frame.rows + 24) { self.background_color = 'white' }
      filled.composite!(frame, Magick::NorthWestGravity, Magick::OverCompositeOp)
      #destroy_image(frame)

        filled.composite!(logo, Magick::SouthEastGravity, 5, 3, Magick::OverCompositeOp)

        txt = Magick::Draw.new
        filled.annotate(txt, 0,0,5,3, 'bitfun.ru') do
          txt.gravity = Magick::SouthWestGravity
          txt.pointsize = 13
          txt.fill = '#979BA7'
          txt.font_weight = Magick::BoldWeight
        end
        processed_list << filled
    end

    processed_list.write(current_path)
  end

  def watermark
    manipulate! do |img|
      logo = Magick::Image.read("#{Rails.root}/app/assets/images/fun-watermark.png").first
      img.composite(logo, Magick::SouthEastGravity, 5, 5, Magick::OverCompositeOp)
    end
  end

end
