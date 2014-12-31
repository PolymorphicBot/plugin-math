import "package:polymorphic_bot/api.dart";
import "package:math_expressions/math_expressions.dart";

import "dart:math" as Math;

BotConnector bot;
Parser parser = new Parser();
ContextModel context = new ContextModel();

void main(_, Plugin plugin) {
  bot = plugin.getBot();

  context.bindVariableName("pi", new Number(Math.PI));
  
  bot.command("calc", (event) {
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
  });
}
