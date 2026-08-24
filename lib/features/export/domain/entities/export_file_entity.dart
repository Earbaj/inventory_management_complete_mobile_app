/// Domain Entity representing exported CSV / PDF file data.
class ExportFileEntity {
  final String fileName;
  final String csvContent;
  final String fileType; // 'csv', 'pdf'
  final DateTime exportedAt;

  const ExportFileEntity({
    required this.fileName,
    required this.csvContent,
    this.fileType = 'csv',
    required this.exportedAt,
  });
}
