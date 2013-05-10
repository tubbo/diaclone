class TransformerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_templates
    template "implementation.rb.erb", "app/transformers/#{file_name}_transformer.rb"
    template "test.rb.erb", "spec/transformers/#{file_name}_transformer_spec.rb"
  end
end
