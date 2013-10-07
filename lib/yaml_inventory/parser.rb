require "yaml_inventory/group"
require "yaml_inventory/host"

module YAMLInventory
  class Parser
    def initialize(inventory, options = {})
      @options = options
      @groups, @hosts = parse_hosts(inventory)
    end

    def groups
      Hash[@groups.map { |g| [g.name, { 
        :hosts => g.get_hosts.map(&:name),
        :vars => g.get_vars,
        :children => g.get_children.map(&:name) }]}]
    end

    def host(host_name)
      vars = @hosts.get_hosts.find { |h| h.name == host_name }.get_vars
      if @options[:extra]
        k,v = @options[:extra].split("=")
        vars[k] = v
      end
      vars
    end

    private

    def find_group(name, groups)
      groups.find { |group| name == group.name }
    end

    def parse_hosts(inventory)
      groups = []

      all_hosts = Group.new('all')

      ungrouped = Group.new('ungrouped')
      groups = [ungrouped]

      children = []
      inventory.select { |entry| entry['group'] }.each do |entry|
        unless group = find_group(entry['group'], groups)
          group = Group.new(entry['group'])
          groups << group
        end

        group.add_vars(entry['vars']) if entry['vars']

        entry['hosts'] and entry['hosts'].each do |host_name|
          unless host = all_hosts.get_hosts.find { |h| h.name == host_name }
            host = Host.new(host_name)
            all_hosts.add_host(host)
          end

          group.add_host(host)
        end

        children += entry['groups'].map { |sub| [group.name, sub] } if entry['groups']
      end

      children.each do |name, sub_name|
        group = find_group(name, groups)
        subgroup = find_group(sub_name, groups)
        group.add_subgroup(subgroup)
      end

      bare_hosts, other_entries = inventory.partition { |entry| entry.is_a?(String) }

      bare_hosts.each do |host_name|
        unless host = all_hosts.get_hosts.find { |h| h.name == host_name }
          host = Host.new(host_name)
          all_hosts.add_host(host)
          ungrouped.add_host(host)
        end
      end

      other_entries.select { |e| e['host'] }.each do |entry|
        host_name = entry['host']
        no_group = false
        unless host = all_hosts.get_hosts.find { |h| h.name == host_name }
          host = Host.new(host_name)
          all_hosts.add_host(host)
          no_group = true
        end

        host.add_vars(entry['vars']) if entry['vars']

        if entry['groups']
          if group = groups.find { |g| entry['groups'].include? g.name }
            group.add_host(host)
            all_hosts.add_host(host)
            no_group = false
          end
        end

        ungrouped.add_host(host) if no_group
      end

      [groups, all_hosts]
    end
  end
end