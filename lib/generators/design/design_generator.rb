class DesignGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  argument :instructions, type: :string, default: ""

  def save_design
    create_json
    create_view
  end

  private

  def create_json
    initialize_json
    designs = JSON.parse(File.read(json_file))
    designs[design_name.parameterize.to_sym] = { name: design_name, instructions: instructions }
    write_json designs
  end

  def create_view
    location = "app/views/designs/#{design_name.parameterize}.html.erb"
    File.open(location, 'w') {|f| f.write("<h1>#{design_name}</h1>Find me at: <code>#{location}</code>") }
  end

  def design_name
    file_name
  end

  def json_file
    "designs.json"
  end

  def initialize_json
    write_json unless File.exists?(json_file)
  end

  def write_json(content={})
    File.open(json_file, 'w') {|f| f.write(content.to_json) }
  end
end
