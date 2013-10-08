# Ansible YAML Inventory

Ansible inventory script for defining inventory using YAML files. YAML is pretty! And readily parseable in a a variety of languages other than Python, unlike the default `.ini` files ansible uses.

It's adapated from the YAML inventory script which used to be part of ansible but isn't anymore.

## Installation

Install with

    $ gem install yaml_inventory

## Usage

Adds the `yaminv` command.

For help:

    $ yaminv --help

### With Ansible

Create a `hosts.yml` file in your current dir, and use it like this

    $ ansible-playbook -i $(which yaminv) playbook.yml

When run with ansible-playbook it will always pick up the hosts.yml file in the current directory.

### Hosts File Format

```yaml

# standalone hosts are okay
- standalonehost1
- standalonehost2

# host with vars
- host: hostwithvars
  vars:
    - var1: hostvar1
    - var2: hostvar2

# group with vars and hosts
- group: group2
  vars:
    - groupvar1: groupvar1
  hosts:
    - ghost1
    - ghost2
  groups:
    - group1

# subgroup
- group: group1
  hosts:
    - host3
    - hostwithvars
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Tests

Run with `rake test`
