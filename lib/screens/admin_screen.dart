import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentTab = 0;
  bool _navigatedAway = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DemoProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    if (!provider.isAdmin && !_navigatedAway) {
      _navigatedAway = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<DemoProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          switch (_currentTab) {
            case 0:
              return _buildDashboard(provider);
            case 1:
              return _buildUsersTab(provider);
            case 2:
              return _buildTaskReviewsTab(provider);
            case 3:
              return _buildTasksTab(provider);
            case 4:
              return _buildSitesTab(provider);
            case 5:
              return _buildMarketTab(provider);
            case 6:
              return _buildBuySellTab(provider);
            case 7:
            default:
              return _buildDashboard(provider);
          }
        },
      ),
      bottomNavigationBar: Container(
        color: AppColors.surface,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        height: 60 + MediaQuery.of(context).padding.bottom,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 8),
          children: [
            _buildNavItem(0, Icons.dashboard, l10n.home),
            _buildNavItem(1, Icons.people, l10n.users),
            _buildNavItem(2, Icons.rate_review, l10n.reviews),
            _buildNavItem(3, Icons.task_alt, l10n.tasks),
            _buildNavItem(4, Icons.language, l10n.sites),
            _buildNavItem(5, Icons.store, l10n.market),
            _buildNavItem(6, Icons.swap_horiz, l10n.buySell),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(l10n.totalUsers, '${provider.totalUsers}', Icons.people, Colors.blue),
          SizedBox(height: 12),
          _buildStatCard('${l10n.totalIssued}', '${_formatNumber(provider.totalItcInCirculation)}', Icons.monetization_on, Colors.green),
          SizedBox(height: 12),
          _buildStatCard(l10n.yourBalance, '${_formatNumber(provider.user?.itcBalance ?? 0)} ITC', Icons.account_balance_wallet, Colors.purple),
          SizedBox(height: 12),
          _buildStatCard('Admin USD', '\$${provider.adminUsdBalance.toStringAsFixed(2)}', Icons.attach_money, Colors.amber),
          SizedBox(height: 24),
          Text(l10n.quickActions, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _buildQuickAction(l10n.addITC, Icons.add_circle, Colors.green, () => _showAddPointsDialog(context, provider)),
          SizedBox(height: 8),
          _buildQuickAction(l10n.deductITC, Icons.remove_circle, Colors.red, () => _showRemovePointsDialog(context, provider)),
          SizedBox(height: 8),
          _buildQuickAction(l10n.addTask, Icons.add_task, Colors.blue, () => _showAddTaskDialog(context, provider)),
          SizedBox(height: 8),
          _buildQuickAction(l10n.addSite, Icons.add_location, Colors.orange, () => _showAddSiteDialog(context, provider)),
          SizedBox(height: 8),
          _buildQuickAction(l10n.buySellItc, Icons.swap_horiz, Colors.teal, () => Navigator.pushNamed(context, '/buy_sell')),
          SizedBox(height: 8),
          _buildQuickAction(l10n.home, Icons.home, Colors.blueGrey, () => Navigator.pushReplacementNamed(context, '/home')),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
        title: Text(label),
        trailing: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) return '${(number / 1000000000).toStringAsFixed(1)}B';
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(2);
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey600),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.red.shade700 : AppColors.grey600, size: 22),
            SizedBox(height: 2),
            Text(label, style: TextStyle(
              color: isSelected ? Colors.red.shade700 : AppColors.grey600,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    if (provider.allUsers.isEmpty) {
      return Center(child: Text(l10n.noUsers));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.allUsers.length,
      itemBuilder: (context, index) {
        final u = provider.allUsers[index];
        final isAdmin = u['email'] == 'mitidjadido@gmail.com';
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAdmin ? Colors.red.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
              child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: isAdmin ? Colors.red : AppColors.primary),
            ),
            title: Text(u['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${u['email']}\n${u['itcBalance'] ?? 0} ITC'),
            isThreeLine: true,
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(value: 'add', child: Text(l10n.addITC)),
                PopupMenuItem(value: 'remove', child: Text(l10n.deductITC)),
                if (!isAdmin) PopupMenuItem(value: 'delete', child: Text(l10n.delete, style: TextStyle(color: Colors.red))),
              ],
              onSelected: (value) {
                if (value == 'add') _showAddPointsDialog(context, provider, prefillEmail: u['email']);
                if (value == 'remove') _showRemovePointsDialog(context, provider, prefillEmail: u['email']);
                if (value == 'delete') _confirmDeleteUser(context, provider, u['email']);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskReviewsTab(DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    final reviews = provider.pendingTaskReviews;
    if (reviews.isEmpty) {
      return Center(child: Text(l10n.noReviews));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final r = reviews[index];
        Color statusColor;
        String statusText;
        switch (r['status']) {
          case 'approved':
            statusColor = Colors.green;
            statusText = l10n.approved;
            break;
          case 'rejected':
            statusColor = Colors.red;
            statusText = l10n.rejected;
            break;
          default:
            statusColor = Colors.orange;
            statusText = l10n.pending;
        }

        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${r['userName']}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text('${r['userEmail']}', style: TextStyle(color: AppColors.grey600, fontSize: 12)),
                SizedBox(height: 4),
                Text('${l10n.taskTitle} ${r['taskTitle']}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('${r['reward']} ITC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    if (r['siteUrl'] != null && r['siteUrl'].toString().isNotEmpty) ...[
                      SizedBox(width: 12),
                      Text('${l10n.siteTitle} ${r['siteUrl']}', style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ],
                  ],
                ),
                if (r['status'] == 'pending') ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => provider.adminApproveTaskReview(r['id']),
                          child: Text(l10n.approve),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => provider.adminRejectTaskReview(r['id']),
                          child: Text(l10n.reject),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksTab(DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context, provider),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addTask),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.allTasks.length,
            itemBuilder: (context, index) {
              final task = provider.allTasks[index];
              final isActive = task['active'] ?? true;
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(task['emoji'] ?? '📋', style: TextStyle(fontSize: 24)),
                  title: Text(task['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${task['reward']} ITC - ${task['type']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => _showEditTaskDialog(context, provider, task),
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (_) => provider.adminToggleTask(task['id']),
                        activeColor: Colors.green,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => provider.adminRemoveTask(task['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSitesTab(DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddSiteDialog(context, provider),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addSite),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.allSites.length,
            itemBuilder: (context, index) {
              final site = provider.allSites[index];
              final isActive = site['active'] ?? true;
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.language, color: isActive ? AppColors.primary : AppColors.grey600),
                  title: Text(site['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${site['reward']} ITC - ${site['time']} ${l10n.seconds}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: isActive,
                        onChanged: (_) => provider.adminToggleSite(site['id']),
                        activeColor: Colors.green,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => provider.adminRemoveSite(site['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddPointsDialog(BuildContext context, DemoProvider provider, {String? prefillEmail}) {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController(text: prefillEmail ?? '');
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addITC),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: l10n.email), enabled: prefillEmail == null),
            SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.itc)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || amount > 999999999 || emailController.text.isEmpty) {
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              try {
                await provider.adminAddItcToUser(emailController.text.trim(), amount);
              } catch (e) {}
              if (!context.mounted) return;
              Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(content: Text('$amount ITC'), backgroundColor: Colors.green),
              );
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    ).then((_) {
      emailController.dispose();
      amountController.dispose();
    });
  }

  void _showRemovePointsDialog(BuildContext context, DemoProvider provider, {String? prefillEmail}) {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController(text: prefillEmail ?? '');
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deductITC),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: l10n.email), enabled: prefillEmail == null),
            SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.itc)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || amount > 999999999 || emailController.text.isEmpty) {
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              try {
                await provider.adminRemoveItcFromUser(emailController.text.trim(), amount);
              } catch (e) {}
              if (!context.mounted) return;
              Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(content: Text('$amount ITC'), backgroundColor: Colors.orange),
              );
            },
            child: Text(l10n.deductITC),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    ).then((_) {
      emailController.dispose();
      amountController.dispose();
    });
  }

  void _showAddTaskDialog(BuildContext context, DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final rewardController = TextEditingController();
    final urlController = TextEditingController();
    final timeController = TextEditingController(text: '15');
    String type = 'ad';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addTask),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  items: [
                    DropdownMenuItem(value: 'ad', child: Text(l10n.ads)),
                    DropdownMenuItem(value: 'survey', child: Text(l10n.surveys)),
                    DropdownMenuItem(value: 'download', child: Text(l10n.download)),
                    DropdownMenuItem(value: 'social', child: Text(l10n.taskCategorySocial)),
                    DropdownMenuItem(value: 'visit', child: Text(l10n.taskCategoryVisit)),
                  ],
                  onChanged: (v) => setDialogState(() => type = v ?? type),
                  decoration: InputDecoration(labelText: l10n.type),
                ),
                SizedBox(height: 12),
                TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.title)),
                SizedBox(height: 12),
                TextField(controller: descController, decoration: InputDecoration(labelText: l10n.description)),
                SizedBox(height: 12),
                TextField(controller: urlController, decoration: InputDecoration(labelText: l10n.link, hintText: 'https://...')),
                SizedBox(height: 12),
                TextField(controller: timeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.waitTime)),
                SizedBox(height: 12),
                TextField(controller: rewardController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${l10n.reward} (ITC)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                final reward = int.tryParse(rewardController.text) ?? 0;
                final time = int.tryParse(timeController.text) ?? 15;
                if (titleController.text.isNotEmpty && reward > 0) {
                  final emojis = {'ad': '📺', 'survey': '📝', 'download': '📱', 'social': '👥', 'visit': '🌐'};
                  try {
                    await provider.adminAddTask({
                      'type': type,
                      'title': titleController.text,
                      'description': descController.text,
                      'reward': reward,
                      'emoji': emojis[type] ?? '📋',
                      'url': urlController.text,
                      'time': time,
                    });
                  } catch (e) {}
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    ).then((_) {
      titleController.dispose();
      descController.dispose();
      rewardController.dispose();
      urlController.dispose();
      timeController.dispose();
    });
  }

  void _showEditTaskDialog(BuildContext context, DemoProvider provider, Map<String, dynamic> task) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController(text: task['title'] ?? '');
    final descController = TextEditingController(text: task['description'] ?? '');
    final rewardController = TextEditingController(text: '${task['reward'] ?? 0}');
    final urlController = TextEditingController(text: task['url'] ?? '');
    final timeController = TextEditingController(text: '${task['time'] ?? 15}');
    String type = task['type'] ?? 'ad';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${l10n.edit} ${l10n.taskTitle}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  items: [
                    DropdownMenuItem(value: 'ad', child: Text(l10n.ads)),
                    DropdownMenuItem(value: 'survey', child: Text(l10n.surveys)),
                    DropdownMenuItem(value: 'download', child: Text(l10n.download)),
                    DropdownMenuItem(value: 'social', child: Text(l10n.taskCategorySocial)),
                    DropdownMenuItem(value: 'visit', child: Text(l10n.taskCategoryVisit)),
                  ],
                  onChanged: (v) => setDialogState(() => type = v ?? type),
                  decoration: InputDecoration(labelText: l10n.type),
                ),
                SizedBox(height: 12),
                TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.title)),
                SizedBox(height: 12),
                TextField(controller: descController, decoration: InputDecoration(labelText: l10n.description)),
                SizedBox(height: 12),
                TextField(controller: urlController, decoration: InputDecoration(labelText: l10n.link, hintText: 'https://...')),
                SizedBox(height: 12),
                TextField(controller: timeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.waitTime)),
                SizedBox(height: 12),
                TextField(controller: rewardController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${l10n.reward} (ITC)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                final reward = int.tryParse(rewardController.text) ?? 0;
                final time = int.tryParse(timeController.text) ?? 15;
                if (titleController.text.isNotEmpty && reward > 0) {
                  final emojis = {'ad': '📺', 'survey': '📝', 'download': '📱', 'social': '👥', 'visit': '🌐'};
                  try {
                    await provider.adminUpdateTask(task['id'], {
                      'type': type,
                      'title': titleController.text,
                      'description': descController.text,
                      'reward': reward,
                      'emoji': emojis[type] ?? '📋',
                      'url': urlController.text,
                      'time': time,
                    });
                  } catch (e) {}
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    ).then((_) {
      titleController.dispose();
      descController.dispose();
      rewardController.dispose();
      urlController.dispose();
      timeController.dispose();
    });
  }

  void _showAddSiteDialog(BuildContext context, DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final rewardController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSite),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.siteName)),
              SizedBox(height: 12),
              TextField(controller: urlController, decoration: InputDecoration(labelText: l10n.url)),
              SizedBox(height: 12),
              TextField(controller: rewardController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${l10n.reward} (ITC)')),
              SizedBox(height: 12),
              TextField(controller: timeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.time)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final reward = int.tryParse(rewardController.text) ?? 0;
              final time = int.tryParse(timeController.text) ?? 10;
              if (titleController.text.isNotEmpty && reward > 0) {
                try {
                  await provider.adminAddSite({
                    'title': titleController.text,
                    'url': urlController.text,
                    'reward': reward,
                    'time': time,
                  });
                } catch (e) {}
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      urlController.dispose();
      rewardController.dispose();
      timeController.dispose();
    });
  }

  void _confirmDeleteUser(BuildContext context, DemoProvider provider, String email) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmUser),
        content: Text(l10n.deleteUserWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              provider.adminDeleteUser(email);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab(DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    final animals = provider.allAnimals;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.manageStore, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddAnimalDialog(context, provider),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(l10n.addAnimal, style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
        Expanded(
          child: animals.isEmpty
              ? Center(child: Text(l10n.noAnimals, style: TextStyle(color: AppColors.grey600)))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    final isActive = animal['active'] == true;
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(animal['emoji'] ?? '🐔', style: TextStyle(fontSize: 32)),
                        title: Row(
                          children: [
                            Text(animal['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isActive ? l10n.completed : l10n.inactive,
                                style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${animal['price']} ITC | ${animal['dailyProfit']} ITC',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => _showEditAnimalDialog(context, provider, animal),
                            ),
                            IconButton(
                              icon: Icon(
                                isActive ? Icons.pause : Icons.play_arrow,
                                color: isActive ? Colors.orange : Colors.green,
                                size: 20,
                              ),
                              onPressed: () => provider.adminToggleAnimal(animal['id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _showDeleteAnimalDialog(context, provider, animal),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddAnimalDialog(BuildContext context, DemoProvider provider) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final profitController = TextEditingController();
    final emojiController = TextEditingController(text: '🐔');
    String type = 'chicken';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addAnimal),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  items: [
                    DropdownMenuItem(value: 'chicken', child: Text(l10n.chicken)),
                    DropdownMenuItem(value: 'cow', child: Text(l10n.cow)),
                    DropdownMenuItem(value: 'dog', child: Text(l10n.dog)),
                    DropdownMenuItem(value: 'horse', child: Text(l10n.horse)),
                    DropdownMenuItem(value: 'elephant', child: Text(l10n.elephant)),
                    DropdownMenuItem(value: 'dragon', child: Text(l10n.dragon)),
                  ],
                  onChanged: (v) => setDialogState(() => type = v ?? type),
                  decoration: InputDecoration(labelText: l10n.type),
                ),
                SizedBox(height: 12),
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
                SizedBox(height: 12),
                TextField(controller: emojiController, decoration: InputDecoration(labelText: l10n.emoji)),
                SizedBox(height: 12),
                TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${l10n.reward} (ITC)')),
                SizedBox(height: 12),
                TextField(controller: profitController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.dailyITC)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) return;
                try {
                  await provider.adminAddAnimal({
                    'type': type,
                    'name': nameController.text,
                    'emoji': emojiController.text,
                    'price': int.tryParse(priceController.text) ?? 50,
                    'dailyProfit': int.tryParse(profitController.text) ?? 1,
                  });
                } catch (e) {}
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l10n.add),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    ).then((_) {
      nameController.dispose();
      priceController.dispose();
      profitController.dispose();
      emojiController.dispose();
    });
  }

  void _showEditAnimalDialog(BuildContext context, DemoProvider provider, Map<String, dynamic> animal) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: animal['name'] ?? '');
    final priceController = TextEditingController(text: '${animal['price'] ?? 50}');
    final profitController = TextEditingController(text: '${animal['dailyProfit'] ?? 1}');
    final emojiController = TextEditingController(text: animal['emoji'] ?? '🐔');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.edit} ${animal['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
              SizedBox(height: 12),
              TextField(controller: emojiController, decoration: InputDecoration(labelText: l10n.emoji)),
              SizedBox(height: 12),
              TextField(controller: priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: '${l10n.reward} (ITC)')),
              SizedBox(height: 12),
              TextField(controller: profitController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.dailyITC)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.adminUpdateAnimal(animal['id'], {
                  'name': nameController.text,
                  'emoji': emojiController.text,
                  'price': int.tryParse(priceController.text) ?? animal['price'],
                  'dailyProfit': int.tryParse(profitController.text) ?? animal['dailyProfit'],
                });
              } catch (e) {}
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text(l10n.save),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      priceController.dispose();
      profitController.dispose();
      emojiController.dispose();
    });
  }

  void _showDeleteAnimalDialog(BuildContext context, DemoProvider provider, Map<String, dynamic> animal) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteAnimalWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              provider.adminRemoveAnimal(animal['id']);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ─── BUY / SELL REQUESTS TAB ───
  // ═══════════════════════════════════════

  Widget _buildBuySellTab(DemoProvider provider) {
    final loc = AppLocalizations.of(context);
    final requests = provider.allBuySellRequests;
    final pending = requests.where((r) => r['status'] == 'pending').toList();

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, color: Colors.grey, size: 64),
            SizedBox(height: 16),
            Text(loc.noPendingRequests, style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final r = pending[index];
        final isBuy = r['type'] == 'buy';
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: AppColors.surface,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isBuy ? Icons.shopping_cart : Icons.sell, color: isBuy ? Colors.green : Colors.red, size: 28),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${isBuy ? loc.buyLabel : loc.sellLabel} ${r['amountItc']} ITC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          Text('\$${r['amountUsd']} | ${r['paymentMethod']}', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.white12),
                _buildInfoRow(loc.adminUser, '${r['userName'] ?? r['userEmail']}'),
                _buildInfoRow(loc.adminEmail, '${r['userEmail']}'),
                _buildInfoRow(loc.transactionId, '${r['txHash']}'),
                if (r['walletAddress'] != null && r['walletAddress'].isNotEmpty)
                  _buildInfoRow(loc.userWallet, '${r['walletAddress']}'),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text(loc.approve, style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          if (r['type'] == 'sell') {
                            final userIdx = provider.allUsers.indexWhere((u) => u['email'] == r['userEmail']);
                            if (userIdx != -1) {
                              final userBalance = provider.allUsers[userIdx]['itcBalance'] ?? 0.0;
                              final sellAmount = (r['amountItc'] ?? 0).toDouble();
                              if (userBalance < sellAmount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${loc.insufficientUserBalance} (${userBalance.toStringAsFixed(2)} ITC) - ${sellAmount.toStringAsFixed(2)} ITC'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                            }
                          }
                          try {
                            await provider.approveBuySellRequest(r['id']);
                          } catch (e) {}
                          if (!context.mounted) return;
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.close, color: Colors.white),
                        label: Text(loc.rejectAction, style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          try {
                            await provider.rejectBuySellRequest(r['id']);
                          } catch (e) {}
                          if (!context.mounted) return;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          Flexible(child: Text(value, style: TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
