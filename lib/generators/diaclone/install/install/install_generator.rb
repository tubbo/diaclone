class InstallGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer_and_show_caveats
    initializer "diaclone.rb" do
      Rails.application.config.middleware.merge \
        "my-identifier" => [  ] # place your middleware in the array
      end
    end
    readme 'CAVEATS'
  end
end
