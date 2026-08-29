import 'package:flutter/material.dart';
import 'package:erp_software/frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ErpTopbar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;

  const ErpTopbar({
    super.key,
    this.searchQuery = '',
    this.onSearchChanged,
  });

  @override
  State<ErpTopbar> createState() => _ErpTopbarState();
}

class _ErpTopbarState extends State<ErpTopbar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final emp = authProvider.employee;
    final userName = emp?.fullName?.isNotEmpty == true ? emp!.fullName : (user?.email.split('@').first ?? '');
    final userRole = user?.role.toUpperCase() ?? '';
    final initials = userName!.length >= 2 ? userName.substring(0, 2).toUpperCase() : 'MM';

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Mobile Hamburger Menu Icon Button
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            const SizedBox(width: 4),
          ],

          // Search input box
          Expanded(
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (widget.onSearchChanged != null) {
                    widget.onSearchChanged!(val);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Search employee...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Settings Gear Icon Button
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, size: 18, color: Color(0xFF64748B)),
              onPressed: () {},
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),

          // User Profile Pill / Menu
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 70, 20, 0),
                items: <PopupMenuEntry<dynamic>>[
                  PopupMenuItem(
                    enabled: false,
                    child: Text('Logged in as $userName ($userRole)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () => authProvider.logout(),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          userRole,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
