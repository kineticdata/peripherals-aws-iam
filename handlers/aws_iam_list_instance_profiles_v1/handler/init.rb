require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class AwsIamListInstanceProfilesV1

  def initialize(input)
    # Set the input document attribute
    @input_document = REXML::Document.new(input)

    # Store the info values in a Hash of info names to values.
    @info_values = {}
    REXML::XPath.each(@input_document,"/handler/infos/info") { |item|
      @info_values[item.attributes['name']] = item.text
    }

    # Retrieve all of the handler parameters and store them in a hash attribute
    # named @parameters.
    @parameters = {}
    REXML::XPath.match(@input_document, 'handler/parameters/parameter').each do |node|
      @parameters[node.attribute('name').value] = node.text.to_s
    end

    @enable_debug_logging = @info_values['enable_debug_logging'].downcase == 'yes' ||
                            @info_values['enable_debug_logging'].downcase == 'true'
    puts "Parameters: #{@parameters.inspect}" if @enable_debug_logging

    # Retrieve the credentials for the AWS session from the input XML string
    creds = Aws::Credentials.new(@info_values['access_key'], @info_values['secret_key'])

    # Create a base AWS object. This object contains all the methods for accessing
    # Amazon Web Services
    @ec2 = Aws::IAM::Client.new(
      region: @info_values['region'],
      credentials: creds
    )

  end

  def execute()

    instance_profile_array=[]

    resp = @ec2.list_instance_profiles(
      path: @parameters['path'],
      max_items: 100
    )

    resp.instance_profiles.each { |instance_profile|
      instance_profile_array.push(instance_profile)
    }

    puts "Instance profiles returned. If results are truncated another call to return instance profiles will need to be made. #{resp.marker}" if @enable_debug_logging
    puts "truncated: #{resp.is_truncated} -- pagination marker: #{resp.is_truncated} " if @enable_debug_logging

    while resp.is_truncated==true do
      resp = @ec2.list_instance_profiles(
        path: @parameters['path'],
        marker: resp.marker
      )
      resp.instance_profiles.each { |instance_profile|
        instance_profile_array.push(instance_profile)
      }

      puts "Instance profiles returned. If results are truncated another call to return instance profiles will need to be made. #{resp.marker}" if @enable_debug_logging
      puts "truncated: #{resp.is_truncated} -- pagination marker: #{resp.is_truncated} " if @enable_debug_logging
    end

    puts "Instance Profile Array #{instance_profile_array} " if @enable_debug_logging

    ip_xml = "<instance_profiles>\n"
    instance_profile_array.each do |ip|
      ip_xml << "<instance_profile name='#{ip['instance_profile_name']}'>\n"
        ip_xml << "<path>" << ip['path'] << "</path>\n"
        ip_xml << "<instance_profile_name>" << ip['instance_profile_name'] << "</instance_profile_name>\n"
        ip_xml << "<instance_profile_id>" << ip['instance_profile_id'] << "</instance_profile_id>\n"
        ip_xml << "<arn>" << ip['arn'] << "</arn>\n"
        ip_xml << "<create_date>" << ip['create_date'].strftime("%Y-%m-%dT%e:%M:%S%z") << "</create_date>\n"
        ip_xml << "<roles>\n"
        ip['roles'].each do |role|
          ip_xml << "<role name='#{role['role_name']}'>\n"
            ip_xml << "<path>" << role['path'] << "</path>\n"
            ip_xml << "<role_name>" << role['role_name'] << "</role_name>\n"
            ip_xml << "<role_id>" << role['role_id'] << "</role_id>\n"
            ip_xml << "<arn>" << role['arn'] << "</arn>\n"
            ip_xml << "<create_date>" << role['create_date'].strftime("%Y-%m-%dT%e:%M:%S%z") << "</create_date>\n"
            ip_xml << "<assume_role_policy_document>" << role['assume_role_policy_document'] << "</assume_role_policy_document>\n"
          ip_xml << "</role>\n"
        end
        ip_xml << "</roles>\n"
      ip_xml << "</instance_profile>\n"
    end
    ip_xml << "</instance_profiles>"

    <<-RESULTS
    <results>
      <result name="Instance Profiles XML">#{escape(ip_xml)}</result>
    </results>
    RESULTS
  end

  # This is a template method that is used to escape results values (returned in
  # execute) that would cause the XML to be invalid.  This method is not
  # necessary if values do not contain character that have special meaning in
  # XML (&, ", <, and >), however it is a good practice to use it for all return
  # variable results in case the value could include one of those characters in
  # the future.  This method can be copied and reused between handlers.
  def escape(string)
    # Globally replace characters based on the ESCAPE_CHARACTERS constant
    string.to_s.gsub(/[&"><]/) { |special| ESCAPE_CHARACTERS[special] } if string
  end
  # This is a ruby constant that is used by the escape method
  ESCAPE_CHARACTERS = {'&'=>'&amp;', '>'=>'&gt;', '<'=>'&lt;', '"' => '&quot;'}
end
