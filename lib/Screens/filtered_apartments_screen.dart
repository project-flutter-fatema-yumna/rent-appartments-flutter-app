import 'package:flats_app/Services/get_filtered_apartments.dart';
import 'package:flats_app/models/filter_criteria.dart';
import 'package:flats_app/models/model_apartment.dart';
import 'package:flats_app/widgets/secondCardHome.dart';
import 'package:flutter/material.dart';

class FilteredApartmentsScreen extends StatefulWidget {
  static String id = 'FilteredApartmentsScreen';
  const FilteredApartmentsScreen({super.key});

  @override
  State<FilteredApartmentsScreen> createState() =>
      _FilteredApartmentsScreenState();
}

class _FilteredApartmentsScreenState extends State<FilteredApartmentsScreen> {
  late FilterCriteria filters;
  bool _isLoading = true;
  List<Model_Apartment> apartments = [];
  String? _errorMsg;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      filters = ModalRoute.of(context)!.settings.arguments as FilterCriteria;
      _loadApartments();
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  Future<void> _loadApartments() async {
    try {
      final result = await getFilteredApartments(filters, context);
      setState(() {
        apartments = result;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Something went wrong';
        print('$e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filtered apartments'),),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (_errorMsg != null) {
      return Center(child: Text(_errorMsg!));
    }
    if (apartments.isEmpty) {
      return const Center(
        child: Text(
          'No apartments match your filters',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        return Second_card_home(model_apartment: apartments[index]);
      },
    );
  }
}
