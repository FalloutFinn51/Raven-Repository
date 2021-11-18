import 'package:flutter_raven/pages/login_page.dart';
import 'package:flutter_test/flutter_test.dart';

//Unit Testing
void main() {
  test("empty email returns error string", () {
    var result = EmailFieldValidator.validate('');
    expect(result, "Email Required");
  });

  test("non-empty email returns null", () {
    var result = EmailFieldValidator.validate('email');
    expect(result, null);
  });

  test("empty password returns error string", () {
    var result = PasswordFieldValidator.validate('');
    expect(result, "Password Required");
  });

  test("non-empty password returns null", () {
    var result = PasswordFieldValidator.validate('password');
    expect(result, null);
  });
}
