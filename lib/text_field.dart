import 'package:flutter/material.dart';
import 'package:theia_flutter/node/node.dart';

class InlineTextField extends StatefulWidget {
  const InlineTextField({
    Key? key,
    required this.elementNode,
    this.editable = true
  }) : super(key: key);

  final ElementNode elementNode;
  final bool editable;

  @override
  State<StatefulWidget> createState() => InlineTextFieldState();
}

class InlineTextFieldState extends State<InlineTextField> {
  @protected
  late InlineTextEditingController editingController;

  @override
  void initState() {
    super.initState();
    editingController = InlineTextEditingController(
        widget.elementNode,
        editable: widget.editable
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: const InputDecoration(
        isCollapsed: true
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
  }
}

class InlineTextEditingController extends TextEditingController {
  InlineTextEditingController(this.elementNode, {
    this.editable = true
  }) {
    StringBuffer stringBuffer = StringBuffer();
    for (Node child in elementNode.children) {
      if (child is InlineNode) {
        stringBuffer.writeCharCode(PlaceholderSpan.placeholderCodeUnit);
      } else if (child is TextNode) {
        stringBuffer.write(child.text);
      }
    }
    text = stringBuffer.toString();
  }

  final ElementNode elementNode;
  final bool editable;

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return TextSpan(
        children: elementNode.children
            .map((child) => child.buildSpan(textStyle: style))
            .whereType<InlineSpan>()
            .toList(growable: false),
    );
  }
}
