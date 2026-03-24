import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BookReview {
  final String id;
  final String bookTitle;
  final String author;
  final double rating;
  final String reviewText;
  final DateTime reviewedAt;

  BookReview({
    required this.id,
    required this.bookTitle,
    required this.author,
    required this.rating,
    required this.reviewText,
    required this.reviewedAt,
  });
}

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<BookReview> _reviews = [];
  String _sortBy = 'newest';

  List<BookReview> get _sorted {
    final list = [..._reviews];
    if (_sortBy == 'newest') {
      list.sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt));
    } else if (_sortBy == 'highest') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      list.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return list;
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'รีวิว & Rating',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded,
                color: AppColors.textSecondary),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'newest', child: Text('ล่าสุด')),
              PopupMenuItem(
                  value: 'highest', child: Text('คะแนนสูงสุด')),
              PopupMenuItem(
                  value: 'lowest', child: Text('คะแนนต่ำสุด')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text('เขียนรีวิว',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีรีวิว',
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'เขียนรีวิวหนังสือที่คุณอ่านจบแล้ว',
                    style:
                        TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary card
                _buildSummaryCard(),
                // Reviews list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _sorted.length,
                    itemBuilder: (context, index) =>
                        _reviewCard(_sorted[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < _avgRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_reviews.length} รีวิว',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const Text(
                'คะแนนเฉลี่ยของคุณ',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(BookReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.bookTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      review.author,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textHint, size: 20),
                onPressed: () =>
                    setState(() => _reviews.remove(review)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          if (review.reviewText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.reviewText,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatDate(review.reviewedAt),
            style: const TextStyle(
                fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showAddReviewSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final reviewCtrl = TextEditingController();
    double selectedRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'เขียนรีวิวหนังสือ',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleCtrl,
                  decoration:
                      const InputDecoration(hintText: 'ชื่อหนังสือ'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorCtrl,
                  decoration:
                      const InputDecoration(hintText: 'ชื่อผู้แต่ง'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ให้คะแนน',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => setModalState(
                          () => selectedRating = (i + 1).toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          i < selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFC107),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reviewCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'เขียนรีวิวของคุณ (ไม่บังคับ)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isEmpty ||
                          authorCtrl.text.isEmpty ||
                          selectedRating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'กรุณากรอกชื่อหนังสือ ผู้แต่ง และให้คะแนน'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _reviews.add(BookReview(
                          id: DateTime.now().toIso8601String(),
                          bookTitle: titleCtrl.text,
                          author: authorCtrl.text,
                          rating: selectedRating,
                          reviewText: reviewCtrl.text,
                          reviewedAt: DateTime.now(),
                        ));
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('บันทึกรีวิว',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}