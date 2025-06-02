import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mo_ai_agent/presentation/blocs/chat/chat_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../blocs/theme/theme_cubit.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Unknown';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          // Theme Settings
          _buildSectionHeader(context, 'Appearance'),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: state.isDarkMode,
                onChanged: (_) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: Text(_appVersion),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service'),
            onTap: () => _launchUrl(AppConstants.termsOfServiceUrl),
          ),
          const Divider(),

          // AI Model Settings
          _buildSectionHeader(context, 'AI Assistant'),
          ListTile(
            title: const Text('Model Information'),
            subtitle: const Text(AppConstants.modelInfo),
          ),
          ListTile(
            title: const Text('Clear Conversation History'),
            subtitle: const Text('Delete all your conversations'),
            onTap: () => _showClearHistoryDialog(),
          ),
          const Divider(),

          // Support Section
          _buildSectionHeader(context, 'Support'),
          ListTile(
            title: const Text('Report an Issue'),
            subtitle: const Text('Let us know if something isn\'t working'),
            onTap: () => _launchUrl(AppConstants.supportUrl),
          ),
          ListTile(
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            onTap: () => _launchUrl(AppConstants.feedbackUrl),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showClearHistoryDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Conversation History'),
          content: const SingleChildScrollView(
            child: Text(
              'Are you sure you want to clear all your conversation history? This action cannot be undone.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                context.read<ChatCubit>().deleteAllConversations();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversation history cleared')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}