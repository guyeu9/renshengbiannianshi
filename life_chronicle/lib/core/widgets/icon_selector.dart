import 'package:flutter/material.dart';
import '../utils/icon_utils.dart';

class IconSelector extends StatelessWidget {
  const IconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.moduleKey,
    this.iconNames,
    this.columns = 6,
    this.iconSize = 28,
    this.spacing = 10,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.showLabel = false,
  });

  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;
  final String? moduleKey;
  final List<String>? iconNames;
  final int columns;
  final double iconSize;
  final double spacing;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final bool showLabel;

  List<String> get _iconNames {
    if (iconNames != null) return iconNames!;
    if (moduleKey != null) {
      return IconUtils.getTagIconNamesForModule(moduleKey!);
    }
    return IconUtils.availableIcons;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icons = _iconNames;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: icons.map((iconName) {
        final isSelected = iconName == selectedIcon;
        final icon = IconUtils.fromName(iconName);

        return InkWell(
          onTap: () => onIconSelected(iconName),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: iconSize + 16,
            height: iconSize + 16,
            decoration: BoxDecoration(
              color: isSelected
                  ? (selectedBackgroundColor ?? colorScheme.primaryContainer)
                  : (backgroundColor ?? colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: selectedColor ?? colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: isSelected
                  ? (selectedColor ?? colorScheme.primary)
                  : (unselectedColor ?? colorScheme.onSurface),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class IconSelectorSheet extends StatefulWidget {
  const IconSelectorSheet({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.moduleKey,
    this.iconNames,
    this.title = '选择图标',
    this.iconSize = 28,
    this.columns = 6,
  });

  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;
  final String? moduleKey;
  final List<String>? iconNames;
  final String title;
  final double iconSize;
  final int columns;

  static Future<String?> show({
    required BuildContext context,
    String? selectedIcon,
    String? moduleKey,
    List<String>? iconNames,
    String title = '选择图标',
    double iconSize = 28,
    int columns = 6,
  }) async {
    String? result = selectedIcon;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IconSelectorSheet(
        selectedIcon: selectedIcon,
        onIconSelected: (icon) {
          result = icon;
          Navigator.of(context).pop();
        },
        moduleKey: moduleKey,
        iconNames: iconNames,
        title: title,
        iconSize: iconSize,
        columns: columns,
      ),
    );
    return result;
  }

  @override
  State<IconSelectorSheet> createState() => _IconSelectorSheetState();
}

class _IconSelectorSheetState extends State<IconSelectorSheet> {
  late String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: IconSelector(
                selectedIcon: _selectedIcon,
                onIconSelected: (icon) {
                  setState(() => _selectedIcon = icon);
                  widget.onIconSelected(icon);
                },
                moduleKey: widget.moduleKey,
                iconNames: widget.iconNames,
                iconSize: widget.iconSize,
                columns: widget.columns,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconPickerField extends StatelessWidget {
  const IconPickerField({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.moduleKey,
    this.iconNames,
    this.label,
    this.hintText = '点击选择图标',
    this.iconSize = 24,
  });

  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;
  final String? moduleKey;
  final List<String>? iconNames;
  final String? label;
  final String hintText;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () async {
        final result = await IconSelectorSheet.show(
          context: context,
          selectedIcon: selectedIcon,
          moduleKey: moduleKey,
          iconNames: iconNames,
        );
        if (result != null && result != selectedIcon) {
          onIconSelected(result);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            if (selectedIcon != null)
              Icon(
                IconUtils.fromName(selectedIcon),
                size: iconSize,
                color: colorScheme.primary,
              )
            else
              Icon(
                Icons.add_circle_outline,
                size: iconSize,
                color: colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label ?? (selectedIcon != null ? selectedIcon! : hintText),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: selectedIcon != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
