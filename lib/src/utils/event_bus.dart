import 'dart:async';

class Event {
  String name;
  dynamic data;

  Event(this.name, {this.data});
}

class EventBus {
  factory EventBus() => _getInstance();
  static EventBus? _eventBus;

  static EventBus get singlton => _getInstance();

  late StreamController _controller;

  Map<dynamic, Map<dynamic, StreamSubscription>> _subscriberByEventType = Map();

  EventBus._internal() {
    _controller = StreamController.broadcast();
  }

  static EventBus _getInstance() {
    if (_eventBus == null) {
      _eventBus = EventBus._internal();
    }
    return _eventBus!;
  }

  StreamSubscription<T> register<T>(dynamic subscriber, void onEvent(T data)) {
    //获取订阅的事件
    Map<dynamic, StreamSubscription>? subscriptionsByEventType = _subscriberByEventType[subscriber];
    if (subscriptionsByEventType == null) {
      subscriptionsByEventType = Map();
      _subscriberByEventType[subscriber] = subscriptionsByEventType;
    } else {
      if (subscriptionsByEventType.containsKey(T)) {
        print("already register this  event");
        return (subscriptionsByEventType[T]!
          ..onData((data) {
            onEvent(data);
          })) as StreamSubscription<T>;
      }
    }
    StreamSubscription<T> subscription = _on<T>().listen(onEvent);

    subscriptionsByEventType[T] = subscription;

    return subscription;
  }

  unregister(dynamic subscriber) {
    Map<dynamic, StreamSubscription>? subscriptionsByEventType = _subscriberByEventType[subscriber];
    if (subscriptionsByEventType != null) {
      subscriptionsByEventType.values.forEach((sub) {
        sub.cancel();
      });
      _subscriberByEventType.remove(subscriber);
    }
  }

  post(dynamic event) {
    _controller.add(event);
  }

  Stream<T> _on<T>() {
    if (T == dynamic) {
      return _controller.stream.cast<T>();
    } else {
      return _controller.stream.where((event) {
        return event is T;
      }).cast<T>();
    }
  }
}
