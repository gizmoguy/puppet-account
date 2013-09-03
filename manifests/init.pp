class account(
  $users = []
) {
    create_resources('account::user', $users)
}
