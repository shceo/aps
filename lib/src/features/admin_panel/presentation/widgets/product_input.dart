// lib/src/features/admin_panel/presentation/widgets/product_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'invoice_service.dart';

/// Виджет для ввода списка товаров:
/// - первый столбец — название (с автодополнением),
/// - второй — количество,
/// - третий — цена за единицу.
///
/// После заполнения количества и цены нужно будет пересчитывать общую сумму,
/// а при сохранении объединять все три поля в один текст и шлёпать в Firestore
/// в то же поле product_details, как раньше.
class ProductInput extends StatefulWidget {
  final List<TextEditingController> nameControllers;
  final List<FocusNode> nameFocusNodes;
  final List<TextEditingController> qtyControllers;
  final List<TextEditingController> priceControllers;
  final InvoiceService service;
  final int maxItems;

  /// Колбэки:
  /// onNameChanged только для первого поля (название),
  /// onQtyChanged — для второго (количество),
  /// onPriceChanged — для третьего (цена за ед.),
  /// onAddRow — добавление новой «строки».
  final void Function(int index, String value) onNameChanged;
  final void Function(int index, String value) onQtyChanged;
  final void Function(int index, String value) onPriceChanged;
  final void Function(int index) onAddRow;

  const ProductInput({
    super.key,
    required this.nameControllers,
    required this.nameFocusNodes,
    required this.qtyControllers,
    required this.priceControllers,
    required this.service,
    required this.onNameChanged,
    required this.onQtyChanged,
    required this.onPriceChanged,
    required this.onAddRow,
    this.maxItems = 40,
  });

  @override
  _ProductInputState createState() => _ProductInputState();
}

class _ProductInputState extends State<ProductInput> {
  OverlayEntry? _suggestionsEntry;

  @override
  void initState() {
    super.initState();
    // показываем автодополнения только на поле «название»
    for (var i = 0; i < widget.nameFocusNodes.length; i++) {
      widget.nameFocusNodes[i].addListener(() {
        if (widget.nameFocusNodes[i].hasFocus) {
          _showSuggestions(i);
        }
      });
    }
  }

  @override
  void dispose() {
    _removeSuggestions();
    super.dispose();
  }

  void _removeSuggestions() {
    _suggestionsEntry?.remove();
    _suggestionsEntry = null;
  }

  void _showSuggestions(int index) async {
    final term = widget.nameControllers[index].text.trim();
    if (term.isEmpty) {
      _removeSuggestions();
      return;
    }
    _removeSuggestions();

    final overlay = Overlay.of(context);
    final renderBox =
        widget.nameFocusNodes[index].context!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _suggestionsEntry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: position.dx,
          top: position.dy + size.height,
          width: size.width * 2, // расширяем подсказки, если надо
          child: Material(
            elevation: 4,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.service.fetchProductList(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final products = snap.data!;
                final matches =
                    products.where((p) {
                      final name = (p['russian'] ?? '') as String;
                      return name.toLowerCase().contains(term.toLowerCase());
                    }).toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _removeSuggestions,
                      ),
                    ),
                    if (matches.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'No items found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    Flexible(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children:
                            matches.map((p) {
                              final name = (p['russian'] ?? '') as String;
                              return ListTile(
                                title: Text(name),
                                onTap: () {
                                  widget.nameControllers[index].text = name;
                                  widget.onNameChanged(index, name);
                                  _removeSuggestions();
                                  // сразу фокус на количество
                                  if (index < widget.qtyControllers.length) {
                                    FocusScope.of(context).requestFocus(
                                      FocusNode(), // можно сделать focusNode для qty, но не обязательно
                                    );
                                  }
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    overlay.insert(_suggestionsEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.nameControllers.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) Название товара
              Expanded(
                flex: 3,
                child: TextField(
                  controller: widget.nameControllers[i],
                  focusNode: widget.nameFocusNodes[i],
                  decoration: InputDecoration(
                    hintText: '${i + 1}. Название товара',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) {
                    widget.onNameChanged(i, v);
                    _showSuggestions(i);
                  },
                ),
              ),
              SizedBox(width: 8),

              // 2) Количество
              Expanded(
                flex: 1,
                child: TextField(
                  controller: widget.qtyControllers[i],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Кол-во',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => widget.onQtyChanged(i, v),
                ),
              ),
              SizedBox(width: 8),

              // 3) Цена за ед.
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.priceControllers[i],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\.,]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Цена за ед.',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => widget.onPriceChanged(i, v),
                ),
              ),

              IconButton(
                icon: Icon(
                  // если это последняя строка — рисуем «+», иначе — «удалить»
                  i == widget.nameControllers.length - 1
                      ? Icons.add
                      : Icons.delete,
                  color:
                      i == widget.nameControllers.length - 1
                          ? Colors.green
                          : Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    if (i == widget.nameControllers.length - 1) {
                      if (widget.nameControllers[i].text.trim().isEmpty) return;

                      widget.nameControllers.add(TextEditingController());
                      widget.nameFocusNodes.add(
                        FocusNode()..addListener(() {
                          if (widget.nameFocusNodes.last.hasFocus) {
                            _showSuggestions(widget.nameControllers.length - 1);
                          }
                        }),
                      );
                      widget.qtyControllers.add(TextEditingController());
                      widget.priceControllers.add(TextEditingController());

                      FocusScope.of(
                        context,
                      ).requestFocus(widget.nameFocusNodes.last);
                    } else {
                      // удаляем эту строку
                      widget.nameControllers.removeAt(i);
                      widget.nameFocusNodes.removeAt(i);
                      widget.qtyControllers.removeAt(i);
                      widget.priceControllers.removeAt(i);
                    }
                  });
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
