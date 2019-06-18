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
    'role_name' => 'TEST_Role',
    'path' => '',
    'assume_role_policy_document' => "{" +
                                        "\"Version\": \"2012-10-17\"," +
                                        "\"Statement\": ["+
                                        "{"+
                                        "\"Sid\": \"\","+
                                        "\"Effect\": \"Allow\","+
                                        "\"Principal\": {"+
                                        "\"Service\": \"ec2.amazonaws.com\""+
                                        "},"+
                                        "\"Action\": \"sts:AssumeRole\""+
                                        "}"+
                                        "]"+
                                     "}"
  }
}
