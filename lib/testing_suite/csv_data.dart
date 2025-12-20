import 'package:sorted_list/sorted_list.dart';

class CSVData {
  CSVData(this._headers, [List<List<String>>? rows]) : _rows = rows ?? List<List<String>>.empty(growable: true) {
    if (_headers.isEmpty) {
      throw ArgumentError("Headers cannot be empty");
    }
    if (_rows.any((row) => row.length != _headers.length)) {
      throw ArgumentError("All rows must have the same length as headers");
    }
  }

  final List<String> _headers;
  final List<List<String>> _rows;

  static CSVData alt(List<String> key, List<List<String>> data) {
    if (key.isEmpty) {
      throw ArgumentError("Key cannot be empty");
    }
    if (data.any((list) => list.length != key.length)) {
      throw ArgumentError("All rows must have the same length as key");
    }

    final List<String> headers = [key.first, ...data.map((d) => d.first)];
    final List<List<String>> rows = List<List<String>>.empty(growable: true);
    for (int i = 0; i < key.length; i++) {
      if (i == 0) {
        continue;
      }
      rows.add([key[i], ...data.map((d) => d[i])]);
    }

    return CSVData(headers, rows);
  }

  void addRow(List<String> row) {
    if (row.length != _headers.length) {
      throw ArgumentError("Row length ${row.length} does not match header length ${_headers.length}");
    }
    _rows.add(row);
  }

  CSVData copyWithHeaders([List<String> headers = const []]) => copyWithIndices(headers.map(_headers.indexOf).toSet());

  CSVData copyWithIndices([Set<int> indicesInput = const {}]) {
    final SortedList<int> indices = SortedList<int>()..addAll(indicesInput);

    // Check if indices are valid
    if (indices.isEmpty) {
      throw ArgumentError("Indices cannot be empty");
    }
    if (indices.any((index) => index < 0)) {
      throw ArgumentError("Indices must be non-negative");
    }
    if (indices.any((index) => index >= _headers.length)) {
      throw ArgumentError("Indices must be less than header length ${_headers.length}");
    }

    final List<String> headers = indices.map((index) => _headers[index]).toList();
    final List<List<String>> rows = _rows.map((row) => indices.map((index) => row[index]).toList()).toList();
    final CSVData result = CSVData(headers, rows);
    return result;
  }

  List<String> getColumnByName(String name) {
    final int index = _headers.indexOf(name);
    if (index == -1) {
      throw ArgumentError("Column name '$name' does not exist");
    }
    return getColumnByIndex(index);
  }

  List<String> getColumnByIndex(int index) {
    if (index < 0 || index >= _headers.length) {
      throw ArgumentError("Index $index is out of range");
    }
    return [_headers[index], ..._rows.map((row) => row[index]).toList()];
  }

  @override
  String toString([String delimiter = ","]) =>
      [_headers.join(delimiter), _rows.map((row) => row.join(delimiter)).join("\n")].join("\n");
}
