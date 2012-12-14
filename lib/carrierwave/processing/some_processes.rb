module CarrierWave
  module SomeProcesses
    extend ActiveSupport::Concern

    module ClassMethods
      def strip
        process :strip
      end

      def only_first_frame
        process :only_first_frame
        end

      def quality(percentage)
        process :quality =>  percentage
      end
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

  end
end
