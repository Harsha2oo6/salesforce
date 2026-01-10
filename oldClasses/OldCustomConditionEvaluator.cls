// Evaluates dynamic rule strings against a nested values map.
public with sharing class CustomConditionEvaluator {
    public class CustomConditionevaluatorException extends Exception {
    }
  
    private enum ComparisonOperator {
      EQUAL,
      NOT_EQUAL,
      GREATER,
      GREATER_OR_EQUAL,
      LESS,
      LESS_OR_EQUAL
    }
  
    private enum StandardDateTimeLiteral {
      DATE_TODAY,
      DATE_TOMORROW,
      DATE_THIS_MONTH,
      DATE_THIS_YEAR,
      DATE_NEXT_YEAR
    }
  
    public static Boolean evaluateCondition(
      Map<String, Object> values,
      String condition
    ) {
      if (values == null) {
        throw new CustomConditionevaluatorException('Values map cannot be null');
      }
      if (String.isBlank(condition)) {
        throw new CustomConditionevaluatorException('Condition cannot be blank');
      }
  
      condition = normalize(condition);
      return evalExpression(values, condition);
    }
  
    private static Boolean evalExpression(
      Map<String, Object> values,
      String expr
    ) {
      String originalExpr = expr;
      expr = stripOuter(expr);
  
      // NOT
      if (expr.startsWith('!')) {
        return !evalExpression(values, stripOuter(expr.substring(1)));
      }
  
      // OR
      List<String> orParts = splitTopLevel(expr, '||');
      if (orParts.size() > 1) {
        for (String p : orParts) {
          Boolean result = evalExpression(values, p);
          if (result)
            return true;
        }
        return false;
      }
  
      // AND
      List<String> andParts = splitTopLevel(expr, '&&');
      if (andParts.size() > 1) {
        for (String p : andParts) {
          if (!evalExpression(values, p))
            return false;
        }
        return true;
      }
  
      // Truthy or binary comparison
      if (!containsOperator(expr)) {
        return isTruthy(resolveValueOrLiteral(values, expr));
      }
  
      return evalCondition(values, expr);
    }
  
    private class OperatorMatch {
      String op;
      Integer pos;
      OperatorMatch(String o, Integer p) {
        op = o;
        pos = p;
      }
    }
  
    private static Boolean evalCondition(
      Map<String, Object> values,
      String expr
    ) {
      OperatorMatch match = findOperator(expr);
      if (match == null) {
        throw new CustomConditionevaluatorException('Invalid condition: ' + expr);
      }
  
      Object left = resolveValue(values, expr.substring(0, match.pos));

      Object right = resolveValueOrLiteral(
        values,
        expr.substring(match.pos + match.op.length())
      );
  
      if (right instanceof StandardDateTimeLiteral) {
        return evalStandardDate(left, (StandardDateTimeLiteral) right, match.op);
      }
      return compare(left, right, match.op);
    }
  
    private static OperatorMatch findOperator(String s) {
      List<String> ops = new List<String>{
        '!==',
        '===',
        '!=',
        '==',
        '>=',
        '<=',
        ' contains ',
        ' in ',
        '>',
        '<'
      };
  
      Integer depth = 0;
      Boolean inString = false;
  
      for (Integer i = 0; i < s.length(); i++) {
        String ch = s.substring(i, i + 1);
  
        if (
          (ch == '"' || ch == '\'') && (i == 0 || s.substring(i - 1, i) != '\\')
        ) {
          inString = !inString;
        }
        if (inString)
          continue;
  
        if (ch == '(' || ch == '[')
          depth++;
        if (ch == ')' || ch == ']')
          depth--;
  
        if (depth == 0) {
          for (String op : ops) {
            if (
              i + op.length() <= s.length() &&
              s.substring(i, i + op.length()) == op
            ) {
              return new OperatorMatch(op.trim(), i);
            }
          }
        }
      }
      return null;
    }
  
    private static Boolean containsOperator(String s) {
      return findOperator(s) != null;
    }
  
    private static Object resolveValueOrLiteral(
      Map<String, Object> values,
      String raw
    ) {
      raw = raw.trim();
      return raw.startsWith('values[')
        ? resolveValue(values, raw)
        : parseLiteral(raw);
    }
  
    private static Object resolveValue(Map<String, Object> values, String expr) {
      if (!expr.startsWith('values[')) {
        throw new CustomConditionevaluatorException(
          'Invalid values reference: ' + expr
        );
      }
  
      List<String> path = extractPath(expr.substring(7));
      Object current = values.get(path[0]);
  
      for (Integer i = 1; i < path.size(); i++) {
        if (!(current instanceof Map<String, Object>))
          return null;
        current = ((Map<String, Object>) current).get(path[i]);
      }
      return current;
    }
  
    private static List<String> extractPath(String s) {
      List<String> parts = new List<String>();
      Integer idx = s.indexOf('[');
      parts.add(idx == -1 ? s.trim() : s.substring(0, idx).trim());
  
      while (idx != -1) {
        Integer endIndex = s.indexOf(']', idx);
        parts.add(removeQuotes(s.substring(idx + 1, endIndex).trim()));
        idx = s.indexOf('[', endIndex);
      }
      return parts;
    }
  
    private static Object parseLiteral(String s) {
      String original = s;
      s = s.trim();
  
      if (s.toLowerCase() == 'null')
        return null;
      if (s.toLowerCase() == 'true')
        return true;
      if (s.toLowerCase() == 'false')
        return false;
  
      if (
        (s.startsWith('"') && s.endsWith('"')) ||
        (s.startsWith('\'') && s.endsWith('\''))
      ) {
        s = s.substring(1, s.length() - 1);
      }
  
      StandardDateTimeLiteral std = toStandardDateLiteral(s);
      if (std != null)
        return std;
  
      Decimal d = toDecimal(s);
      Object result = d != null ? (Object) d : (Object) s;
      String typeName = result instanceof String ? 'String' : 
                       result instanceof Decimal ? 'Decimal' : 
                       result instanceof Boolean ? 'Boolean' : 
                       result == null ? 'null' : 'Object';
      return result;
    }
  
    private static Boolean compare(Object l, Object r, String op) {
      if (op == 'contains') {
        return l != null &&
          r != null &&
          String.valueOf(l).contains(String.valueOf(r));
      }
  
      if (op == 'in') {
        return r instanceof List<Object> && ((List<Object>) r).contains(l);
      }
  
      ComparisonOperator cop = toComparisonOperator(op);

      if (l == null || r == null) {
        // Handle null comparisons
        if (l == null && r == null) {
          // Both null: equal if EQUAL operator, not equal if NOT_EQUAL operator
          return cop == ComparisonOperator.EQUAL;
        }
        // One is null, one is not: equal only if NOT_EQUAL operator
        return cop == ComparisonOperator.NOT_EQUAL;
      }
  
      // Direct comparison for same types - use values exactly as they are
      if (l instanceof String && r instanceof String) {
        return compareStrings((String) l, (String) r, cop);
      }
      
      if (l instanceof Boolean && r instanceof Boolean) {
        return compareBooleans((Boolean) l, (Boolean) r, cop);
      }
      
      if (l instanceof Decimal && r instanceof Decimal) {
        return compareNumbers((Decimal) l, (Decimal) r, cop);
      }
      
      if (l instanceof Integer && r instanceof Integer) {
        return compareNumbers(Decimal.valueOf((Integer) l), Decimal.valueOf((Integer) r), cop);
      }
      
      if (l instanceof Long && r instanceof Long) {
        return compareNumbers(Decimal.valueOf((Long) l), Decimal.valueOf((Long) r), cop);
      }
      
      // Date/DateTime comparisons - only convert if both are date-like
      Date ld = toDate(l);
      Date rd = toDate(r);
      if (ld != null && rd != null) {
        return compareDates(ld, rd, cop);
      }
      
      // For DateTime comparisons, compare as DateTime if both are DateTime
      if (l instanceof Datetime && r instanceof Datetime) {
        return compareDateTimes((Datetime) l, (Datetime) r, cop);
      }
      
      // If one is DateTime and other is Date, convert Date to DateTime for comparison
      if (l instanceof Datetime && r instanceof Date) {
        Datetime rdDt = Datetime.newInstance((Date) r, Time.newInstance(0, 0, 0, 0));
        return compareDateTimes((Datetime) l, rdDt, cop);
      }
      if (l instanceof Date && r instanceof Datetime) {
        Datetime ldDt = Datetime.newInstance((Date) l, Time.newInstance(0, 0, 0, 0));
        return compareDateTimes(ldDt, (Datetime) r, cop);
      }
  
      // For numeric comparisons, only convert if both can be converted to Decimal
      // and they are not already strings (to avoid converting string "123" when comparing to actual string)
      Decimal ln = toDecimal(l);
      Decimal rn = toDecimal(r);
      if (ln != null && rn != null && !(l instanceof String) && !(r instanceof String)) {
        return compareNumbers(ln, rn, cop);
      }
  
      // Final fallback: direct object comparison using == (works for most Apex types)
      // Only use string conversion as absolute last resort
      if (cop == ComparisonOperator.EQUAL || cop == ComparisonOperator.NOT_EQUAL) {
        Boolean isEqual = (l == r);
        return cop == ComparisonOperator.EQUAL ? isEqual : !isEqual;
      }
      
      // For other operators, convert to string only if needed
      return String.valueOf(l) == String.valueOf(r);
    }
  
    private static Boolean evalStandardDate(
      Object left,
      StandardDateTimeLiteral lit,
      String op
    ) {
      Date ld = toDate(left);
      if (ld == null)
        return false;
  
      Date today = Date.today();
      Date target;
  
      switch on lit {
        when DATE_TODAY {
          target = today;
        }
        when DATE_TOMORROW {
          target = today.addDays(1);
        }
        when DATE_THIS_MONTH {
          target = Date.newInstance(today.year(), today.month(), 1);
        }
        when DATE_THIS_YEAR {
          target = Date.newInstance(today.year(), 1, 1);
        }
        when DATE_NEXT_YEAR {
          target = Date.newInstance(today.year() + 1, 1, 1);
        }
      }
  
      return compareDates(ld, target, toComparisonOperator(op));
    }
  
    private static ComparisonOperator toComparisonOperator(String s) {
      if (s == '==' || s == '===')
        return ComparisonOperator.EQUAL;
      if (s == '!=' || s == '!==')
        return ComparisonOperator.NOT_EQUAL;
      if (s == '>')
        return ComparisonOperator.GREATER;
      if (s == '>=')
        return ComparisonOperator.GREATER_OR_EQUAL;
      if (s == '<')
        return ComparisonOperator.LESS;
      if (s == '<=')
        return ComparisonOperator.LESS_OR_EQUAL;
      throw new CustomConditionevaluatorException('Unsupported operator: ' + s);
    }
  
    private static Boolean compareDates(Date l, Date r, ComparisonOperator o) {
      if (o == ComparisonOperator.EQUAL)
        return l == r;
      if (o == ComparisonOperator.NOT_EQUAL)
        return l != r;
      if (o == ComparisonOperator.GREATER)
        return l > r;
      if (o == ComparisonOperator.GREATER_OR_EQUAL)
        return l >= r;
      if (o == ComparisonOperator.LESS)
        return l < r;
      return l <= r;
    }
  
    private static Boolean compareNumbers(
      Decimal l,
      Decimal r,
      ComparisonOperator o
    ) {
      if (o == ComparisonOperator.EQUAL)
        return l == r;
      if (o == ComparisonOperator.NOT_EQUAL)
        return l != r;
      if (o == ComparisonOperator.GREATER)
        return l > r;
      if (o == ComparisonOperator.GREATER_OR_EQUAL)
        return l >= r;
      if (o == ComparisonOperator.LESS)
        return l < r;
      return l <= r;
    }
  
    private static Boolean compareStrings(
      String l,
      String r,
      ComparisonOperator o
    ) {
      if (o == ComparisonOperator.EQUAL)
        return l == r;
      if (o == ComparisonOperator.NOT_EQUAL)
        return l != r;
      if (o == ComparisonOperator.GREATER)
        return l > r;
      if (o == ComparisonOperator.GREATER_OR_EQUAL)
        return l >= r;
      if (o == ComparisonOperator.LESS)
        return l < r;
      return l <= r;
    }
  
    private static Boolean compareBooleans(
      Boolean l,
      Boolean r,
      ComparisonOperator o
    ) {
      if (o == ComparisonOperator.EQUAL)
        return l == r;
      if (o == ComparisonOperator.NOT_EQUAL)
        return l != r;
      // Boolean comparisons don't support >, <, >=, <=
      throw new CustomConditionevaluatorException(
        'Boolean values do not support comparison operators: >, <, >=, <='
      );
    }
  
    private static Boolean compareDateTimes(
      Datetime l,
      Datetime r,
      ComparisonOperator o
    ) {
      if (o == ComparisonOperator.EQUAL)
        return l == r;
      if (o == ComparisonOperator.NOT_EQUAL)
        return l != r;
      if (o == ComparisonOperator.GREATER)
        return l > r;
      if (o == ComparisonOperator.GREATER_OR_EQUAL)
        return l >= r;
      if (o == ComparisonOperator.LESS)
        return l < r;
      return l <= r;
    }
  
    private static Boolean isTruthy(Object v) {
      if (v == null)
        return false;
      if (v instanceof Boolean)
        return (Boolean) v;
      if (v instanceof String)
        return String.isNotBlank((String) v);
      if (v instanceof Decimal)
        return ((Decimal) v) != 0;
      return true;
    }
  
    private static Date toDate(Object o) {
      if (o instanceof Date)
        return (Date) o;
      if (o instanceof Datetime)
        return ((Datetime) o).date();
      return null;
    }
  
    private static Decimal toDecimal(Object o) {
      try {
        return Decimal.valueOf(String.valueOf(o));
      } catch (Exception e) {
        return null;
      }
    }
  
    private static StandardDateTimeLiteral toStandardDateLiteral(String s) {
      try {
        return StandardDateTimeLiteral.valueOf(s.toUpperCase());
      } catch (Exception e) {
        return null;
      }
    }
  
    private static String normalize(String s) {
      return stripOuter(s.replace('\n', ' ').replace('\r', ' ').trim());
    }
  
    private static String stripOuter(String s) {
      // Only strip outer parentheses if they actually match at the top level
      while (s.startsWith('(') && s.endsWith(')')) {
        // Check if the closing paren at the end matches the opening paren at the start
        Integer depth = 0;
        Boolean shouldStrip = false;
        for (Integer i = 0; i < s.length(); i++) {
          String ch = s.substring(i, i + 1);
          if (ch == '(') {
            depth++;
          } else if (ch == ')') {
            depth--;
            // If depth reaches 0 at the last character, the outer parens match
            if (depth == 0 && i == s.length() - 1) {
              shouldStrip = true;
              break;
            }
            // If depth reaches 0 before the end, the outer parens don't match
            if (depth == 0 && i < s.length() - 1) {
              shouldStrip = false;
              break;
            }
          }
        }
        if (shouldStrip) {
          s = s.substring(1, s.length() - 1).trim();
        } else {
          break;
        }
      }
      return s;
    }
  
    private static List<String> splitTopLevel(String s, String sep) {
      List<String> parts = new List<String>();
      Integer depth = 0;
      Boolean inString = false;
      Integer start = 0;
  
      for (Integer i = 0; i < s.length(); i++) {
        String ch = s.substring(i, i + 1);
  
        if (
          (ch == '"' || ch == '\'') && (i == 0 || s.substring(i - 1, i) != '\\')
        ) {
          inString = !inString;
        }
        if (inString)
          continue;
  
        if (ch == '(' || ch == '[')
          depth++;
        if (ch == ')' || ch == ']')
          depth--;
  
        if (
          depth == 0 &&
          i + sep.length() <= s.length() &&
          s.substring(i, i + sep.length()) == sep
        ) {
          parts.add(s.substring(start, i).trim());
          start = i + sep.length();
        }
      }
  
      parts.add(s.substring(start).trim());
      return parts;
    }
  
    private static String removeQuotes(String s) {
      if (
        (s.startsWith('"') && s.endsWith('"')) ||
        (s.startsWith('\'') && s.endsWith('\''))
      ) {
        return s.substring(1, s.length() - 1);
      }
      return s;
    }
  }
  