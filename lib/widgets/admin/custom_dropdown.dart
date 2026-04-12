// lib/widgets/admin/custom_dropdown.dart
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final String label;
  final IconData icon;
  final List<CustomDropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isLoading;
  final bool isRequired;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.label,
    required this.icon,
    required this.items,
    this.onChanged,
    this.validator,
    this.isLoading = false,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: isLoading ? null : () => _showDropdownMenu(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getDisplayText(),
                      style: TextStyle(
                        color: value == null ? Colors.grey.shade500 : Colors.black87,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.green.shade600),
                ],
              ),
            ),
          ),
        ),
        if (isRequired && validator != null && value == null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              'Please select $label',
              style: TextStyle(fontSize: 12, color: Colors.red.shade400),
            ),
          ),
      ],
    );
  }

  String _getDisplayText() {
    if (isLoading) return 'Loading...';
    if (value == null) return hint;

    for (var item in items) {
      if (item.value == value) {
        return item.label;
      }
    }
    return hint;
  }

  void _showDropdownMenu(BuildContext context) async {
    if (isLoading) return;

    final selectedValue = await showModalBottomSheet<T?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Select $label',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...items.map((item) {
                        return InkWell(
                          onTap: () => Navigator.pop(context, item.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(icon, color: Colors.green.shade600, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text(item.label)),
                                if (value == item.value)
                                  Icon(Icons.check, color: Colors.green.shade600),
                              ],
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 1),
                      InkWell(
                        onTap: () => Navigator.pop(context, null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(Icons.clear, color: Colors.red.shade400),
                              const SizedBox(width: 12),
                              const Text('Clear selection'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedValue != value && onChanged != null) {
      onChanged!(selectedValue);
    }
  }
}

class CustomDropdownItem<T> {
  final T? value;
  final String label;

  const CustomDropdownItem({
    required this.value,
    required this.label,
  });
}