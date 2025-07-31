import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_state.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class AlertManagementScreen extends StatefulWidget {
  const AlertManagementScreen({super.key});

  @override
  State<AlertManagementScreen> createState() => _AlertManagementScreenState();
}

class _AlertManagementScreenState extends State<AlertManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationModel> _alerts = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final authState = Provider.of<AuthState>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);
      final notificationService = NotificationService(apiService);
      final alerts = await notificationService.getNotifications();
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading alerts: $e')));
    }
  }

  List<NotificationModel> get _filteredAlerts {
    var filtered = _alerts;

    if (_selectedFilter != 'All') {
      filtered = filtered
          .where(
            (alert) => alert.type.toString().toLowerCase().contains(
              _selectedFilter.toLowerCase(),
            ),
          )
          .toList();
    }

    if (_selectedPriority != 'All') {
      filtered = filtered
          .where(
            (alert) =>
                _getPriority(alert).toLowerCase() ==
                _selectedPriority.toLowerCase(),
          )
          .toList();
    }

    return filtered;
  }

  String _getPriority(NotificationModel alert) {
    if (alert.message.toLowerCase().contains('critical') ||
        alert.message.toLowerCase().contains('urgent')) {
      return 'High';
    } else if (alert.message.toLowerCase().contains('moderate')) {
      return 'Medium';
    }
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Alert Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF91C788)),
            onPressed: _loadAlerts,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF91C788),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF91C788),
          tabs: const [
            Tab(text: 'Active Alerts'),
            Tab(text: 'Alert Rules'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveAlertsTab(),
          _buildAlertRulesTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveAlertsTab() {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredAlerts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAlerts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAlerts.length,
                    itemBuilder: (context, index) {
                      return _buildAlertCard(_filteredAlerts[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: ['All', 'Nutrition', 'Medical', 'Follow-up', 'Emergency']
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: ['All', 'High', 'Medium', 'Low']
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedPriority = value!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(NotificationModel alert) {
    final priority = _getPriority(alert);
    final priorityColor = priority == 'High'
        ? Colors.red
        : priority == 'Medium'
        ? Colors.orange
        : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, HH:mm').format(alert.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAlertDetails(alert),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF91C788)),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Color(0xFF91C788)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolveAlert(alert),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF91C788),
                    ),
                    child: const Text(
                      'Resolve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRulesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert Configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildRuleCard(
            'Nutrition Alerts',
            'Trigger when patient reports poor nutrition',
            Icons.restaurant,
            true,
          ),
          _buildRuleCard(
            'Missed Check-ins',
            'Alert when patient misses scheduled check-in',
            Icons.schedule,
            true,
          ),
          _buildRuleCard(
            'Critical Symptoms',
            'Immediate alert for emergency symptoms',
            Icons.warning,
            true,
          ),
          _buildRuleCard(
            'Follow-up Reminders',
            'Remind healthcare workers of pending follow-ups',
            Icons.notifications,
            false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showCreateRuleDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF91C788),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create New Rule',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(
    String title,
    String description,
    IconData icon,
    bool isActive,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF91C788)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title ${value ? 'enabled' : 'disabled'}'),
              ),
            );
          },
          activeColor: const Color(0xFF91C788),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final totalAlerts = _alerts.length;
    final highPriority = _alerts.where((a) => _getPriority(a) == 'High').length;
    final resolvedToday = _alerts
        .where((a) => a.createdAt.day == DateTime.now().day)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Alerts',
                  totalAlerts.toString(),
                  Icons.notifications,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'High Priority',
                  highPriority.toString(),
                  Icons.priority_high,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today',
                  resolvedToday.toString(),
                  Icons.today,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Response Time',
                  '12 min',
                  Icons.timer,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem(
                    'Alert resolved',
                    'Nutrition concern for Patient #123',
                    '2 min ago',
                  ),
                  _buildActivityItem(
                    'New alert',
                    'Missed check-in for Patient #456',
                    '15 min ago',
                  ),
                  _buildActivityItem(
                    'Rule updated',
                    'Modified follow-up reminder settings',
                    '1 hour ago',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String action, String description, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF91C788),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Active Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All alerts have been resolved or no new alerts available.',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAlertDetails(NotificationModel alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: ${_getPriority(alert)}'),
            const SizedBox(height: 8),
            Text(
              'Time: ${DateFormat('MMM dd, yyyy HH:mm').format(alert.createdAt)}',
            ),
            const SizedBox(height: 8),
            Text('Message: ${alert.message}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resolveAlert(alert);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91C788),
            ),
            child: const Text('Resolve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resolveAlert(NotificationModel alert) {
    setState(() {
      _alerts.remove(alert);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert resolved successfully')),
    );
  }

  void _showCreateRuleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Alert Rule'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Rule Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert rule created successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF91C788),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
