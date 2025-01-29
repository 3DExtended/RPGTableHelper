bool emailValid(String email) => RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    .hasMatch(email);

bool usernameValid(String username, {List<String>? invalidUsernames}) {
  if (invalidUsernames != null && invalidUsernames.contains(username)) {
    return false;
  }

  return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username) &&
      username.length >= 3 &&
      username.length <= 13;
}

bool passwordValid(String password) =>
    password.length >= 8 && password.length <= 41;

bool resetCodeValid(String resetCode) =>
    RegExp(r'^\d{3}-?\d{3}$').hasMatch(resetCode);

bool joinCodeValid(String joinCode) =>
    RegExp(r'^\d{3}-?\d{3}$').hasMatch(joinCode);

bool lorePageTitleValid(String title) => title.length >= 3;
