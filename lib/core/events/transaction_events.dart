import 'dart:async';

class TransactionEvents {
  static final TransactionEvents _instance = TransactionEvents._internal();
  factory TransactionEvents() => _instance;
  TransactionEvents._internal();

  static TransactionEvents get instance => _instance;

  // Stream controller for transaction events
  final StreamController<TransactionEvent> _controller =
      StreamController<TransactionEvent>.broadcast();

  // Stream of transaction events
  Stream<TransactionEvent> get stream => _controller.stream;

  // Emit a transaction created event
  void transactionCreated(String transactionNumber) {
    _controller.add(TransactionCreatedEvent(transactionNumber));
  }

  // Emit a transaction updated event
  void transactionUpdated(String transactionNumber) {
    _controller.add(TransactionUpdatedEvent(transactionNumber));
  }

  // Emit a transaction deleted event
  void transactionDeleted(String transactionNumber) {
    _controller.add(TransactionDeletedEvent(transactionNumber));
  }

  // Clean up resources
  void dispose() {
    _controller.close();
  }
}

// Base class for transaction events
abstract class TransactionEvent {
  final String transactionNumber;
  final DateTime timestamp;

  TransactionEvent(this.transactionNumber) : timestamp = DateTime.now();
}

// Specific event types
class TransactionCreatedEvent extends TransactionEvent {
  TransactionCreatedEvent(String transactionNumber) : super(transactionNumber);
}

class TransactionUpdatedEvent extends TransactionEvent {
  TransactionUpdatedEvent(String transactionNumber) : super(transactionNumber);
}

class TransactionDeletedEvent extends TransactionEvent {
  TransactionDeletedEvent(String transactionNumber) : super(transactionNumber);
}
