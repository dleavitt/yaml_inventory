require "set"
require "yaml"

require "yaml_inventory/version"
require "yaml_inventory/parser"

module YAMLInventory
  def self.parse(inventory, host = nil, options = {})
    yi = YAMLInventory::Parser.new(inventory)
    host ? yi.host(host) : yi.groups
  end

  def self.parse_file(inventory_file, host = nil, options = {})
    YAMLInventory.parse(YAML.load_file(inventory_file), host, options)
  end
end
