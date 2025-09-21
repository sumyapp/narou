# frozen_string_literal: true

#
# Sinatra 4.x は Rackup::Handler を利用するが、rackup gem が未導入の場合
# 定義自体が存在せずに SystemExit を発生させてしまう。
# narou.rb はバンドル無しで実行されるケースが多いため、最低限の
# Rackup::Handler を補完して最新の Sinatra でもサーバ起動できるようにする。
#

begin
  require "rack/handler"
rescue LoadError
  # rack/handler は Sinatra の require で読み込まれる想定だが、もしまだ
  # ロードされていなくてもここで諦めず、Rackup::Handler が必要になった
  # タイミングで再度例外として表面化させる。
end

unless defined?(Rackup::Handler)
  module Rackup
    module Handler
      module_function

      DEFAULT_CANDIDATES = %i[puma webrick falcon].freeze

      def pick(server = nil)
        if server
          return Rack::Handler.get(server)
        end

        DEFAULT_CANDIDATES.each do |candidate|
          begin
            return Rack::Handler.get(candidate)
          rescue LoadError, NameError
            next
          end
        end

        Rack::Handler.get(:webrick)
      end
    end
  end
end

