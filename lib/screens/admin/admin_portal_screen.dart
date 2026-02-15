import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cw_flutter/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/errors/api_error.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../core/utils/plate_utils.dart';
import '../../models/member_row.dart';
import '../../models/scanned_customer.dart';
import '../../providers/admin_portal_provider.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/saudi_plate.dart';

class AdminPortalScreen extends ConsumerStatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  ConsumerState<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends ConsumerState<AdminPortalScreen> {
  String _activeTab = 'overview';
  bool _showScanner = false;
  ScannedCustomer? _scannedCustomer;
  String _searchQuery = '';
  Map<String, dynamic>? _feedback;
  bool _processing = false;
  bool _actionDone = false;
  String? _pendingBarcode;

  // Edit member
  MemberRow? _editingMember;
  String _editName = '';
  String _editPhone = '';
  String _editPlate = '';

  // Filters
  String _activityFilter = 'all';
  String _memberFilter = 'all';
  String _memberSort = 'recent';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final adminState = ref.watch(adminPortalProvider);

    if (adminState.loading) {
      return const Scaffold(
        body: Center(
          child: Text('...', style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          )),
        ),
      );
    }

    final members = adminState.members;
    final stats = adminState.stats;
    final activity = adminState.activity;

    // Filtering logic
    final filteredMembers = _filterAndSortMembers(members);
    final filteredActivity = activity.where((item) {
      if (_activityFilter == 'free') return item.wash.isFree;
      if (_activityFilter == 'paid') return !item.wash.isFree;
      return true;
    }).toList();

    final topMember = members.isEmpty
        ? null
        : members.reduce((a, b) => a.washesCount > b.washesCount ? a : b);

    return Scaffold(
      appBar: const GlassAppBar(),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: _activeTab == 'overview'
                ? _buildOverview(l10n, stats, filteredMembers, filteredActivity, topMember)
                : _buildMembers(l10n, filteredMembers),
          ),

          // Bottom nav
          _buildBottomNav(l10n),

          // Feedback banner
          if (_feedback != null)
            Positioned(
              top: 0,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _feedback!['type'] == 'success'
                        ? AppColors.successBg
                        : AppColors.errorBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _feedback!['type'] == 'success'
                          ? AppColors.successBorder
                          : AppColors.errorBorder,
                    ),
                  ),
                  child: Text(
                    _feedback!['msg'] as String,
                    style: TextStyle(
                      color: _feedback!['type'] == 'success'
                          ? AppColors.successText
                          : AppColors.errorText,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

          // Scanned customer modal
          if (_scannedCustomer != null) _buildScannedCustomerModal(l10n),

          // Pending barcode confirmation
          if (_pendingBarcode != null) _buildPendingBarcodeModal(l10n),

          // Scanner
          if (_showScanner) _buildScannerOverlay(l10n),
        ],
      ),
    );
  }

  List<MemberRow> _filterAndSortMembers(List<MemberRow> members) {
    final query = _searchQuery.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final normalizedLetters = normalizePlateLetters(_searchQuery);
    final normalizedDigits = normalizePlateDigits(_searchQuery);

    var filtered = members.where((u) {
      if (_searchQuery.isEmpty) return true;
      final plateRaw = (u.plateNumber ?? '').toUpperCase();
      final parts = plateRaw.split('-');
      final plateDigits = parts.isNotEmpty ? parts[0] : '';
      final plateLetters = parts.length > 1 ? parts[1] : '';

      final matchesPlate = (normalizedLetters.isNotEmpty &&
              normalizedDigits.isNotEmpty &&
              plateLetters.contains(normalizedLetters) &&
              plateDigits.contains(normalizedDigits)) ||
          (normalizedLetters.isNotEmpty &&
              plateLetters.contains(normalizedLetters)) ||
          (normalizedDigits.isNotEmpty &&
              plateDigits.contains(normalizedDigits)) ||
          plateRaw.replaceAll(RegExp(r'\s+'), '').toLowerCase().contains(query);

      return u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.barcode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.phone.contains(_searchQuery) ||
          matchesPlate;
    }).toList();

    // Member filter
    final weekAgo = DateTime.now().millisecondsSinceEpoch - 7 * 24 * 60 * 60 * 1000;
    filtered = filtered.where((u) {
      if (_memberFilter == 'gift') return u.freeWashAvailable;
      if (_memberFilter == 'new') return u.createdAt >= weekAgo;
      if (_memberFilter == 'inactive') return u.lastWashAt == null;
      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      if (_memberSort == 'name') return a.fullName.compareTo(b.fullName);
      if (_memberSort == 'washes') return b.washesCount - a.washesCount;
      final aTime = a.lastWashAt ?? 0;
      final bTime = b.lastWashAt ?? 0;
      return bTime - aTime;
    });

    return filtered;
  }

  Widget _buildOverview(AppLocalizations l10n, stats, List<MemberRow> members,
      List filteredActivity, MemberRow? topMember) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Search
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: l10n.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search, size: 20),
                  ),
                ),
                if (_searchQuery.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...members.take(5).map((m) => _buildSearchResult(m)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats cards
          Row(
            children: [
              Expanded(child: _buildStatCard(l10n.totalMembers, '${stats.membersCount}', false)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(l10n.giftsReady, '${stats.giftsReady}', true)),
            ],
          ),
          const SizedBox(height: 16),

          // Top member
          if (topMember != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.topMember.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMuted,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topMember.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.lastWash}: ${app_date.formatShortDate(topMember.lastWashAt ?? 0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${topMember.washesCount} / 5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondary,
                        ),
                      ),
                      if (topMember.freeWashAvailable)
                        Text(
                          l10n.gift.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.emerald,
                            letterSpacing: 0,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Activity
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(56),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.activity.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    Wrap(
                      spacing: 4,
                      children: [
                        ...['all', 'paid', 'free'].map((f) => _buildFilterChip(
                            f,
                            f == 'all' ? l10n.filterAll : f == 'paid' ? l10n.filterPaid : l10n.filterFree,
                            _activityFilter,
                            (v) => setState(() => _activityFilter = v))),
                        GestureDetector(
                          onTap: _clearActivity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.clearActivity,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.error,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...filteredActivity.take(20).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item.wash.isFree ? AppColors.successBg : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(item.wash.isFree ? '🎁' : '💧', style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.user.fullName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: item.wash.isFree ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${item.user.phone} · ${app_date.formatTime(item.wash.timestamp)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.wash.isFree ? AppColors.successText : AppColors.border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.wash.isFree ? l10n.gift : l10n.paid,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: item.wash.isFree ? Colors.white : AppColors.textMuted,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembers(AppLocalizations l10n, List<MemberRow> members) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Search
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide(color: AppColors.border, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filters
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      l10n.quickFilters.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMuted,
                        letterSpacing: 0,
                      ),
                    ),
                    ...['all', 'gift', 'new', 'inactive'].map((f) => _buildFilterChip(
                        f,
                        f == 'all' ? l10n.filterAll : f == 'gift' ? l10n.filterGifts : f == 'new' ? l10n.filterNew : l10n.filterInactive,
                        _memberFilter,
                        (v) => setState(() => _memberFilter = v))),
                  ],
                ),
              ),
              // Sort dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButton<String>(
                  value: _memberSort,
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                  items: [
                    DropdownMenuItem(value: 'recent', child: Text(l10n.sortRecent)),
                    DropdownMenuItem(value: 'name', child: Text(l10n.sortName)),
                    DropdownMenuItem(value: 'washes', child: Text(l10n.sortWashes)),
                  ],
                  onChanged: (v) => setState(() => _memberSort = v ?? 'recent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Member list
          ...members.map((member) => _buildMemberCard(l10n, member)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(AppLocalizations l10n, MemberRow member) {
    final isEditing = _editingMember?.id == member.id;

    return GestureDetector(
      onTap: () => _loadCustomerByBarcode(member.barcode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: member.freeWashAvailable
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: member.freeWashAvailable
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.person_outline, color: AppColors.textMuted, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: member.freeWashAvailable
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(member.phone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      Text(member.barcode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.memberSince} ${app_date.formatShortDate(member.createdAt)} · ${l10n.lastWash} ${member.lastWashAt != null ? app_date.formatShortDate(member.lastWashAt!) : "—"}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMuted,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${member.washesCount} / 5',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                    if (member.freeWashAvailable)
                      Text(
                        l10n.gift.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald,
                          letterSpacing: 0,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (member.plateNumber != null && member.plateNumber!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SaudiPlate(plate: member.plateNumber!, scale: 0.6),
            ],
            const SizedBox(height: 20),
            if (isEditing)
              _buildEditForm(l10n, member)
            else
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _editingMember = member;
                          _editName = member.fullName;
                          _editPhone = member.phone;
                          _editPlate = member.plateNumber ?? '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.edit.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _deleteMember(l10n, member),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.delete.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.error,
                            letterSpacing: 0,
                          ),
                        ),
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

  Widget _buildEditForm(AppLocalizations l10n, MemberRow member) {
    return Column(
      children: [
        TextField(
          controller: TextEditingController(text: _editName),
          onChanged: (v) => _editName = v,
          decoration: InputDecoration(hintText: l10n.fullName),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: _editPhone),
          onChanged: (v) => _editPhone = v,
          decoration: InputDecoration(hintText: l10n.mobile),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: _editPlate),
          onChanged: (v) => _editPlate = v,
          decoration: InputDecoration(hintText: l10n.plate),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _editingMember = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0, fontSize: 12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _processing ? null : () => _saveMember(l10n),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _processing ? '...' : l10n.save,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchResult(MemberRow member) {
    return GestureDetector(
      onTap: () => _loadCustomerByBarcode(member.barcode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                Text(member.phone, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              ],
            ),
            Text(
              '${member.washesCount} / 5',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, String current, ValueChanged<String> onChanged) {
    final active = value == current;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.dark : AppColors.border,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : AppColors.textMuted,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.borderMedium.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 60,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildNavItem(l10n.overview, Icons.home_outlined, 'overview'),
                _buildNavItem(l10n.members, Icons.person_outline, 'members'),
                // Scan button
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showScanner = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderMedium.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_scanner, size: 20, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.scanBarcode.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMuted,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, String tab) {
    final active = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12)]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: active ? Colors.white : AppColors.textMuted),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: active ? Colors.white : AppColors.textMuted,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannedCustomerModal(AppLocalizations l10n) {
    final customer = _scannedCustomer!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _scannedCustomer = null),
        child: Container(
          color: AppColors.dark.withValues(alpha: 0.4),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(64),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              customer.fullName.isNotEmpty ? customer.fullName[0] : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                                Text(customer.barcode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                if (customer.plateNumber != null && customer.plateNumber!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: SaudiPlate(plate: customer.plateNumber!, scale: 0.6),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _scannedCustomer = null),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.errorBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: AppColors.error, size: 20),
                            ),
                          ),
                        ],
                      ),

                      // Free wash banner
                      if (customer.freeWashAvailable)
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.successBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🎁 ', style: TextStyle(fontSize: 16)),
                              Text(
                                l10n.freeNextMsg,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.successText,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Main action button
                      if (!_actionDone)
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _processing ? null : _processWash,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: AppColors.dark,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _processing
                                    ? '...'
                                    : customer.freeWashAvailable
                                        ? l10n.redeemReward.toUpperCase()
                                        : l10n.registerWash.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.confirm.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMuted,
                              letterSpacing: 0,
                            ),
                          ),
                        ),

                      // Undo button
                      if (customer.washHistory.isNotEmpty)
                        GestureDetector(
                          onTap: _processing ? null : _undoLastWash,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _processing ? '...' : l10n.undoWash.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.error,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingBarcodeModal(AppLocalizations l10n) {
    return Positioned.fill(
      child: Container(
        color: AppColors.dark.withValues(alpha: 0.4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(56),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.confirmScan, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(_pendingBarcode!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _pendingBarcode = null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0, fontSize: 12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _confirmBarcode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0, fontSize: 12)),
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
    );
  }

  Widget _buildScannerOverlay(AppLocalizations l10n) {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final barcode = barcodes.first.rawValue;
                    if (barcode != null && barcode.isNotEmpty) {
                      setState(() {
                        _showScanner = false;
                        _pendingBarcode = barcode.trim();
                      });
                    }
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => setState(() => _showScanner = false),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
                  ),
                  child: Text(
                    l10n.scanAtCounter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Actions
  Future<void> _loadCustomerByBarcode(String barcode) async {
    try {
      final customer = await ref.read(adminServiceProvider).getCustomer(barcode);
      setState(() {
        _scannedCustomer = customer;
        _actionDone = false;
      });
    } catch (e) {
      _showFeedback('error', e is ApiError ? e.arabicMessage : 'Customer not found');
    }
  }

  Future<void> _confirmBarcode() async {
    if (_pendingBarcode == null) return;
    await _loadCustomerByBarcode(_pendingBarcode!);
    setState(() => _pendingBarcode = null);
  }

  Future<void> _processWash() async {
    if (_scannedCustomer == null) return;
    setState(() {
      _processing = true;
      _actionDone = false;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final notifier = ref.read(adminPortalProvider.notifier);
      if (_scannedCustomer!.freeWashAvailable) {
        await notifier.useFreeWash(_scannedCustomer!.barcode);
        _showFeedback('success', l10n.freeWashAlert);
      } else {
        final res = await notifier.scanBarcode(_scannedCustomer!.barcode);
        _showFeedback('success', res.freeWashAvailable ? l10n.freeWashAlert : l10n.paidWashAlert);
      }
      setState(() {
        _actionDone = true;
        _scannedCustomer = null;
      });
      await ref.read(adminPortalProvider.notifier).reload();
    } catch (e) {
      _showFeedback('error', e is ApiError ? e.arabicMessage : 'Failed');
    } finally {
      setState(() => _processing = false);
    }
  }

  Future<void> _undoLastWash() async {
    if (_scannedCustomer == null) return;
    setState(() => _processing = true);

    final l10n = AppLocalizations.of(context)!;

    try {
      await ref.read(adminPortalProvider.notifier).undoWash(_scannedCustomer!.barcode);
      _showFeedback('success', l10n.undoSuccess);
      setState(() {
        _scannedCustomer = null;
        _actionDone = false;
      });
      await ref.read(adminPortalProvider.notifier).reload();
    } catch (e) {
      _showFeedback('error', e is ApiError ? e.arabicMessage : 'Failed');
    } finally {
      setState(() => _processing = false);
    }
  }

  Future<void> _saveMember(AppLocalizations l10n) async {
    if (_editingMember == null) return;
    setState(() => _processing = true);

    try {
      await ref.read(adminPortalProvider.notifier).updateMember(
        _editingMember!.id,
        fullName: _editName,
        phone: _editPhone,
        plateNumber: _editPlate.isEmpty ? null : _editPlate,
      );
      _showFeedback('success', l10n.saved);
      setState(() => _editingMember = null);
    } catch (e) {
      _showFeedback('error', e is ApiError ? e.arabicMessage : 'Failed');
    } finally {
      setState(() => _processing = false);
    }
  }

  Future<void> _deleteMember(AppLocalizations l10n, MemberRow member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processing = true);
    try {
      await ref.read(adminPortalProvider.notifier).deleteMember(member.id);
      _showFeedback('success', l10n.deleted);
    } catch (e) {
      _showFeedback('error', e is ApiError ? e.arabicMessage : 'Failed');
    } finally {
      setState(() => _processing = false);
    }
  }

  Future<void> _clearActivity() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearActivityConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.clearActivity)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processing = true);
    try {
      await ref.read(adminPortalProvider.notifier).clearActivity();
      _showFeedback('success', l10n.cleared);
    } catch (e) {
      _showFeedback('error', e is ApiError ? e.arabicMessage : 'Failed');
    } finally {
      setState(() => _processing = false);
    }
  }

  void _showFeedback(String type, String msg) {
    setState(() => _feedback = {'type': type, 'msg': msg});
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _feedback = null);
    });
  }
}
