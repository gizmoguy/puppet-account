class account(
  $users = {},
  $usergroups = {},
  $groups = {}
) {

  validate_hash($users)
  validate_hash($usergroups)
  validate_hash($groups)
  create_resources('account::user', $users)
  create_resources('account::group', $groups)
  create_resources('desired_groups', $usergroups)

}
