import "package:polymorphic_bot/api.dart";
import "package:math_expressions/math_expressions.dart";

import "math.dart";

import "dart:math" as Math;

Parser parser = new Parser();
ContextModel context = new ContextModel()
  ..bindVariableName("pi", new Number(Math.PI));
Storage acks;
Storage fibs;
Storage factorials;

@PluginInstance()
Plugin plugin;

@BotInstance()
BotConnector bot;

void main(_, Plugin plugin) => plugin.load();

@Start()
void start() {
  acks = plugin.getStorage("ack");
  fibs = plugin.getStorage("fibs");
  factorials = plugin.getStorage("factorials");
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

@Command("factorial")
void factorialCommand(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("> Usage: factorial <n>");
    return;
  }
  
  int n;
  
  try {
    n = int.parse(event.args[0]);
  } catch (e) {
    event.reply("> ERROR: Invalid Number.");
    return;
  }
  
  if (n < 0) {
    event.reply("> ERROR: Number can't be less than zero.");
    return;
  }
  
  int result;
  
  if (factorials.map.containsKey(n.toString())) {
    result = factorials.get(n.toString());
  } else {
    result = factorial(n);
    factorials.set(n.toString(), result);
  }
  
  event.reply("> factorial(${result}) = ${result}");
}

@Command("fib")
void fibCommand(CommandEvent event) {
  if (event.args.length != 1) {
    event.reply("> Usage: fib <n>");
    return;
  }
  
  int n;
  
  try {
    n = int.parse(event.args[0]);
  } catch (e) {
    event.reply("> ERROR: Invalid Number.");
    return;
  }
  
  int result;
  
  if (fibs.map.containsKey(n.toString())) {
    result = factorials.get(n.toString());
  } else {
    result = fib(n);
    fibs.set(n.toString(), result);
  }
  
  event.reply("> fib(${result}) = ${result}");
}

@Command("ack-calcs")
void ackCalcs(CommandEvent event) {
  event.reply(
      "> Still Calculating: ${calculatingAcks.map((it) => "ack(" + it.replaceAll(",", ", ") + ")").join(", ")}");
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

  calculatingAcks.add(key);
  ackAsync(m, n).then((value) {
    calculatingAcks.remove(key);
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

List<String> calculatingAcks = [];

