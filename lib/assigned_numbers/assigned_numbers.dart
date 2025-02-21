import 'package:blue_crab/assigned_numbers/company_identifiers.dart' as ids;

class AssignedNumbers {
  Map<String, String> company_identifiers = ids.company_identifiers;

  AssignedNumbers() {
    company_identifiers.values.forEach((company) => print(company));
  }
}
