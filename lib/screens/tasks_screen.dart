import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final allTasks = provider.allTasks.where((t) => t['active'] == true).toList();
          final tasks = _selectedFilter == 'all'
              ? allTasks
              : allTasks.where((t) => t['type'] == _selectedFilter).toList();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(AppLocalizations.of(context).all, 'all'),
                      SizedBox(width: 8),
                      _buildFilterChip(AppLocalizations.of(context).ads, 'ad'),
                      SizedBox(width: 8),
                      _buildFilterChip(AppLocalizations.of(context).surveys, 'survey'),
                      SizedBox(width: 8),
                      _buildFilterChip(AppLocalizations.of(context).download, 'download'),
                      SizedBox(width: 8),
                      _buildFilterChip(AppLocalizations.of(context).taskCategorySocial, 'social'),
                      SizedBox(width: 8),
                      _buildFilterChip(AppLocalizations.of(context).taskCategoryVisit, 'visit'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context).noTasks, style: TextStyle(color: AppColors.grey600)))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await provider.initialize();
                          setState(() {});
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return _buildTaskCard(tasks[index], provider);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, DemoProvider provider) {
    final taskId = task['id']?.toString() ?? '';
    final isCompleted = provider.isTaskCompleted(taskId);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isCompleted ? Colors.grey.withValues(alpha: 0.15) : null,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCompleted
                      ? Colors.grey.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.green, size: 24)
                      : Text(task['emoji'] ?? '📋', style: TextStyle(fontSize: 24)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isCompleted ? AppLocalizations.of(context).completed : (task['description'] ?? ''),
                        style: TextStyle(
                          fontSize: 14,
                          color: isCompleted ? Colors.green : AppColors.grey600,
                          fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.monetization_on, size: 16, color: isCompleted ? Colors.grey : Colors.green),
                SizedBox(width: 4),
                Text(
                  '${task['reward']} ITC',
                  style: TextStyle(color: isCompleted ? Colors.grey : Colors.green, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                if (isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(AppLocalizations.of(context).completed, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(task: task),
                        ),
                      );
                    },
                    icon: Icon(Icons.open_in_new, size: 16),
                    label: Text(AppLocalizations.of(context).startTask),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  XFile? _pickedFile;
  bool _isSubmitted = false;
  final _proofController = TextEditingController();

  @override
  void dispose() {
    _proofController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final url = task['url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).taskDetails),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitted
          ? _buildSuccessView()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['emoji'] ?? '📋',
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(height: 12),
                        Text(
                          task['title'] ?? '',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                            SizedBox(width: 6),
                            Text(
                              '${task['reward']} ${AppLocalizations.of(context).reward}',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context).taskDesc, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          task['description'] ?? AppLocalizations.of(context).noDescription,
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_list_numbered, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context).steps, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildStep('1', AppLocalizations.of(context).step1),
                        SizedBox(height: 8),
                        _buildStep('2', AppLocalizations.of(context).step2),
                        SizedBox(height: 8),
                        _buildStep('3', AppLocalizations.of(context).step3),
                        SizedBox(height: 8),
                        _buildStep('4', AppLocalizations.of(context).step4),
                        SizedBox(height: 8),
                        _buildStep('5', AppLocalizations.of(context).step5),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  if (url.isNotEmpty) ...[
                    Text(AppLocalizations.of(context).taskLink, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              url,
                              style: TextStyle(fontSize: 13, color: Colors.blue),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: AppColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: url));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context).linkCopied), backgroundColor: Colors.green),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(url);
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context).linkCopied), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
                            );
                          }
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: Icon(Icons.open_in_browser, color: Colors.white),
                        label: Text(AppLocalizations.of(context).openInBrowser, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  Text(AppLocalizations.of(context).uploadScreenshot, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() => _pickedFile = image);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _pickedFile != null ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _pickedFile != null ? Colors.green : Colors.grey.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _pickedFile != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 50),
                                SizedBox(height: 8),
                                Text(AppLocalizations.of(context).screenshotSelected, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                Text(AppLocalizations.of(context).tapToChange, style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey, size: 50),
                                SizedBox(height: 8),
                                Text(AppLocalizations.of(context).tapToSelect, style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _pickedFile == null
                          ? null
                          : () => _submitTask(context),
                      icon: Icon(Icons.send, color: Colors.white),
                      label: Text(
                        AppLocalizations.of(context).submitForReview,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pickedFile == null ? Colors.grey : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(number, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 14, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).taskSubmitted,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).taskReviewMsg,
              style: TextStyle(fontSize: 16, color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).backToTasks, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTask(BuildContext context) async {
    final taskId = widget.task['id']?.toString();
    if (taskId == null || taskId.isEmpty) return;
    if (_pickedFile == null) return;

    final provider = Provider.of<DemoProvider>(context, listen: false);
    try {
      await provider.submitTaskForReview(taskId, _pickedFile!.path, '');
      if (!mounted) return;
      setState(() => _isSubmitted = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).error), backgroundColor: Colors.red),
      );
    }
  }
}
