module YAMLInventory
  class InventoryItem
    
    attr_accessor :name, :vars

    def initialize(name)
      @name = name
      @vars = {}
    end

    def add_vars(vars)
      vars = vars.reduce(Hash.new, :merge) if vars.is_a?(Array)
      vars.each { |k,v| @vars[k] = v }
    end

    def get_vars
      all_vars = {}
      @groups.each do |group|
        group.get_vars.each do |k,v|
          all_vars[k] = v
        end
      end
      all_vars.merge(@vars)
    end
  end
end