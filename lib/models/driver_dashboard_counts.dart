/// Simple counts for the driver dashboard cards.
class DriverDashboardCounts {
  final int pending;
  final int accepted;
  final int completedToday;

  const DriverDashboardCounts({
    required this.pending,
    required this.accepted,
    required this.completedToday,
  });
}
