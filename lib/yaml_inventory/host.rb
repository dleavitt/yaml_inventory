require 'yaml_inventory/inventory_item'

module YAMLInventory
  class Host < InventoryItem
    attr_accessor :groups

    def initialize(name)
      super
      @groups = Set.new
    end

    def add_group(group)
      @groups << group
    end
  end
end