
enum DishPreparationStatus {
  notStarted('Not Started', 0.0),
  preparing('Preparing', 0.33),
  almostReady('Almost Ready', 0.66),
  ready('Ready for Pickup', 1.0),
  pickedUp('Picked Up', 1.0);

  final String label;
  final double progress;
  const DishPreparationStatus(this.label, this.progress);
}
