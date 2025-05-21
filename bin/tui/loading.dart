import 'dart:async';
import 'dart:io';

class Loading {
  final List<String> spinnerFrames = ['|', '/', '-', '\\'];
  final String text;
  final Duration interval;
  bool _running = false;
  int _index = 0;
  late Timer _timer;

  Loading({this.text = 'Loading', this.interval = const Duration(milliseconds: 100)});

  void start() {
    _running = true;
    _timer = Timer.periodic(interval, (_) {
      stdout.write('\r\x1b[38;5;39m$text ${spinnerFrames[_index % spinnerFrames.length]}\x1b[0m');
      _index++;
    });
  }

  Future<void> stop() async {
    _running = false;
    _timer.cancel();
    print('\x1b[38;5;39m$text [Done]\x1b[0m'); 
    stdout.write('\r');
  }
}
