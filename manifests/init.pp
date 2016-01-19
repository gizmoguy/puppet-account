class account(
  $users = {},
  $usergroups = {}
) {

  validate_hash($users)
  validate_hash($usergroups)
  create_resources('account::user', $users)
  create_resources('desired_groups', $usergroups)

}
