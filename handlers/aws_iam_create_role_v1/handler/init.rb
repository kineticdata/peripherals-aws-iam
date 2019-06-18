require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class AwsIamCreateRoleV1

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
    @iam = Aws::IAM::Client.new(
      region: @info_values['region'],
      credentials: creds
    )

  end

  def execute()

    role_path = "/"
    if @parameters['path'].strip!=""
      role_path = @parameters['path']
    end

    resp = @iam.create_role(
      role_name: @parameters['role_name'],
      path: role_path,
      assume_role_policy_document: @parameters['assume_role_policy_document']
    )

    puts resp.role if @enable_debug_logging

    <<-RESULTS
    <results>
      <result name="Role Name">#{escape(resp.role.role_name)}</result>
      <result name="Role Id">#{escape(resp.role.role_id)}</result>
      <result name="Role ARN">#{escape(resp.role.arn)}</result>
      <result name="Role Path">#{escape(resp.role.path)}</result>
      <result name="Role Create Date">#{escape(resp.role.create_date)}</result>
      <result name="Role Assume Role Policy Document">#{escape(resp.role.assume_role_policy_document)}</result>
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
