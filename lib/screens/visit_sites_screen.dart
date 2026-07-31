import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class VisitSitesScreen extends StatefulWidget {
  @override
  _VisitSitesScreenState createState() => _VisitSitesScreenState();
}

class _VisitSitesScreenState extends State<VisitSitesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final sites = provider.allSites.where((s) => s['active'] == true).toList();

          return sites.isEmpty
              ? Center(child: Text(AppLocalizations.of(context).noSites, style: TextStyle(color: AppColors.grey600)))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: sites.length,
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    final siteId = site['id']?.toString() ?? '';
                    final isVisited = provider.isSiteVisited(siteId);

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: isVisited ? Colors.grey.withValues(alpha: 0.15) : null,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isVisited
                                      ? Colors.grey.withValues(alpha: 0.2)
                                      : AppColors.primary.withValues(alpha: 0.1),
                                  child: isVisited
                                      ? Icon(Icons.check, color: Colors.green)
                                      : Icon(Icons.language, color: AppColors.primary),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        site['title'] ?? '',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: AppColors.grey600),
                                          SizedBox(width: 4),
                                          Text('${site['time']} ${AppLocalizations.of(context).seconds}', style: TextStyle(color: AppColors.grey600, fontSize: 13)),
                                          SizedBox(width: 12),
                                          Icon(Icons.monetization_on, size: 14, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text('${site['reward']} ITC', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: isVisited
                                  ? Container(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(AppLocalizations.of(context).visited, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SiteDetailScreen(site: site),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.open_in_new, size: 16),
                                      label: Text(AppLocalizations.of(context).visitSite),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class SiteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;
  const SiteDetailScreen({super.key, required this.site});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> with WidgetsBindingObserver {
  Timer? _timer;
  int _remainingSeconds = 30;
  int _totalVisitTime = 30;
  bool _isTimerRunning = false;
  bool _isFinished = false;
  bool _showCaptcha = false;
  String _captchaNumber = '';
  final TextEditingController _captchaController = TextEditingController();
  DateTime? _timerEndTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _timerEndTime != null) {
      _checkTimerFromBackground();
    }
  }

  void _checkTimerFromBackground() {
    if (_timerEndTime == null) return;
    final now = DateTime.now();
    if (now.isAfter(_timerEndTime!)) {
      _timer?.cancel();
      if (mounted && _isTimerRunning) {
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
          _showCaptcha = true;
          _timerEndTime = null;
          _generateCaptcha();
        });
      }
    }
  }

  void _startVisit() {
    final time = widget.site['time'] ?? 30;

    _timerEndTime = DateTime.now().add(Duration(seconds: time));

    setState(() {
      _remainingSeconds = time;
      _totalVisitTime = time;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final remaining = _timerEndTime!.difference(now).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
          _showCaptcha = true;
          _timerEndTime = null;
          _generateCaptcha();
        });
      } else {
        setState(() {
          _remainingSeconds = remaining;
        });
      }
    });
  }

  void _generateCaptcha() {
    final random = Random();
    final number = random.nextInt(900000) + 100000;
    _captchaNumber = number.toString();
    _captchaController.clear();
  }

  void _verifyCaptcha() async {
    if (_captchaController.text == _captchaNumber) {
      final provider = Provider.of<DemoProvider>(context, listen: false);
      final reward = widget.site['reward'] ?? 0;
      try {
        await provider.addItc(reward.toDouble(), '${AppLocalizations.of(context).visitSite}: ${widget.site['title']}');
        await provider.markSiteVisited(widget.site['id']?.toString() ?? '');
      } catch (e) {}
      if (!mounted) return;
      setState(() {
        _showCaptcha = false;
        _isFinished = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wrongNumber),
          backgroundColor: Colors.red,
        ),
      );
      _generateCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    final site = widget.site;
    final url = site['url'] ?? '';
    final reward = site['reward'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).visitSite),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _isFinished
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
                        Icon(Icons.language, color: Colors.white, size: 40),
                        SizedBox(height: 12),
                        Text(
                          site['title'] ?? '',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text('${site['time']} ${AppLocalizations.of(context).seconds}', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            SizedBox(width: 16),
                            Icon(Icons.monetization_on, color: Colors.yellow, size: 18),
                            SizedBox(width: 6),
                            Text('$reward ${AppLocalizations.of(context).reward}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                            Text(AppLocalizations.of(context).visitSteps, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildStep('1', AppLocalizations.of(context).visitStep1),
                        SizedBox(height: 8),
                        _buildStep('2', AppLocalizations.of(context).visitStep2),
                        SizedBox(height: 8),
                        _buildStep('3', AppLocalizations.of(context).visitStep3),
                        SizedBox(height: 8),
                        _buildStep('4', AppLocalizations.of(context).visitStep4),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  if (url.isNotEmpty) ...[
                    Text(AppLocalizations.of(context).siteLink, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isTimerRunning ? null : () async {
                          final uri = Uri.parse(url);
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${AppLocalizations.of(context).linkCopied} + ${AppLocalizations.of(context).openInBrowser}'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                            );
                          }
                          _startVisit();
                          if (await canLaunchUrl(uri)) {
                            launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: Icon(_isTimerRunning ? Icons.timer : Icons.open_in_browser, color: Colors.white),
                        label: Text(
                          _isTimerRunning ? '$_remainingSeconds ${AppLocalizations.of(context).remainingSeconds}' : AppLocalizations.of(context).openBrowserStartTimer,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTimerRunning ? AppColors.grey600 : Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  if (_isTimerRunning) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.timer, color: AppColors.primary, size: 40),
                          SizedBox(height: 12),
                          Text(AppLocalizations.of(context).countdown, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          SizedBox(height: 16),
                          Text(
                            '$_remainingSeconds',
                            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Text(AppLocalizations.of(context).seconds, style: TextStyle(fontSize: 16, color: AppColors.grey600)),
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _totalVisitTime > 0 ? 1 - (_remainingSeconds / _totalVisitTime) : 0,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          if (_showCaptcha)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: EdgeInsets.all(32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context).captchaTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context).captchaHint, style: TextStyle(fontSize: 18)),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: Text(
                              _captchaNumber,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 8,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _captchaController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, letterSpacing: 4),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: AppLocalizations.of(context).enterNumber,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showCaptcha = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(AppLocalizations.of(context).cancel),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _verifyCaptcha,
                                  child: Text(AppLocalizations.of(context).verify),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
    final reward = widget.site['reward'] ?? 0;
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
              AppLocalizations.of(context).success,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '${AppLocalizations.of(context).gotReward} $reward ITC 🎉',
              style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).backToSites, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
}
