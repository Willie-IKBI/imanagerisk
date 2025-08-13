import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final tokens = Theme.of(context).extension<IMRTokens>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F2F2F),
              Color(0xFF4A4A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header with User Info
              _buildModernHeader(context, ref, user, tokens, isMobile),
              
              // Main Content - Scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section with Key Metric
                      _buildHeroSection(context, ref, tokens, isMobile),
                      const SizedBox(height: 24),
                      
                      // Quick Actions Row
                      _buildQuickActionsRow(context, tokens, isMobile, isTablet),
                      const SizedBox(height: 24),
                      
                      // Stats Overview
                      _buildStatsOverview(context, ref, tokens, isMobile, isTablet),
                      const SizedBox(height: 24),
                      
                      // Main Content Grid
                      _buildMainContentGrid(context, ref, tokens, isMobile, isTablet),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, WidgetRef ref, user, tokens, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Row(
        children: [
          // User Avatar and Info
          Expanded(
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tokens.brandOrange,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      _getUserInitials(user),
                      style: TextStyle(
                        color: tokens.pureWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${_getUserName(user)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: tokens.pureWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.email ?? 'User',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.pureWhite.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Header Actions
          Row(
            children: [
              // Notifications (placeholder)
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_outlined, color: tokens.pureWhite),
              ),
              
              // Sign Out Button
              IMRButton(
                text: isMobile ? 'Sign Out' : 'Sign Out',
                type: IMRButtonType.secondary,
                onPressed: () async {
                  try {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/sign-in');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign out failed: ${e.toString()}'),
                          backgroundColor: tokens.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref, tokens, bool isMobile) {
    return GlassCard(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Row(
          children: [
            // Hero Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I Manage Risk',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: tokens.pureWhite,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your risk management dashboard',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: tokens.pureWhite.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Hero Metric
            Consumer(
              builder: (context, ref, child) {
                final statsAsync = ref.watch(dashboardStatsProvider);
                return statsAsync.when(
                  data: (stats) => _buildHeroMetric(context, stats['totalClients'] ?? 0, tokens),
                  loading: () => _buildHeroMetric(context, 0, tokens, isLoading: true),
                  error: (error, stack) => _buildHeroMetric(context, 0, tokens, hasError: true),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroMetric(BuildContext context, int value, tokens, {bool isLoading = false, bool hasError = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.brandOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.brandOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          if (isLoading)
            const CircularProgressIndicator(color: Color(0xFFF57C00))
          else if (hasError)
            Icon(Icons.error_outline, color: tokens.error, size: 32)
          else ...[
            Text(
              '$value',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: tokens.brandOrange,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Total Clients',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.pureWhite.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context, tokens, bool isMobile, bool isTablet) {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Add Client', 'route': '/add-existing-client'},
      {'icon': Icons.people, 'label': 'View Clients', 'route': '/clients'},
      {'icon': Icons.assessment, 'label': 'Reports', 'route': '/reports'},
      {'icon': Icons.settings, 'label': 'Settings', 'route': '/settings'},
    ];

    if (isMobile) {
      return Column(
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActionCard(context, action, tokens),
          )),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: actions.map((action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildActionCard(context, action, tokens),
              ),
            )).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action, tokens) {
    return GlassCard(
      child: InkWell(
        onTap: () => context.go(action['route']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                action['icon'],
                color: tokens.brandOrange,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                action['label'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.pureWhite,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, WidgetRef ref, tokens, bool isMobile, bool isTablet) {
    final stats = [
      {'key': 'activePolicies', 'label': 'Active Policies', 'icon': Icons.security},
      {'key': 'pendingClaims', 'label': 'Pending Claims', 'icon': Icons.pending_actions},
      {'key': 'totalRevenue', 'label': 'Total Revenue', 'icon': Icons.trending_up},
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.map((stat) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStatCard(context, ref, stat, tokens),
          )),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: stats.map((stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildStatCard(context, ref, stat, tokens),
              ),
            )).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(BuildContext context, WidgetRef ref, Map<String, dynamic> stat, tokens) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer(
          builder: (context, ref, child) {
            final statsAsync = ref.watch(dashboardStatsProvider);
            return statsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        stat['icon'],
                        color: tokens.brandOrange,
                        size: 24,
                      ),
                      const Spacer(),
                      _buildTrendIndicator(tokens),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${stats[stat['key']] ?? 0}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: tokens.pureWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['label'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.pureWhite.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Icon(Icons.error_outline, color: tokens.error),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            color: tokens.success,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '+12%',
            style: TextStyle(
              color: tokens.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentGrid(BuildContext context, WidgetRef ref, tokens, bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildRecentActivity(context, ref, tokens),
          const SizedBox(height: 24),
          _buildQuickInsights(context, ref, tokens),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildRecentActivity(context, ref, tokens),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildQuickInsights(context, ref, tokens),
          ),
        ],
      );
    }
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref, tokens) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: tokens.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
                         // Placeholder for recent activity items
             _buildActivityItem(context, tokens, 'New client added', 'John Doe', '2 hours ago'),
             _buildActivityItem(context, tokens, 'Policy updated', 'Business Policy #123', '4 hours ago'),
             _buildActivityItem(context, tokens, 'Claim submitted', 'Auto Claim #456', '1 day ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, tokens, String action, String details, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: tokens.brandOrange,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.pureWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  details,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.pureWhite.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.brandGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInsights(BuildContext context, WidgetRef ref, tokens) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: tokens.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
                         const SizedBox(height: 16),
             _buildInsightItem(context, tokens, 'Client Growth', '+15% this month'),
             _buildInsightItem(context, tokens, 'Policy Renewals', '8 due this week'),
             _buildInsightItem(context, tokens, 'Risk Score', 'Low risk profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, tokens, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.pureWhite.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: tokens.pureWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getUserInitials(user) {
    if (user?.userMetadata != null) {
      final firstName = user.userMetadata!['first_name'] ?? '';
      final lastName = user.userMetadata!['last_name'] ?? '';
      return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
    }
    return 'U';
  }

  String _getUserName(user) {
    if (user?.userMetadata != null) {
      final firstName = user.userMetadata!['first_name'] ?? '';
      final lastName = user.userMetadata!['last_name'] ?? '';
      return '${firstName.isNotEmpty ? firstName : ''} ${lastName.isNotEmpty ? lastName : ''}'.trim();
    }
    return 'User';
  }
}
