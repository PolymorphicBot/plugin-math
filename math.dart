import "dart:async";
import "dart:math";

Future<int> ackAsync(int m, int n, {int pergo: 200}) {
  var stack = <int>[];
  var completer = new Completer<int>();

  Function go;

  go = () {
    for (var i = 1; i <= pergo; i++) {
      if (m == 0) {
        if (stack.isEmpty) {
          completer.complete(n + 1);
          return;
        } else {
          m = stack.removeLast() - 1;
          n = n + 1;
        }
      } else if (n == 0) {
        m = m - 1;
        n = 1;
      } else {
        stack.add(m);
        n = n - 1;
      }
    }

    new Future(go);
  };

  new Future(go);

  return completer.future;
}

int factorial(int n) {
  if (n < 0) {
    throw new ArgumentError('Argument less than 0');
  }

  int result = 1;

  for (int i = 1; i <= n; i++) {
    result *= i;
  }

  return result;
}

int fib(int n) {
  if (n == 0 || n == 1) {
    return n;
  }
  
  var prev = 1;
  var current = 1;
  
  for (var i = 2; i < n; i++) {
    var next = prev + current;
    prev = current;
    current = next;
  }
  
  return current;
}
