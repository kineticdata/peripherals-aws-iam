{
  'info' =>
  {
    'access_key' => '',
    'secret_key' => '',
    'region' => 'us-west-1',
    'enable_debug_logging' => 'Yes'
  },
  'parameters' =>
  {
    'policy_name' => 'TEST_Policy',
    'path' => '',
    'policy_document' => "{" + "\r\n" +
                           "\"Version\": \"2012-10-17\"," + "\r\n" +
                           "\"Statement\": [" + "\r\n" +
                           "{" + "\r\n" +
                           "\"Resource\": \"*\"," + "\r\n" +
                           "\"Action\": [" + "\r\n" +
                           "\"ec2:CreateRoute\"," + "\r\n" +
                           "\"ec2:Describe*\"," + "\r\n" +
                           "\"ec2:ReplaceRoute\"" + "\r\n" +
                           "]," + "\r\n" +
                           "\"Effect\": \"Allow\"" + "\r\n" +
                           "}" + "\r\n" +
                           "]" + "\r\n" +
                         "}",
    'description' => 'Allow NAT to change RTBs'
  }
}
