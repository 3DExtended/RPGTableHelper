// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpg_configuration_wizard_step_5_item_categories.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$_ItemCategoryEditCWProxy {
  _ItemCategoryEdit uuid(String uuid);

  _ItemCategoryEdit nameController(TextEditingController nameController);

  _ItemCategoryEdit iconName(String? iconName);

  _ItemCategoryEdit iconColor(Color? iconColor);

  _ItemCategoryEdit subCategories(List<_ItemCategoryEdit> subCategories);

  _ItemCategoryEdit hideInInventoryFilters(bool hideInInventoryFilters);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `_ItemCategoryEdit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// _ItemCategoryEdit(...).copyWith(id: 12, name: "My name")
  /// ```
  _ItemCategoryEdit call({
    String uuid,
    TextEditingController nameController,
    String? iconName,
    Color? iconColor,
    List<_ItemCategoryEdit> subCategories,
    bool hideInInventoryFilters,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOf_ItemCategoryEdit.copyWith(...)` or call `instanceOf_ItemCategoryEdit.copyWith.fieldName(value)` for a single field.
class _$_ItemCategoryEditCWProxyImpl implements _$_ItemCategoryEditCWProxy {
  const _$_ItemCategoryEditCWProxyImpl(this._value);

  final _ItemCategoryEdit _value;

  @override
  _ItemCategoryEdit uuid(String uuid) => call(uuid: uuid);

  @override
  _ItemCategoryEdit nameController(TextEditingController nameController) =>
      call(nameController: nameController);

  @override
  _ItemCategoryEdit iconName(String? iconName) => call(iconName: iconName);

  @override
  _ItemCategoryEdit iconColor(Color? iconColor) => call(iconColor: iconColor);

  @override
  _ItemCategoryEdit subCategories(List<_ItemCategoryEdit> subCategories) =>
      call(subCategories: subCategories);

  @override
  _ItemCategoryEdit hideInInventoryFilters(bool hideInInventoryFilters) =>
      call(hideInInventoryFilters: hideInInventoryFilters);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `_ItemCategoryEdit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// _ItemCategoryEdit(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  _ItemCategoryEdit call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? nameController = const $CopyWithPlaceholder(),
    Object? iconName = const $CopyWithPlaceholder(),
    Object? iconColor = const $CopyWithPlaceholder(),
    Object? subCategories = const $CopyWithPlaceholder(),
    Object? hideInInventoryFilters = const $CopyWithPlaceholder(),
  }) {
    return _ItemCategoryEdit(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      nameController:
          nameController == const $CopyWithPlaceholder() ||
              nameController == null
          ? _value.nameController
          // ignore: cast_nullable_to_non_nullable
          : nameController as TextEditingController,
      iconName: iconName == const $CopyWithPlaceholder()
          ? _value.iconName
          // ignore: cast_nullable_to_non_nullable
          : iconName as String?,
      iconColor: iconColor == const $CopyWithPlaceholder()
          ? _value.iconColor
          // ignore: cast_nullable_to_non_nullable
          : iconColor as Color?,
      subCategories:
          subCategories == const $CopyWithPlaceholder() || subCategories == null
          ? _value.subCategories
          // ignore: cast_nullable_to_non_nullable
          : subCategories as List<_ItemCategoryEdit>,
      hideInInventoryFilters:
          hideInInventoryFilters == const $CopyWithPlaceholder() ||
              hideInInventoryFilters == null
          ? _value.hideInInventoryFilters
          // ignore: cast_nullable_to_non_nullable
          : hideInInventoryFilters as bool,
    );
  }
}

extension _$_ItemCategoryEditCopyWith on _ItemCategoryEdit {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOf_ItemCategoryEdit.copyWith(...)` or `instanceOf_ItemCategoryEdit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$_ItemCategoryEditCWProxy get copyWith =>
      _$_ItemCategoryEditCWProxyImpl(this);
}
