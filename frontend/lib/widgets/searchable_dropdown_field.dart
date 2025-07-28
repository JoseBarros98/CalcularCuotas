import 'package:flutter/material.dart';

class SearchableDropdownField<T> extends StatefulWidget {
  final String labelText;
  final String hintText;
  final Icon? prefixIcon;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const SearchableDropdownField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    required this.selectedItem,
    required this.itemAsString,
    required this.onChanged,
    this.validator,
  });

  @override
  State<SearchableDropdownField<T>> createState() => _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T> extends State<SearchableDropdownField<T>> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant SearchableDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    _controller.text = widget.selectedItem != null ? widget.itemAsString(widget.selectedItem as T) : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showSelectionDialog() async {
    final T? selected = await showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return _SearchDialog<T>(
          items: widget.items,
          itemAsString: widget.itemAsString,
        );
      },
    );

    if (selected != null && selected != widget.selectedItem) {
      widget.onChanged(selected);
    } else if (selected == null && widget.selectedItem != null) {
      // Si el usuario cierra el diálogo sin seleccionar nada y ya había algo seleccionado,
      // podemos decidir si queremos deseleccionar o mantener el valor.
      // Por ahora, lo mantendremos si no se selecciona nada nuevo.
      // Si se quisiera deseleccionar al cerrar sin elegir, se podría llamar widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true, // Para que no se pueda escribir directamente
      onTap: _showSelectionDialog,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.selectedItem != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.onChanged(null); // Permite deseleccionar
                },
              )
            : const Icon(Icons.arrow_drop_down), // Icono de dropdown
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(widget.selectedItem);
        }
        return null;
      },
    );
  }
}

class _SearchDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemAsString;

  const _SearchDialog({
    super.key,
    required this.items,
    required this.itemAsString,
  });

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return widget.itemAsString(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Buscar...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            final item = _filteredItems[index];
            return ListTile(
              title: Text(widget.itemAsString(item)),
              onTap: () {
                Navigator.of(context).pop(item); // Devuelve el elemento seleccionado
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo sin seleccionar nada
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
