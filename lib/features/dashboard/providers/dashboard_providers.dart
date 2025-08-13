import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../clients/services/client_service.dart';

/// Provider to trigger dashboard refresh
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

/// Provider for client count
final clientCountProvider = FutureProvider<int>((ref) async {
  // Watch the refresh provider to trigger refetch
  ref.watch(dashboardRefreshProvider);
  return await ClientService.getClientCount();
});

/// Provider for new clients this week
final newClientsThisWeekProvider = FutureProvider<int>((ref) async {
  // Watch the refresh provider to trigger refetch
  ref.watch(dashboardRefreshProvider);
  return await ClientService.getNewClientsThisWeek();
});

/// Provider for dashboard stats
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  // Watch the refresh provider to trigger refetch
  ref.watch(dashboardRefreshProvider);
  
  final clientCount = await ClientService.getClientCount();
  final newThisWeek = await ClientService.getNewClientsThisWeek();
  
  return {
    'totalClients': clientCount,
    'newThisWeek': newThisWeek,
    'activePolicies': 0, // Placeholder for now
    'pendingClaims': 0, // Placeholder for now
    'totalRevenue': 0, // Placeholder for now
    'thisMonth': 0, // Placeholder for now
  };
});
