class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult({
    required this.label,
    required this.confidence,
  });

  @override
  String toString() {
    return 'ClassificationResult(label: $label, confidence: $confidence)';
  }
}
