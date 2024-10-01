import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomTextLongPressWidget extends StatelessWidget {
  String? message;
  TextStyle? textStyle;
  CustomTextLongPressWidget({super.key, this.message, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return SelectableAutoLinkText(message ?? "***",
        linkStyle: const TextStyle(color: Colors.blueAccent),
        highlightedLinkStyle: TextStyle(
          color: Colors.blueAccent,
          backgroundColor: Colors.blueAccent.withAlpha(0x33),
        ),
        onTap: (url) => launchUrl(Uri.parse(url)),
        onLongPress: (url) => Share.share(url),
        contextMenuBuilder: (context, editableTextState) {
          final TextEditingValue value = editableTextState.textEditingValue;
          final List<ContextMenuButtonItem> buttonItems = [];
          buttonItems.insertAll(
            0,
            [
              ContextMenuButtonItem(
                label: '举报',
                onPressed: () {
                  // Implement your logic for handling "举报" here
                  // This example shows a simple dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('举报'),
                        content: const Text('您确定要举报此内容吗？'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('内容已举报.'),
                                ),
                              );
                            },
                            child: Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Add your actual reporting logic here
                              Navigator.pop(context);
                            },
                            child: Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ContextMenuButtonItem(
                label: '复制',
                onPressed: () {
                  if (value.selection.baseOffset !=
                      value.selection.extentOffset) {
                    final selectedText = value.selection.baseOffset !=
                            value.selection.extentOffset
                        ? value.text.substring(value.selection.baseOffset,
                            value.selection.extentOffset)
                        : '';
                    final clipboard = ClipboardData(text: selectedText);
                    Clipboard.setData(clipboard);
                  }
                  //   editableTextState.selectAll(SelectionChangedCause.forcePress);
                  // // Access the selected text and copy it to clipboard
                  // final clipboard = ClipboardData(text: value.text);
                  // Clipboard.setData(clipboard);
                },
              ),
              ContextMenuButtonItem(
                label: '分享',
                onPressed: () {
                  // Share the selected text (replace with your sharing logic)
                  final textToShare = value.text;
                  Share.share(textToShare);
                },
              ),
            ],
          );
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: buttonItems,
          );
        },
        style: textStyle);
  }
}
