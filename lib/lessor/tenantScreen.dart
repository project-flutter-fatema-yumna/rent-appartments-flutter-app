import 'package:flats_app/MyColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Services/Lessor_Services/getAllTenantsService.dart';
import '../models/model_tenantUser.dart';

class tenants_Screen extends StatefulWidget {
  static const id = "tenants_Screen";
  const tenants_Screen({super.key});

  @override
  State<tenants_Screen> createState() => _tenants_ScreenState();
}

class _tenants_ScreenState extends State<tenants_Screen> {
  final searchText=TextEditingController();
  bool loading = true;
  String? error;
  List<Model_tenant> allTenants = [];
  List<Model_tenant> filteredTenants = [];

  void initState() {
    super.initState();
    _fetchTenants();
    searchText.addListener(() {
      _applySearch(searchText.text);
    });
  }
  Future<void> _fetchTenants() async {
    setState(() { loading = true; error = null; });

    try {
      //final prefs = await SharedPreferences.getInstance();
      //final token = prefs.getString("token");
      final String token='1|EZIEoy5aLnCdi5XP2jxeaGtnNT60yqCeYyfoaP0W9a2b30e6';


      if (token == null || token.isEmpty) throw Exception("Token not found");

      final list = await get_All_Tenants().getTenants(token: token);

      setState(() {
        allTenants = list;
        filteredTenants = list;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }
  void _applySearch(String text) {
    final query = text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => filteredTenants = allTenants);
      return;
    }
    setState(() {
      filteredTenants = allTenants.where((t) {
        final name = ("${t.firstName ?? ""} ${t.lastName ?? ""}").toLowerCase();
        final phone = (t.phone ?? "").toLowerCase();
        final username = (t.username ?? "").toLowerCase();
        return name.contains(query) || phone.contains(query) || username.contains(query);
      }).toList();
    });
  }
  @override
  void dispose() {
    searchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myColors.colorWhite,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Tenants",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Contact & Chat",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Manage your tenants and communicate easily",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: myColors.colorWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF667085)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchText,
                          decoration: const InputDecoration(
                            hintText: "Search tenant name or phone...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (searchText.text.isNotEmpty)
                        IconButton(
                          onPressed: () => searchText.clear(),
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFF667085)),
                        ),
                    ],
                  ),

                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Builder(
              builder: (_) {
                if (loading) {
                  return Center(
                    child: SpinKitThreeBounce(color: Colors.blue, size: 20),
                  );
                }

                if (error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 10),
                          Text(error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _fetchTenants,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredTenants.isEmpty) {
                  return const Center(child: Text("No tenants yet"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  itemCount: filteredTenants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _TenantCard(
                    tenant: filteredTenants[index],
                    onCall: () async {
                      final phone = filteredTenants[index].phone;
                      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                    onChat: () {},
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final Model_tenant tenant;
  final VoidCallback onCall;
  final VoidCallback onChat;

  const _TenantCard({
    required this.tenant,
    required this.onCall,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.05),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                tenant.firstName.isNotEmpty
                    ? tenant.firstName.trim()[0].toUpperCase()
                    : "T",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tenant.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF101828),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tenant.phone,
                  style: const TextStyle(
                    color: Color(0xFF475467),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tenant.username,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              _actionButton(
                icon: Icons.call_rounded,
                label: "Call",
                color: Colors.green,
                onTap: onCall,
              ),
              const SizedBox(height: 8),
              _actionButton(
                icon: Icons.chat_bubble_rounded,
                label: "Chat",
                color: Colors.blue,
                onTap: onChat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
