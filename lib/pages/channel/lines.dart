import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weechat/pages/channel/urlify.dart';
import 'package:weechat/relay/buffer.dart';
import 'package:weechat/relay/colors.dart';

class ChannelLines extends StatefulWidget {
  @override
  _ChannelLinesState createState() => _ChannelLinesState();
}

class _ChannelLinesState extends State<ChannelLines> {
  void _requestFocus() => FocusScope.of(context).requestFocus(FocusNode());

  @override
  Widget build(BuildContext context) {
    final buffer = Provider.of<RelayBuffer>(context, listen: true);
    return GestureDetector(
      onTap: _requestFocus,
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) =>
            _buildLineData(context, buffer.lines[index]),
        itemCount: buffer.lines.length,
        reverse: true,
      ),
    );
  }

  Widget _buildLineData(BuildContext context, LineData line) {
    final df = DateFormat.Hm().format(line.date);
    final tt = Theme.of(context).textTheme;

    final isSystem =
        ['<--', '-->', '--', '==='].any((e) => line.prefix.endsWith(e));
    final alpha = isSystem ? 100 : 255;
    final defaultColor = tt.bodyText2?.color ?? Colors.black;

    //print('<${line.prefix}> ${line.message} (${line.message.codeUnits.map((e) => e.toRadixString(16)).toList()})');

    final prefixRT = parseColors(line.prefix, defaultColor, alpha: alpha).text;
    final messageRT =
        parseColors(line.message, defaultColor, alpha: alpha).text as TextSpan;

    final dateRT = Container(
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 3),
      margin: EdgeInsets.only(right: 5),
      color: line.highlight ? Colors.redAccent : null,
      child: RichText(
        text: TextSpan(
          text: '$df',
          style: tt.bodyText2?.copyWith(
            fontFeatures: [FontFeature.tabularFigures()],
            color: line.highlight ? Colors.white : Colors.grey.withAlpha(100),
          ),
        ),
      ),
    );

    final bodyRT = RichText(
      text: TextSpan(
        children: [
          if (!isSystem) TextSpan(text: '<', style: tt.bodyText2),
          prefixRT,
          TextSpan(text: isSystem ? ' ' : '> ', style: tt.bodyText2),
          urlify(messageRT),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [dateRT, Expanded(child: bodyRT)],
      ),
    );
  }
}
