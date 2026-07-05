import 'package:flutter/material.dart';

import '../models/food_post.dart';
import '../models/stage.dart';
import '../services/post_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/month_nav.dart';
import '../widgets/post_form_sheet.dart';
import '../widgets/post_grid.dart';
import '../widgets/stage_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = PostRepository();

  List<FoodPost> _posts = [];
  String _activeStage = kStages.first.key;
  int _activeMonth = kAllMonths;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final posts = await _repository.loadPosts();
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  void _changeActiveStage(String key) {
    setState(() {
      _activeStage = key;
      _activeMonth = kAllMonths;
    });
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostFormSheet(
        repository: _repository,
        initialStage: _activeStage,
        initialMonth: _activeMonth,
        onSaved: (post) {
          setState(() {
            _posts = [post, ..._posts];
            _activeStage = post.stage;
            _activeMonth = post.month;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = stageByKey(_activeStage);
    final filtered = _posts
        .where((p) => p.stage == _activeStage && (_activeMonth == kAllMonths || p.month == _activeMonth))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOGMOG LOG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.leaf,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'もぐもぐ、いつから？',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _openForm,
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: const Text('記録する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clay,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 3,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            StageNav(activeStage: _activeStage, onChanged: _changeActiveStage),
            const SizedBox(height: 4),
            MonthNav(
              stage: currentStage,
              activeMonth: _activeMonth,
              onChanged: (month) => setState(() => _activeMonth = month),
            ),
            Expanded(child: _buildBody(currentStage, filtered)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Stage currentStage, List<FoodPost> filtered) {
    if (_loading) {
      return const Center(
        child: Text('読み込み中…', style: TextStyle(fontSize: 13, color: Color(0x8C3A342A))),
      );
    }
    if (filtered.isEmpty) {
      final monthLabel = _activeMonth == kAllMonths ? '' : '（$_activeMonthヶ月）';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${currentStage.label}$monthLabelの記録はまだないよ',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                '最初の一枚、撮ってみる？',
                style: TextStyle(fontSize: 13, color: Color(0x8C3A342A)),
              ),
            ],
          ),
        ),
      );
    }
    return PostGrid(posts: filtered);
  }
}
