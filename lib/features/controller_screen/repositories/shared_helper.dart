import 'package:shared_preferences/shared_preferences.dart';

class SharedHelper {
  Future<void> setData(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("password", password);
  }

  Future<String?> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? check = prefs.getString('password');
    return check;
  }

  Future<void> setCheck(bool check) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("check", check);
  }

  Future<bool?> getCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool('check');
    return check;
  }

  Future<void> setProfile(
    String fullName,
    email,
    phone,
    address,
    langititude,
    longitude,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('full_name', fullName);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
    await prefs.setString('address', address);
    await prefs.setString('langititude', langititude);
    await prefs.setString('longitude', longitude);
  }

  Future<String?> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullName = prefs.getString('full_name');
    return fullName;
  }

  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    return email;
  }

  Future<String?> getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    return phone;
  }

  Future<String?> getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? address = prefs.getString('address');
    return address;
  }

  Future<void> setApi(String read, write, results) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('read', read);
    await prefs.setString('write', write);
    await prefs.setString('results', results);
  }

  Future<String?> getRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? read = prefs.getString('read');
    return read;
  }

  Future<String?> getWrite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? write = prefs.getString('write');
    return write;
  }

  Future<String?> getResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? results = prefs.getString('results');
    return results;
  }

  Future<void> setCheck1(bool check) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("check1", check);
  }

  Future<bool?> getCheck1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool('check1');
    return check;
  }

  Future<void> setMinutes(bool check) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("minutes", check);
  }

  Future<bool?> getMinutes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool('minutes');
    return check;
  }

  Future<String?> getLangititude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? write = prefs.getString('langititude');
    return write;
  }

  Future<String?> getLongitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? write = prefs.getString('longitude');
    return write;
  }

  Future<void> setSchedulare(bool check) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("scheduale", check);
  }

  Future<bool?> getScheduale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool('scheduale');
    return check;
  }

  Future<void> setToggle(bool check) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("toggle", check);
  }

  Future<bool?> getToggle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? check = prefs.getBool('toggle');
    return check;
  }
}
