require 'yaml_inventory/inventory_item'

module YAMLInventory
  class Group < InventoryItem
    attr_accessor :hosts, :children, :parents

    def initialize(name)
      super
      @hosts = Set.new
      @children = Set.new
      @parents = Set.new
    end

    def get_hosts
      (@hosts + Set.new(@children.flat_map(&:get_hosts))).to_a
    end

    def add_host(host)
      @hosts << host
      host.add_group(self)
    end

    def add_subgroup(group)
      @children << group
      group.parents << self
    end

    def get_vars
      @parents.map(&:get_vars).reduce(Hash.new, :merge).merge(@vars)
    end

    def get_children
      (@children + Set.new(@children.flat_map(&:get_children))).to_a
    end
  end
end