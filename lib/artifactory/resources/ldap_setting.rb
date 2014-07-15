require 'rexml/document'

module Artifactory
  class Resource::LDAPSetting < Resource::Base
    class << self
      #
      # Get a list of all ldap settings in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::LDAPSetting>]
      #   the list of layouts
      #
      def all(options = {})
        config = Resource::System.configuration(options)
        list_from_config('config/security/ldapSettings/ldapSetting', config, options)
      end

      #
      # Find (fetch) an ldap setting by its name.
      #
      # @example Find an LDAPSetting by its name.
      #   ldap_config.find('ldap.example.com') #=> #<MailServer host: 'ldap.example.com' ...>
      #
      # @param [String] name
      #   the name of the ldap config setting to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::LDAPSetting, nil]
      #   an instance of the ldap setting that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        config = Resource::System.configuration(options)
        find_from_config("config/security/ldapSettings/ldapSetting/key[text()='#{name}']", config, options)
      rescue Error::HTTPError => e
        raise unless e.code == 404
        nil
      end

      private
      #
      # List all the child text elements in the Artifactory configuration file
      # of a node matching the specified xpath
      #
      # @param [String] xpath
      #   xpath expression for the parent element whose children are to be listed
      #
      # @param [REXML] config
      #   Artifactory config as an REXML file
      #
      # @param [Hash] options
      #   the list of options
      #
      def list_from_config(xpath, config, options = {})
        REXML::XPath.match(config, xpath).map do |r|
          hash = Util.xml_to_hash(r, 'search')
          from_hash(hash, options)
        end
      end

      #
      # Find all the sibling text elements in the Artifactory configuration file
      # of a node matching the specified xpath
      #
      # @param [String] xpath
      #   xpath expression for the element whose siblings are to be found
      #
      # @param [REXML] config
      #   Artifactory configuration file as an REXML doc
      #
      # @param [Hash] options
      #   the list of options
      #
      def find_from_config(xpath, config, options = {})
        name_node = REXML::XPath.match(config, xpath)
        return nil if name_node.empty?
        properties = Util.xml_to_hash(name_node[0].parent, 'search')
        from_hash(properties, options)
      end
    end

    # Ordered to match the artifactory xsd to make consuming the attributes
    # hash when writing artifactory xml more convenient.
    # http://bit.ly/UHMrHc
    attribute :key, ->{ raise 'name missing!' }
    attribute :enabled, true
    attribute :ldap_url
    attribute :search_filter
    attribute :search_base
    attribute :search_sub_tree
    attribute :manager_dn
    attribute :manager_password
    attribute :auto_create_user
    attribute :email_attribute, 'mail'
  end
end