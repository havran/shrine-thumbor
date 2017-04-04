require "shrine"
require "down"

class Shrine
  module Storage
    class Thumbor
      def initialize
        @thumbor_base_url = 'https://img.uid.is'
        @thumbor_api      = "#{@thumbor_base_url}/image"
      end

      def upload(io, id, shrine_metadata: {}, **upload_options)
        # uploads `io` to the location `id`, can accept upload options
        slug      = shrine_metadata['filename']
        mime_type = shrine_metadata['mime_type']

        response = RestClient.post(
          @thumbor_api,
          io.read,
          {
            'Content-Type' => mime_type,
            'Slug' => slug
          }
        )

        id.replace(response.headers[:location])
        shrine_metadata.merge!({location: response.headers[:location]})
      end

      def url(id, **options)
        # returns URL to the remote file, accepts options for customizing the URL
        "#{@thumbor_base_url}#{id}"
      end

      def open(id)
        # returns the remote file as an IO-like object
        Down.open("#{@thumbor_base_url}#{id}")
      end

      def exists?(id)
        # checks if the file exists on the storage
      end

      def delete(id)
        # deletes the file from the storage
        RestClient.delete(url(id))
      end
    end
  end
end
