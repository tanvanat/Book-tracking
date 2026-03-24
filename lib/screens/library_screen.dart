import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BookStatus { reading, completed, dropped }

class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final int totalPages;
  int currentPage;
  BookStatus status;
  double rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.totalPages,
    this.currentPage = 0,
    this.status = BookStatus.reading,
    this.rating = 0,
  });

  double get progress =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Book> _filtered(BookStatus status) =>
      _books.where((b) => b.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'My Library',
          style: TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'กำลังอ่าน (${_filtered(BookStatus.reading).length})'),
            Tab(text: 'อ่านแล้ว (${_filtered(BookStatus.completed).length})'),
            Tab(text: 'หยุดอ่าน (${_filtered(BookStatus.dropped).length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มหนังสือ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookList(_filtered(BookStatus.reading)),
          _buildBookList(_filtered(BookStatus.completed)),
          _buildBookList(_filtered(BookStatus.dropped)),
        ],
      ),
    );
  }

  Widget _buildBookList(List<Book> books) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'ยังไม่มีหนังสือ',
              style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'กด + เพื่อเพิ่มหนังสือ',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) => _bookCard(books[index]),
    );
  }

  Widget _bookCard(Book book) {
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
      child: Row(
        children: [
          // Book cover placeholder
          Container(
            width: 56,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.book_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                if (book.status == BookStatus.reading) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(book.progress * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.currentPage} / ${book.totalPages} หน้า',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint),
                  ),
                ],
                if (book.status == BookStatus.completed && book.rating > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < book.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFFFC107),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onPressed: () => _showBookOptions(context, book),
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final pagesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เพิ่มหนังสือใหม่',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'ชื่อหนังสือ'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: authorCtrl,
              decoration: const InputDecoration(hintText: 'ชื่อผู้แต่ง'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pagesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'จำนวนหน้าทั้งหมด'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isEmpty || authorCtrl.text.isEmpty) return;
                  setState(() {
                    _books.add(Book(
                      id: DateTime.now().toIso8601String(),
                      title: titleCtrl.text,
                      author: authorCtrl.text,
                      totalPages: int.tryParse(pagesCtrl.text) ?? 0,
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
                child: const Text('เพิ่มหนังสือ',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookOptions(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
              title: const Text('อัปเดตหน้าที่อ่าน'),
              onTap: () {
                Navigator.pop(context);
                _showUpdatePageDialog(context, book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_rounded,
                  color: Colors.green),
              title: const Text('มาร์คว่าอ่านแล้ว'),
              onTap: () {
                setState(() => book.status = BookStatus.completed);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle_rounded,
                  color: Colors.orange),
              title: const Text('หยุดอ่าน'),
              onTap: () {
                setState(() => book.status = BookStatus.dropped);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: Colors.redAccent),
              title: const Text('ลบหนังสือ',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                setState(() => _books.remove(book));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePageDialog(BuildContext context, Book book) {
    final ctrl = TextEditingController(text: book.currentPage.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('อัปเดตหน้าที่อ่าน'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration:
              InputDecoration(hintText: 'หน้าปัจจุบัน (สูงสุด ${book.totalPages})'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                book.currentPage =
                    (int.tryParse(ctrl.text) ?? book.currentPage)
                        .clamp(0, book.totalPages);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}