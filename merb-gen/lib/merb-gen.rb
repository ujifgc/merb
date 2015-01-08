require 'merb-core'

require 'digest/sha1'

Kernel.send :alias_method, :old_instance_exec, :instance_exec
require 'templater'

if RUBY_VERSION >= '1.9.1'
  Kernel.send :alias_method, :instance_exec, :old_instance_exec
end

require 'merb-gen/templater'
require 'merb-gen/generator'
require 'merb-gen/named_generator'
require 'merb-gen/namespaced_generator'
require 'merb-gen/app_generator'

# TODO Look at how templater handles generators that don't reside
# in the toplevel rubygems 'namespace'

require File.expand_path('../generators/merb/merb_stack',     __FILE__)
require File.expand_path('../generators/merb/merb_core',      __FILE__)
require File.expand_path('../generators/merb/merb_flat',      __FILE__)
require File.expand_path('../generators/merb/merb_very_flat', __FILE__)
require File.expand_path('../generators/merb_plugin',         __FILE__)
require File.expand_path('../generators/controller',          __FILE__)
require File.expand_path('../generators/helper',              __FILE__)
require File.expand_path('../generators/part_controller',     __FILE__)
require File.expand_path('../generators/migration',           __FILE__)
require File.expand_path('../generators/session_migration',   __FILE__)
require File.expand_path('../generators/model',               __FILE__)
require File.expand_path('../generators/resource_controller', __FILE__)
require File.expand_path('../generators/resource',            __FILE__)
require File.expand_path('../generators/layout',              __FILE__)
require File.expand_path('../generators/passenger',           __FILE__)
require File.expand_path('../generators/fcgi',                __FILE__)

unless Gem.respond_to?(:cache)
  module Templater::Discovery
    def self.find_latest_gem_paths
      Gem.loaded_specs.values.map(&:full_gem_path)
    end
  end
end

Templater::Discovery.discover!('merb-gen')

Merb.generators.each do |file|
  require file
end
