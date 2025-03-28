class CSVData {
  CSVData(this._headers);

  final List<String> _headers;
  final List<List<String>> _rows = [];

  void addRow(List<String> row) => _rows.add(row);

  @override
  String toString() => [_headers.join(","), _rows.map((row) => row.join(",")).join("\n")].join("\n");
}
