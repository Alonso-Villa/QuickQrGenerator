class EmailMessage {
  List<String> to;
  EmailMessageData message;

  EmailMessage({required this.to, required this.message});

  // Convert the EmailMessage object to a Map
  Map<String, dynamic> toMap() {
    return {
      'to': to,
      'message': {
        'subject': message.subject,
        'text': message.text,
        'html': message.html,
      },
    };
  }
}

class EmailMessageData {
  String subject;
  String text;
  String html;

  EmailMessageData(
      {required this.subject, required this.text, required this.html});
}
