require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class AwsIamCreatePolicyV1

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

    policy_path = "/"
    if @parameters['path'].strip!=""
      policy_path = @parameters['path']
    end

    resp = @iam.create_policy(
      policy_name: @parameters['policy_name'],
      path: policy_path,
      policy_document: @parameters['policy_document'],
      description: @parameters['description']
    )

    puts resp.policy if @enable_debug_logging

    <<-RESULTS
    <results>
      <result name="Policy Name">#{escape(resp.policy.policy_name)}</result>
      <result name="Policy ID">#{escape(resp.policy.policy_id)}</result>
      <result name="Policy ARN">#{escape(resp.policy.arn)}</result>
      <result name="Policy Path">#{escape(resp.policy.path)}</result>
      <result name="Policy Default Version ID">#{escape(resp.policy.default_version_id)}</result>
      <result name="Policy Attachment Count">#{escape(resp.policy.attachment_count.to_s)}</result>
      <result name="Policy Is Attachable">#{escape(resp.policy.is_attachable)}</result>
      <result name="Policy Description">#{escape(resp.policy.description)}</result>
      <result name="Policy Create Date">#{escape(resp.policy.create_date)}</result>
      <result name="Policy Update Date">#{escape(resp.policy.update_date)}</result>
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
