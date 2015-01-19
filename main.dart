import "package:polymorphic_bot/api.dart";
import "package:math_expressions/math_expressions.dart";

import "dart:math" as Math;
import "dart:async";

Parser parser = new Parser();
ContextModel context = new ContextModel()
  ..bindVariableName("pi", new Number(Math.PI));
Storage acks;

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

void main(_, Plugin plugin) => plugin.load();

@Start()
void start() {
  acks = plugin.getStorage("ack");
}

@Command("calc")
void calc(CommandEvent event) {
  if (event.args.isEmpty) {
    event.reply("> Usage: calc <expression>");
  } else {
    try {
      Expression exp = parser.parse(event.args.join(" "));
      var answer = exp.evaluate(EvaluationType.REAL, context);
      event.reply("> ${answer}");

      context.bindVariableName("ans", new Number(answer));
    } catch (e) {
      event.reply("> ERROR: ${e}");
    }
  }
}

@Command("ack-calcs")
void ackCalcs(CommandEvent event) {
  event.reply(
      "> Still Calculating: ${calculating.map((it) => "ack(" + it.replaceAll(",", ", ") + ")").join(", ")}");
}

@Command("ack")
void ackCommand(CommandEvent event) {
  if (event.args.length != 2) {
    event.reply("> Usage: ack <m> <n>");
    return;
  }
  int m;
  int n;

  try {
    m = int.parse(event.args[0]);
    n = int.parse(event.args[1]);
  } catch (e) {
    event.reply("> ERROR: ${e}");
    return;
  }

  var key = "${m},${n}";

  if (acks.map.containsKey(key)) {
    event.reply("> ack(${m}, ${n}) = ${acks.get(key)}");
    return;
  }

  bool ping = false;

  calculating.add(key);
  ackAsync(m, n).then((value) {
    calculating.remove(key);
    acks.set(key, value);

    if (ping) {
      event.reply("${event.user}: ack(${m}, ${n}) = ${value}");
    } else {
      event.reply("> ack(${m}, ${n}) = ${value}");
    }
  }).timeout(new Duration(seconds: 30), onTimeout: () {
    event.reply(
        "> ack(${m}, ${n}) is taking a while to calculate. We are still chugging along though.");
    ping = true;
  });
}

List<String> calculating = [];

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
