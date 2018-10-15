require "fileutils"
require "shellwords"

def configure_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("design_template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/benpritchard/design_template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{design_template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def add_gems
  gem 'bootstrap', '~> 4.1', '>= 4.1.1'
  gem 'font-awesome-sass', '~> 5.0', '>= 5.0.13'
  gem 'jquery-rails', '~> 4.3.1'
  gem 'webpacker', '~> 3.5', '>= 3.5.3'
end

def set_application_name
  environment "config.application_name = Rails.application.class.parent_name"
end

def set_root
  route "root to: 'designs#index'"
  route "get 'designs/:name', to: 'designs#show'"
end

def add_bootstrap
  # Remove Application CSS
  run "rm app/assets/stylesheets/application.css"

  # Add Bootstrap JS
  insert_into_file(
    "app/assets/javascripts/application.js",
    "\n//= require jquery\n//= require popper\n//= require bootstrap",
    after: "//= require rails-ujs"
  )
end

def copy_templates
  directory "app", force: true
  directory "lib", force: true
end

def add_webpack
  rails_command 'webpacker:install'
end

def stop_spring
  run "spring stop"
end

# Main setup
configure_source_path

add_gems

after_bundle do
  set_application_name
  set_root
  stop_spring
  add_bootstrap
  add_webpack

  copy_templates

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
