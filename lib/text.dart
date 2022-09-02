import 'package:flutter/material.dart';
import 'package:theia_flutter/node/node.dart';
import 'package:theia_flutter/node/text.dart';
import 'package:theia_flutter/theia.dart';

class InlineTextField extends StatefulWidget {
  const InlineTextField({
    Key? key,
    required this.elementNode,
    required this.theiaKey
  }) : super(key: key);

  final ElementNode elementNode;
  final TheiaKey theiaKey;

  @override
  State<StatefulWidget> createState() => InlineTextFieldState();
}

class InlineTextFieldState extends State<InlineTextField> {
  @protected
  late InlineTextEditingController editingController;

  @override
  void initState() {
    super.initState();
    editingController = InlineTextEditingController(widget.elementNode, widget.theiaKey);
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.theiaKey.currentState?.widget.readOnly ?? false;
    if (readOnly) {
      return Container(
        width: double.infinity,
        child: Text.rich(
          editingController.buildTextSpan(context: context, withComposing: false),
          style: globalTextStyle(context),
        ),
      );
    } else {
      return TextField(
        controller: editingController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            focusedBorder: InputBorder.none
        ),
        style: globalTextStyle(context),
        readOnly: widget.theiaKey.currentState?.widget.readOnly ?? false,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
  }
}

class InlineTextEditingController extends TextEditingController {
  InlineTextEditingController(this.elementNode, this.theiaKey) {
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
  final TheiaKey theiaKey;

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return TextSpan(
        children: elementNode.children
            .map((child) => child.buildSpan(textStyle: style, theiaKey: theiaKey))
            .whereType<InlineSpan>()
            .toList(growable: false),
    );
  }
}

TextStyle? globalTextStyle(BuildContext context) {
  final globalTextStyle = context
      .findAncestorWidgetOfExactType<GlobalTextStyle>();
  return globalTextStyle?.style;
}

class GlobalTextStyle extends StatelessWidget {
  GlobalTextStyle({
    Key? key,
    this.inherit = true,
    required TextStyle style,
    required this.child,
  }) : _style = style,
        super(key: key);

  final Widget child;

  TextStyle _style;
  TextStyle get style => _style;

  /// 如果为真，会合并parent的style，如果为假，则不会合并
  final bool inherit;

  @override
  Widget build(BuildContext context) {
    if (inherit) {
      final parentGlobalTextStyle = context
          .findAncestorWidgetOfExactType<GlobalTextStyle>();
      _style = parentGlobalTextStyle?.style.merge(_style) ?? style;
    }
    return child;
  }
}
