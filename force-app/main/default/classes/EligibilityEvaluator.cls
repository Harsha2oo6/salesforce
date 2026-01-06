// Evaluates dynamic rule strings against a nested values map.
public with sharing class EligibilityEvaluator {

    public class EvaluatorException extends Exception {}

    // Public entry: clean rule text then evaluate the expression.
    public static Boolean evaluateEligibility(
        Map<String, Object> values,
        String rule
    ) {
        if (values == null) {
            throw new EvaluatorException('Values map cannot be null');
        }
        
        if (String.isBlank(rule)) {
            throw new EvaluatorException('Rule cannot be blank');
        }

        rule = rule.replace('\n', ' ').replace('\r', ' ').trim();
        rule = normalizeWhitespace(rule);
        rule = stripOuterParentheses(rule);

        return evaluateExpression(values, rule);
    }

    // Recursively evaluate boolean expressions with !, &&, ||, truthy, and conditions.
    private static Boolean evaluateExpression(
        Map<String, Object> values,
        String expr
    ) {
        if (String.isBlank(expr)) {
            throw new EvaluatorException('Empty expression');
        }

        expr = stripOuterParentheses(expr.trim());

        if (expr.startsWith('!')) {
            String innerExpr = expr.substring(1).trim();
            if (innerExpr.startsWith('(')) {
                innerExpr = stripOuterParentheses(innerExpr);
            }
            return !evaluateExpression(values, innerExpr);
        }

        List<Integer> orPositions = findTopLevelOperatorPositions(expr, '||');

        if (!orPositions.isEmpty()) {
            Integer start = 0;
            for (Integer pos : orPositions) {
                String part = expr.substring(start, pos).trim();
                // Short-circuit on the first truthy OR branch.
                if (evaluateExpression(values, part)) {
                    return true;
                }
                start = pos + 2;
            }
            String lastPart = expr.substring(start).trim();
            return evaluateExpression(values, lastPart);
        }

        List<Integer> andPositions = findTopLevelOperatorPositions(expr, '&&');

        if (!andPositions.isEmpty()) {
            Integer start = 0;
            for (Integer pos : andPositions) {
                String part = expr.substring(start, pos).trim();
                // Short-circuit on the first falsy AND branch.
                if (!evaluateExpression(values, part)) {
                    return false;
                }
                start = pos + 2;
            }
            String lastPart = expr.substring(start).trim();
            return evaluateExpression(values, lastPart);
        }

        if (isTruthyCheck(expr)) {
            return evaluateTruthy(values, expr);
        }

        return evaluateCondition(values, expr);
    }

    // Locate top-level operator positions while ignoring nested groups and strings.
    private static List<Integer> findTopLevelOperatorPositions(String expr, String operator) {
        List<Integer> positions = new List<Integer>();
        Integer depth = 0;
        Boolean inString = false;
        String stringChar = '';

        for (Integer i = 0; i < expr.length() - 1; i++) {
            String ch = expr.substring(i, i + 1);
            
            if ((ch == '\'' || ch == '"') && (i == 0 || expr.substring(i - 1, i) != '\\')) {
                if (!inString) {
                    inString = true;
                    stringChar = ch;
                } else if (ch == stringChar) {
                    inString = false;
                }
                continue;
            }
            
            if (inString) continue;

            if (ch == '(') depth++;
            else if (ch == ')') depth--;

            if (depth == 0 && i + operator.length() <= expr.length()) {
                // Only capture operators that live at top-level (depth 0).
                if (expr.substring(i, i + operator.length()) == operator) {
                    positions.add(i);
                    i += operator.length() - 1;
                }
            }
        }

        return positions;
    }

    // Evaluate a comparison/containment condition (lhs op rhs).
    private static Boolean evaluateCondition(
        Map<String, Object> values,
        String condition
    ) {
        condition = stripOuterParentheses(condition.trim());

        OperatorInfo opInfo = parseOperator(condition);
        
        if (opInfo == null) {
            throw new EvaluatorException('No valid operator found in condition: "' + condition + '"');
        }

        String lhsRaw = condition.substring(0, opInfo.position).trim();
        String rhsRaw = condition.substring(opInfo.position + opInfo.operator.length()).trim();

        Object leftValue = resolveValue(values, lhsRaw);
        Object rightValue = parseLiteral(rhsRaw);

        return compareValues(leftValue, rightValue, opInfo.operator);
    }

    // Holder for parsed operator metadata.
    private class OperatorInfo {
        public String operator;
        public Integer position;
        
        public OperatorInfo(String op, Integer pos) {
            this.operator = op;
            this.position = pos;
        }
    }

    // Scan a condition for the first top-level operator.
    private static OperatorInfo parseOperator(String condition) {
        List<String> operators = new List<String>{
            '!==', '===', '!=', '==', '>=', '<=', '>', '<', ' contains ', ' in '
        };

        Integer depth = 0;
        Boolean inString = false;
        String stringChar = '';

        for (Integer i = 0; i < condition.length(); i++) {
            String ch = condition.substring(i, i + 1);
            
            if ((ch == '\'' || ch == '"') && (i == 0 || condition.substring(i - 1, i) != '\\')) {
                if (!inString) {
                    inString = true;
                    stringChar = ch;
                } else if (ch == stringChar) {
                    inString = false;
                }
                continue;
            }
            
            if (inString) continue;

            if (ch == '(' || ch == '[') depth++;           // Track nested parens/brackets.
            else if (ch == ')' || ch == ']') depth--;

            if (depth == 0) {
                for (String op : operators) {
                    if (i + op.length() <= condition.length()) {
                        String substr = condition.substring(i, i + op.length());
                        if (substr == op) {
                            return new OperatorInfo(op.trim(), i);
                        }
                    }
                }
            }
        }

        return null;
    }

    // Compare two values using supported operators (==, !=, >, contains, in, etc.).
    private static Boolean compareValues(Object left, Object right, String operator) {
        operator = operator.trim();

        if (operator == '===' || operator == '==') {
            if (left == null && right == null) return true;
            if (left == null || right == null) return false;
            return String.valueOf(left) == String.valueOf(right);
        }

        if (operator == '!==' || operator == '!=') {
            if (left == null && right == null) return false;
            if (left == null || right == null) return true;
            return String.valueOf(left) != String.valueOf(right);
        }

        if (operator == '>' || operator == '<' || operator == '>=' || operator == '<=') {
            if (left == null || right == null) {
                return false;
            }

            Decimal leftNum = toDecimal(left);
            Decimal rightNum = toDecimal(right);

            if (leftNum == null || rightNum == null) {
                throw new EvaluatorException(
                    'Cannot perform numeric comparison. Left: "' + left + '", Right: "' + right + '"'
                );
            }

            if (operator == '>') return leftNum > rightNum;
            if (operator == '<') return leftNum < rightNum;
            if (operator == '>=') return leftNum >= rightNum;
            if (operator == '<=') return leftNum <= rightNum;
        }

        if (operator == 'contains') {
            if (left == null) return false;
            if (right == null) return false;
            return String.valueOf(left).contains(String.valueOf(right));
        }

        if (operator == 'in') {
            if (left == null) return false;
            if (right == null) return false;
            
            if (right instanceof List<Object>) {
                List<Object> rightList = (List<Object>) right;
                String leftStr = String.valueOf(left);
                for (Object item : rightList) {
                    if (item != null && String.valueOf(item) == leftStr) {
                        return true;
                    }
                }
                return false;
            }
            
            throw new EvaluatorException('Right side of "in" operator must be an array: ' + right);
        }

        throw new EvaluatorException('Unknown operator: "' + operator + '"');
    }

    // Resolve a values[...] path into the provided map, walking nested maps safely.
    private static Object resolveValue(
        Map<String, Object> values,
        String expression
    ) {
        expression = expression.trim();
        
        if (!expression.startsWith('values[')) {
            throw new EvaluatorException('Invalid value expression. Expected "values[...]" but got: "' + expression + '"');
        }

        expression = expression.substring(7);
        expression = cleanExpression(expression);

        List<String> pathParts = parseValuePath(expression);
        
        if (pathParts.isEmpty()) {
            throw new EvaluatorException('Empty path in value expression');
        }

        String section = pathParts[0];
        
        if (!values.containsKey(section)) {
            return null;
        }

        Object current = values.get(section);

        for (Integer i = 1; i < pathParts.size(); i++) {
            if (current == null) {
                return null;
            }
            
            if (!(current instanceof Map<String, Object>)) {
                // Bail out when the path dives into a non-map.
                return null;
            }
            
            Map<String, Object> currentMap = (Map<String, Object>) current;
            String key = pathParts[i];
            
            current = currentMap.get(key);
        }

        return current;
    }

    // Normalize a values[...] inner expression without stripping brackets.
    private static String cleanExpression(String expr) {
        // Keep brackets intact; only trim whitespace and outer parentheses.
        expr = expr.trim();
        expr = stripOuterParentheses(expr);
        return expr;
    }

    // Break values[...] path into keys, handling bracketed segments and quotes.
    private static List<String> parseValuePath(String expression) {
        List<String> parts = new List<String>();
        
        Integer firstBracket = expression.indexOf('[');
        
        if (firstBracket == -1) {
            parts.add(expression.trim());
            return parts;
        }
        
        parts.add(expression.substring(0, firstBracket).trim());
        
        String remaining = expression.substring(firstBracket);
        
        Integer pos = 0;
        while (pos < remaining.length()) {
            Integer start = remaining.indexOf('[', pos);
            if (start == -1) break;
            
            Integer endIdx = findMatchingBracket(remaining, start);
            if (endIdx == -1) break;
            
            String content = remaining.substring(start + 1, endIdx).trim();
            
            content = removeQuotes(content);
            
            if (String.isNotBlank(content)) {
                parts.add(content);
            }
            
            pos = endIdx + 1;
        }
        
        return parts;
    }

    // Find matching ] for a [ while respecting nested brackets and strings.
    private static Integer findMatchingBracket(String str, Integer openPos) {
        Integer depth = 0;
        Boolean inString = false;
        String stringChar = '';
        
        for (Integer i = openPos; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            
            if ((ch == '\'' || ch == '"') && (i == 0 || str.substring(i - 1, i) != '\\')) {
                if (!inString) {
                    inString = true;
                    stringChar = ch;
                } else if (ch == stringChar) {
                    inString = false;
                }
                continue;
            }
            
            if (!inString) {
                if (ch == '[') depth++;
                else if (ch == ']') {
                    depth--;
                    if (depth == 0) return i; // Found the matching closing bracket.
                }
            }
        }
        
        return -1;
    }

    // Strip surrounding single/double quotes if present.
    private static String removeQuotes(String str) {
        str = str.trim();
        if (str.length() >= 2) {
            String first = str.substring(0, 1);
            String last = str.substring(str.length() - 1);
            if ((first == '\'' && last == '\'') || (first == '"' && last == '"')) {
                return str.substring(1, str.length() - 1);
            }
        }
        return str;
    }

    // Parse a literal into Apex types: null, booleans, numbers, strings, arrays.
    private static Object parseLiteral(String raw) {
        raw = raw.trim();
        
        if (isNullLiteral(raw)) {
            return null;
        }
        
        if (raw.toLowerCase() == 'true') {
            return true;
        }
        if (raw.toLowerCase() == 'false') {
            return false;
        }
        
        if (raw.startsWith('[') && raw.endsWith(']')) {
            return parseArrayLiteral(raw);
        }
        
        if ((raw.startsWith('\'') && raw.endsWith('\'')) || 
            (raw.startsWith('"') && raw.endsWith('"'))) {
            return raw.substring(1, raw.length() - 1);
        }
        
        Decimal num = toDecimal(raw);
        if (num != null) {
            return num;
        }
        
        return raw;
    }

    // Parse a [a, b, c] literal into a List<Object>.
    private static List<Object> parseArrayLiteral(String arrayStr) {
        List<Object> result = new List<Object>();
        
        arrayStr = arrayStr.substring(1, arrayStr.length() - 1).trim();
        
        if (String.isBlank(arrayStr)) {
            return result;
        }
        
        List<String> items = splitByComma(arrayStr);
        
        for (String item : items) {
            item = item.trim();
            result.add(parseLiteral(item));
        }
        
        return result;
    }

    // Split by commas while respecting quoted segments.
    private static List<String> splitByComma(String str) {
        List<String> parts = new List<String>();
        Boolean inString = false;
        String stringChar = '';
        Integer start = 0;
        
        for (Integer i = 0; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            
            if ((ch == '\'' || ch == '"') && (i == 0 || str.substring(i - 1, i) != '\\')) {
                if (!inString) {
                    inString = true;
                    stringChar = ch;
                } else if (ch == stringChar) {
                    inString = false;
                }
                continue;
            }
            
            if (!inString && ch == ',') {
                parts.add(str.substring(start, i));
                start = i + 1;
            }
        }
        
        if (start < str.length()) {
            parts.add(str.substring(start));
        }
        
        return parts;
    }

    // Determine if expression is a standalone truthy check (no operator).
    private static Boolean isTruthyCheck(String expr) {
        expr = expr.trim();
        
        OperatorInfo opInfo = parseOperator(expr);
        return opInfo == null;
    }

    // Evaluate truthiness for literals or values[...] references (with optional !).
    private static Boolean evaluateTruthy(Map<String, Object> values, String expr) {
        expr = expr.trim();
        
        if (expr.startsWith('!')) {
            String innerExpr = expr.substring(1).trim();
            if (innerExpr.startsWith('(')) {
                innerExpr = stripOuterParentheses(innerExpr);
            }
            return !evaluateTruthy(values, innerExpr);
        }
        
        if (expr.startsWith('values[')) {
            Object value = resolveValue(values, expr);
            return isTruthy(value);
        }
        
        Object value = parseLiteral(expr);
        return isTruthy(value);
    }

    // Truthiness rules across supported types.
    private static Boolean isTruthy(Object value) {
        if (value == null) return false;
        if (value instanceof Boolean) return (Boolean) value;
        if (value instanceof String) return String.isNotBlank((String) value);
        if (value instanceof Decimal) return ((Decimal) value) != 0;
        if (value instanceof Integer) return ((Integer) value) != 0;
        if (value instanceof List<Object>) return !((List<Object>) value).isEmpty();
        return true;
    }

    // Remove redundant outer parentheses while preserving inner structure.
    private static String stripOuterParentheses(String input) {
        input = input.trim();
        
        while (input.length() >= 2 && input.startsWith('(') && input.endsWith(')')) {
            Integer depth = 0;
            Boolean firstMatchesLast = false;
            Boolean inString = false;
            String stringChar = '';
            
            for (Integer i = 0; i < input.length(); i++) {
                String ch = input.substring(i, i + 1);
                
                if ((ch == '\'' || ch == '"') && (i == 0 || input.substring(i - 1, i) != '\\')) {
                    if (!inString) {
                        inString = true;
                        stringChar = ch;
                    } else if (ch == stringChar) {
                        inString = false;
                    }
                    continue;
                }
                
                if (!inString) {
                    if (ch == '(') depth++;
                    else if (ch == ')') depth--;
                    
                    if (depth == 0 && i < input.length() - 1) {
                        // Outer pair isn't the sole wrapper; stop stripping.
                        firstMatchesLast = false;
                        break;
                    }
                    if (depth == 0 && i == input.length() - 1) {
                        firstMatchesLast = true;
                    }
                }
            }
            
            if (firstMatchesLast) {
                input = input.substring(1, input.length() - 1).trim();
            } else {
                break;
            }
        }
        
        return input;
    }

    // Check if a literal represents null.
    private static Boolean isNullLiteral(String value) {
        if (value == null) return true;
        String lower = value.toLowerCase().trim();
        return lower == 'null' || lower == '\'null\'' || lower == '"null"';
    }

    // Convert supported types/strings to Decimal when possible.
    private static Decimal toDecimal(Object value) {
        if (value == null) return null;
        
        if (value instanceof Decimal) return (Decimal) value;
        if (value instanceof Integer) return Decimal.valueOf((Integer) value);
        if (value instanceof Long) return Decimal.valueOf((Long) value);
        if (value instanceof Double) return Decimal.valueOf((Double) value);
        
        String str = String.valueOf(value).trim();
        
        try {
            if (str.startsWith('-')) {
                // Handle leading negative sign separately from numeric validation.
                str = str.substring(1);
                if (isValidNumberString(str)) {
                    return -Decimal.valueOf(str);
                }
            } else if (isValidNumberString(str)) {
                return Decimal.valueOf(str);
            }
        } catch (Exception e) {
        }
        
        return null;
    }

    // Validate a numeric string (optional leading -, single dot).
    private static Boolean isValidNumberString(String str) {
        if (String.isBlank(str)) return false;
        
        Boolean hasDecimal = false;
        for (Integer i = 0; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            if (ch == '.') {
                if (hasDecimal) return false;
                hasDecimal = true;
            } else if (!ch.isNumeric()) {
                return false;
            }
        }
        return true;
    }

    // Collapse consecutive spaces to single spaces.
    private static String normalizeWhitespace(String input) {
        if (String.isBlank(input)) return input;
        
        while (input.contains('  ')) {
            input = input.replace('  ', ' ');
        }
        
        return input;
    }
}
