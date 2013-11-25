class account(
  $users = {}
) {

  validate_hash($users)
  create_resources('account::user', $users)

}
