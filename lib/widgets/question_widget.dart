import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionWidget extends StatefulWidget {
  final QuestionModel question;
  final void Function(String) onSubmit;
  QuestionWidget({required this.question, required this.onSubmit});

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.question.question, style: TextStyle(fontSize: 20)),
        SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter answer',
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onSubmit(_ctrl.text);
                _ctrl.clear();
              },
              child: Text('Submit'),
            ),
            SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}
