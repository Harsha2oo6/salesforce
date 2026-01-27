/**
 * Evaluates dynamic JavaScript-like condition strings against a nested values map.
 * Handles complex expressions including nested values[...] paths, unquoted strings,
 * standard date/time literals, and various comparison operators.
 */
public with sharing class CustomConditionEvaluator {

    public class CustomConditionevaluatorException extends Exception {}

    private class OperatorInfo {
        public String operator;
        public Integer position;
        
        public OperatorInfo(String op, Integer pos) {
            this.operator = op;
            this.position = pos;
        }
    }
    
    private class StringState {
        public Boolean inString = false;
        public String stringChar = '';
        
        public Boolean updateState(String ch, Integer i, String expr) {
            if ((ch == '\'' || ch == '"') && (i == 0 || expr.substring(i - 1, i) != '\\')) {
                if (!inString) {
                    inString = true;
                    stringChar = ch;
                } else if (ch == stringChar) {
                    inString = false;
                }
                return true;
            }
            return false;
        }
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

    /**
     * Main entry point: evaluates a condition string against a values map.
     * 
     * @param values The nested map containing data to evaluate against
     * @param condition The condition string to evaluate (e.g., "values[KEY1[KEY2]] === 'value'")
     * @return Boolean result of the condition evaluation
     * @throws CustomConditionevaluatorException if values is null or condition is blank
     */
    public static Boolean evaluateCondition(
        Map<String, Object> values,
        String condition
    ) {
        if (values == null) {
            throw new CustomConditionEvaluatorException('Values map cannot be null');
        }
        
        if (String.isBlank(condition)) {
            throw new CustomConditionEvaluatorException('Condition cannot be blank');
        }

        // Normalize the condition string
        condition = condition.replace('\n', ' ').replace('\r', ' ').trim();
        condition = normalizeWhitespace(condition);
        condition = stripOuterParentheses(condition);

        return evaluateExpression(values, condition);
    }

    /**
     * Recursively evaluates boolean expressions with !, &&, ||, truthy checks, and conditions.
     * Handles operator precedence: ! > && > ||
     */
    private static Boolean evaluateExpression(
        Map<String, Object> values,
        String expr
    ) {
        if (String.isBlank(expr)) {
            throw new CustomConditionEvaluatorException('Empty expression');
        }

        expr = stripOuterParentheses(expr.trim());

        // Handle negation operator (!)
        if (expr.startsWith('!')) {
            String innerExpr = expr.substring(1).trim();
            if (innerExpr.startsWith('(')) {
                innerExpr = stripOuterParentheses(innerExpr);
            }
            return !evaluateExpression(values, innerExpr);
        }

        // Handle OR operator (||) - lowest precedence
        List<Integer> orPositions = findTopLevelOperatorPositions(expr, '||');
        if (!orPositions.isEmpty()) {
            Integer start = 0;
            for (Integer pos : orPositions) {
                String part = expr.substring(start, pos).trim();
                // Short-circuit: return true on first truthy OR branch
                if (evaluateExpression(values, part)) {
                    return true;
                }
                start = pos + 2;
            }
            String lastPart = expr.substring(start).trim();
            return evaluateExpression(values, lastPart);
        }

        // Handle AND operator (&&) - higher precedence than ||
        List<Integer> andPositions = findTopLevelOperatorPositions(expr, '&&');
        if (!andPositions.isEmpty()) {
            Integer start = 0;
            for (Integer pos : andPositions) {
                String part = expr.substring(start, pos).trim();
                // Short-circuit: return false on first falsy AND branch
                if (!evaluateExpression(values, part)) {
                    return false;
                }
                start = pos + 2;
            }
            String lastPart = expr.substring(start).trim();
            return evaluateExpression(values, lastPart);
        }

        // Check if this is a standalone truthy check (no comparison operator)
        if (isTruthyCheck(expr)) {
            return evaluateTruthy(values, expr);
        }

        // Otherwise, evaluate as a comparison condition
        return evalCondition(values, expr);
    }

    /**
     * Finds positions of top-level operators (ignoring nested parentheses, brackets, and strings).
     */
    private static List<Integer> findTopLevelOperatorPositions(String expr, String operator) {
        List<Integer> positions = new List<Integer>();
        Integer depth = 0;
        StringState strState = new StringState();

        for (Integer i = 0; i < expr.length() - 1; i++) {
            String ch = expr.substring(i, i + 1);
            
            // Handle string delimiters (single or double quotes)
            if (strState.updateState(ch, i, expr)) {
                continue;
            }
            
            if (strState.inString) continue;

            // Track nesting depth
            if (ch == '(') depth++;
            else if (ch == ')') depth--;

            // Only capture operators at top level (depth 0)
            if (depth == 0 && i + operator.length() <= expr.length()) {
                if (expr.substring(i, i + operator.length()) == operator) {
                    positions.add(i);
                    i += operator.length() - 1; // Skip past the operator
                }
            }
        }

        return positions;
    }

    /**
     * Determines if an expression is a standalone truthy check (no comparison operator).
     */
    private static Boolean isTruthyCheck(String expr) {
        expr = expr.trim();
        OperatorInfo opInfo = parseOperator(expr);
        return opInfo == null;
    }

    /**
     * Evaluates truthiness for literals or values[...] references (with optional !).
     */
    private static Boolean evaluateTruthy(Map<String, Object> values, String expr) {
        expr = expr.trim();
        
        // Handle negation
        if (expr.startsWith('!')) {
            String innerExpr = expr.substring(1).trim();
            if (innerExpr.startsWith('(')) {
                innerExpr = stripOuterParentheses(innerExpr);
            }
            return !evaluateTruthy(values, innerExpr);
        }
        
        // Handle values[...] references
        if (expr.startsWith('values[')) {
            Object value = resolveValue(values, expr);
            return isTruthy(value);
        }
        
        // Handle literals
        Object value = parseLiteral(expr);
        return isTruthy(value);
    }

    /**
     * Determines truthiness of a value based on type.
     */
    private static Boolean isTruthy(Object value) {
        if (value == null) return false;
        if (value instanceof Boolean) return (Boolean) value;
        if (value instanceof String) return String.isNotBlank((String) value);
        if (value instanceof Decimal) return ((Decimal) value) != 0;
        if (value instanceof Integer) return ((Integer) value) != 0;
        if (value instanceof List<Object>) return !((List<Object>) value).isEmpty();
        return true;
    }
    
    /**
     * Evaluates a comparison condition (lhs op rhs).
     * Handles both values[...] expressions and literals on both sides.
     */
    private static Boolean evalCondition(
        Map<String, Object> values,
        String condition
    ) {
        condition = stripOuterParentheses(condition.trim());
        OperatorInfo opInfo = parseOperator(condition);
        
        if (opInfo == null) {
            throw new CustomConditionEvaluatorException('No valid operator found in condition: "' + condition + '"');
        }

        // Split condition into left and right hand sides
        String lhsRaw = condition.substring(0, opInfo.position).trim();
        String rhsRaw = condition.substring(opInfo.position + opInfo.operator.length()).trim();

        // Resolve left-hand side (must be a values[...] expression)
        Object leftValue = resolveValue(values, lhsRaw);
        
        // Resolve right-hand side (can be values[...] expression OR literal)
        Object rightValue = resolveRightHandSide(values, rhsRaw);

        // Handle standard date/time literals specially
        if (rightValue instanceof StandardDateTimeLiteral) {
            return evaluateStandardDateTimeLiteral(leftValue, (StandardDateTimeLiteral) rightValue, opInfo.operator);
        }

        // Perform the comparison
        return compareValues(leftValue, rightValue, opInfo.operator);
    }

    /**
     * Resolves the right-hand side of a condition.
     * Can be either a values[...] expression or a literal (string, number, null, etc.).
     */
    private static Object resolveRightHandSide(Map<String, Object> values, String rhsRaw) {
        rhsRaw = rhsRaw.trim();
        
        // Check if RHS is a values[...] expression
        if (rhsRaw.startsWith('values[')) {
            return resolveValue(values, rhsRaw);
        }
        
        // Otherwise, parse as a literal
        return parseLiteral(rhsRaw);
    }

    /**
     * Scans a condition for the first top-level operator.
     * Respects nested parentheses, brackets, and strings.
     */
    private static OperatorInfo parseOperator(String condition) {
        // Order matters: longer operators first to avoid partial matches
        List<String> operators = new List<String>{
            '!==', '===', '!=', '==', '>=', '<=', ' contains ', ' in ', '>', '<'
        };

        Integer depth = 0;
        StringState strState = new StringState();

        for (Integer i = 0; i < condition.length(); i++) {
            String ch = condition.substring(i, i + 1);
            
            // Handle string delimiters
            if (strState.updateState(ch, i, condition)) {
                continue;
            }
            
            if (strState.inString) continue;

            // Track nesting depth for parentheses and brackets
            if (ch == '(' || ch == '[') depth++;
            else if (ch == ')' || ch == ']') depth--;

            // Only check for operators at top level (depth 0)
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
    
    /**
     * Resolves a values[...] path into the provided map, walking nested maps safely.
     * Example: values[PRODUCT_OPPORTUNITY[CreatedDate]] resolves to values.get('PRODUCT_OPPORTUNITY').get('CreatedDate')
     */
    private static Object resolveValue(
        Map<String, Object> values,
        String expression
    ) {
        expression = expression.trim();
        
        if (!expression.startsWith('values[')) {
            throw new CustomConditionEvaluatorException('Invalid value expression. Expected "values[...]" but got: "' + expression + '"');
        }

        // Remove "values[" prefix
        expression = expression.substring(7);
        expression = cleanExpression(expression);

        // Parse the path into individual keys
        List<String> pathParts = parseValuePath(expression);
        
        if (pathParts.isEmpty()) {
            throw new CustomConditionEvaluatorException('Empty path in value expression');
        }

        // Start with the first key
        String section = pathParts[0];
        
        if (!values.containsKey(section)) {
            return null;
        }

        Object current = values.get(section);

        // Navigate through nested maps
        for (Integer i = 1; i < pathParts.size(); i++) {
            if (current == null) {
                return null;
            }
            
            if (!(current instanceof Map<String, Object>)) {
                // Path dives into a non-map value - return null
                return null;
            }
            
            Map<String, Object> currentMap = (Map<String, Object>) current;
            String key = pathParts[i];
            
            current = currentMap.get(key);
        }

        return current;
    }

    /**
     * Normalizes a values[...] inner expression without stripping brackets.
     */
    private static String cleanExpression(String expr) {
        expr = expr.trim();
        expr = stripOuterParentheses(expr);
        return expr;
    }

    /**
     * Breaks a values[...] path into keys, handling bracketed segments and quotes.
     * Example: "PRODUCT_OPPORTUNITY[CreatedDate]" -> ["PRODUCT_OPPORTUNITY", "CreatedDate"]
     */
    private static List<String> parseValuePath(String expression) {
        List<String> parts = new List<String>();
        
        Integer firstBracket = expression.indexOf('[');
        
        if (firstBracket == -1) {
            // No brackets, just a single key
            // But if there's a trailing ']', remove it (e.g., "CALL_STATUS__c]" -> "CALL_STATUS__c")
            String key = expression.trim();
            // if (key.endsWith(']') && !key.contains('[')) {
            //     key = key.substring(0, key.length() - 1).trim();
            // }
            parts.add(key);
            return parts;
        }
        
        // Add the first key (before first bracket)
        parts.add(expression.substring(0, firstBracket).trim());
        
        String remaining = expression.substring(firstBracket);
        
        // Extract all bracketed segments
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

    /**
     * Finds the matching closing bracket ] for an opening bracket [.
     * Respects nested brackets and strings.
     */
    private static Integer findMatchingBracket(String str, Integer openPos) {
        Integer depth = 0;
        StringState strState = new StringState();
        
        for (Integer i = openPos; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            
            // Handle string delimiters
            if (strState.updateState(ch, i, str)) {
                continue;
            }
            
            if (!strState.inString) {
                if (ch == '[') depth++;
                else if (ch == ']') {
                    depth--;
                    if (depth == 0) return i; // Found matching closing bracket
                }
            }
        }
        
        return -1; // No matching bracket found
    }
    
    /**
     * Parses a literal into Apex types: null, booleans, numbers, strings, arrays, or standard literals.
     * Handles both quoted and unquoted strings.
     */
    private static Object parseLiteral(String raw) {
        raw = raw.trim();
        
        // Check for null
        if (isNullLiteral(raw)) {
            return null;
        }
        
        // Check for booleans
        if (raw.toLowerCase() == 'true') {
            return true;
        }
        if (raw.toLowerCase() == 'false') {
            return false;
        }
        
        // Check for array literals
        if (raw.startsWith('[') && raw.endsWith(']')) {
            return parseArrayLiteral(raw);
        }
        
        // Check for quoted strings (single or double quotes)
        if ((raw.startsWith('\'') && raw.endsWith('\'')) || 
            (raw.startsWith('"') && raw.endsWith('"'))) {
            String innerValue = raw.substring(1, raw.length() - 1);
            return resolveStandardLiteralOrString(innerValue);
        }
        
        // Check for numeric literals
        Decimal num = toDecimal(raw);
        if (num != null) {
            return num;
        }
        
        // Otherwise, treat as unquoted string or standard literal
        return resolveStandardLiteralOrString(raw);
    }

    /**
     * Resolves well-known standard literals (e.g. DATE_TODAY) to enum values.
     * If the input is not a standard literal, returns the original string.
     */
    private static Object resolveStandardLiteralOrString(String value) {
        if (String.isBlank(value)) {
            return value;
        }

        StandardDateTimeLiteral std = toStandardDateTimeLiteral(value);
        return std != null ? std : (Object) value;
    }

    /**
     * Parses an array literal [a, b, c] into a List<Object>.
     */
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

    /**
     * Splits a string by commas while respecting quoted segments.
     */
    private static List<String> splitByComma(String str) {
        List<String> parts = new List<String>();
        StringState strState = new StringState();
        Integer start = 0;
        
        for (Integer i = 0; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            
            // Handle string delimiters
            if (strState.updateState(ch, i, str)) {
                continue;
            }
            
            // Split on comma only when not in a string
            if (!strState.inString && ch == ',') {
                parts.add(str.substring(start, i));
                start = i + 1;
            }
        }
        
        // Add the last part
        if (start < str.length()) {
            parts.add(str.substring(start));
        }
        
        return parts;
    }

    /**
     * Checks if a literal represents null.
     */
    private static Boolean isNullLiteral(String value) {
        if (value == null) return true;
        String lower = value.toLowerCase().trim();
        return lower == 'null' || lower == '\'null\'' || lower == '"null"';
    }

    /**
     * Converts a string to a StandardDateTimeLiteral enum value, or null if not matched.
     */
    private static StandardDateTimeLiteral toStandardDateTimeLiteral(String literal) {
        if (String.isBlank(literal)) {
            return null;
        }

        String key = literal.trim().toUpperCase();

        try {
            return StandardDateTimeLiteral.valueOf(key);
        } catch (Exception e) {
            return null;
        }
    }

    // ============================================
    // PRIVATE METHODS - COMPARISON OPERATIONS
    // ============================================
    
    /**
     * Attempts DateTime comparison for two values.
     * Returns the comparison result if both values can be coerced to DateTime, null otherwise.
     */
    private static Boolean tryDateTimeComparison(Object left, Object right, ComparisonOperator op) {
        Datetime leftDt = coerceToDateTime(left);
        Datetime rightDt = coerceToDateTime(right);
        if (leftDt != null && rightDt != null) {
            return compareDateTimes(leftDt, rightDt, op);
        }
        return null; // Indicates DateTime comparison not applicable
    }
    
    /**
     * Compares two values using supported operators (==, !=, >, contains, in, etc.).
     */
    private static Boolean compareValues(Object left, Object right, String operator) {
        operator = operator.trim();

        // Handle 'contains' operator
        if (operator == 'contains') {
            if (left == null || right == null) return false;
            return String.valueOf(left).contains(String.valueOf(right));
        }

        // Handle 'in' operator
        if (operator == 'in') {
            if (left == null || right == null) return false;
            
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
            
            throw new CustomConditionEvaluatorException('Right side of "in" operator must be an array: ' + right);
        }

        // Map operator to canonical enum
        ComparisonOperator opEnum = toComparisonOperator(operator);

        // Handle equality
        if (opEnum == ComparisonOperator.EQUAL) {
            if (left == null && right == null) return true;
            if (left == null || right == null) return false;
            
            // Try DateTime comparison first (for date strings like '2025-01-01 10:00:00')
            Boolean dtResult = tryDateTimeComparison(left, right, opEnum);
            if (dtResult != null) return dtResult;
            
            // Fall back to string comparison for non-date values
            return String.valueOf(left) == String.valueOf(right);
        }

        // Handle inequality
        if (opEnum == ComparisonOperator.NOT_EQUAL) {
            if (left == null && right == null) return false;
            if (left == null || right == null) return true;
            
            // Try DateTime comparison first (for date strings like '2025-01-01 10:00:00')
            Boolean dtResult = tryDateTimeComparison(left, right, opEnum);
            if (dtResult != null) return dtResult;
            
            // Fall back to string comparison for non-date values
            return String.valueOf(left) != String.valueOf(right);
        }

        // Handle comparison operators (>, <, >=, <=)
        if (opEnum == ComparisonOperator.GREATER ||
            opEnum == ComparisonOperator.LESS ||
            opEnum == ComparisonOperator.GREATER_OR_EQUAL ||
            opEnum == ComparisonOperator.LESS_OR_EQUAL) {
            
            if (left == null || right == null) {
                return false;
            }

            // Try DateTime comparison first (preserves time component for datetime strings)
            Boolean dtResult = tryDateTimeComparison(left, right, opEnum);
            if (dtResult != null) return dtResult;

            // Fall back to Date comparison (for date-only values)
            Date leftDateVal = coerceToDate(left);
            Date rightDateVal = coerceToDate(right);
            if (leftDateVal != null && rightDateVal != null) {
                return compareDates(leftDateVal, rightDateVal, opEnum);
            }

            // Fall back to numeric comparison
            Decimal leftNum = toDecimal(left);
            Decimal rightNum = toDecimal(right);

            if (leftNum == null || rightNum == null) {
                throw new CustomConditionEvaluatorException(
                    'Cannot perform numeric comparison. Left: "' + left + '", Right: "' + right + '"'
                );
            }

            if (opEnum == ComparisonOperator.GREATER) return leftNum > rightNum;
            if (opEnum == ComparisonOperator.LESS) return leftNum < rightNum;
            if (opEnum == ComparisonOperator.GREATER_OR_EQUAL) return leftNum >= rightNum;
            if (opEnum == ComparisonOperator.LESS_OR_EQUAL) return leftNum <= rightNum;
        }

        throw new CustomConditionEvaluatorException('Unknown or unsupported operator: "' + operator + '"');
    }

    /**
     * Maps operator symbols (===, ==, >=, etc.) to the canonical ComparisonOperator enum.
     */
    private static ComparisonOperator toComparisonOperator(String opSymbol) {
        if (String.isBlank(opSymbol)) {
            throw new CustomConditionEvaluatorException('Empty operator');
        }

        String symbol = opSymbol.trim();

        if (symbol == '===' || symbol == '==') {
            return ComparisonOperator.EQUAL;
        }
        if (symbol == '!==' || symbol == '!=') {
            return ComparisonOperator.NOT_EQUAL;
        }
        if (symbol == '>') {
            return ComparisonOperator.GREATER;
        }
        if (symbol == '>=') {
            return ComparisonOperator.GREATER_OR_EQUAL;
        }
        if (symbol == '<') {
            return ComparisonOperator.LESS;
        }
        if (symbol == '<=') {
            return ComparisonOperator.LESS_OR_EQUAL;
        }

        throw new CustomConditionEvaluatorException('Unsupported comparison operator symbol: "' + opSymbol + '"');
    }

    /**
     * Specialized comparison logic when RHS is a standard date/time literal.
     */
    private static Boolean evaluateStandardDateTimeLiteral(
        Object left,
        StandardDateTimeLiteral right,
        String operator
    ) {
        Date leftDate = coerceToDate(left);
        if (leftDate == null || right == null) {
            return false;
        }

        ComparisonOperator op = operator != null ? toComparisonOperator(operator) : null;
        Date today = Date.today();
        Integer leftYear = leftDate.year();
        Integer leftMonth = leftDate.month();
        Integer thisYear = today.year();
        Integer thisMonth = today.month();

        switch on right {
            when DATE_TODAY {
                return compareDates(leftDate, today, op);
            }
            when DATE_TOMORROW {
                return compareDates(leftDate, today.addDays(1), op);
            }
            when DATE_THIS_MONTH {
                // Compare year-month as integer key for chronological ordering
                Integer leftKey = leftYear * 100 + leftMonth;
                Integer thisKey = thisYear * 100 + thisMonth;
                return compareInts(leftKey, thisKey, op, 'month');
            }
            when DATE_THIS_YEAR {
                return compareInts(leftYear, thisYear, op, 'year');
            }
            when DATE_NEXT_YEAR {
                return compareInts(leftYear, thisYear + 1, op, 'year');
            }
        }

        return false;
    }

    /**
     * Coerces supported types into a Date (Date, Datetime, date strings).
     */
    private static Date coerceToDate(Object value) {
        if (value == null) return null;
        if (value instanceof Date) return (Date) value;
        if (value instanceof Datetime) return ((Datetime) value).date();
        
        // Try parsing date/time strings
        if (value instanceof String) {
            String str = ((String) value).trim();
            if (String.isBlank(str)) return null;
            try {
                // Try full datetime first
                Datetime dt = Datetime.valueOf(str);
                return dt.date();
            } catch (Exception e) {
                try {
                    // Fall back to plain date
                    Date d = Date.valueOf(str);
                    return d;
                } catch (Exception e2) {
                    return null;
                }
            }
        }
        return null;
    }

    /**
     * Coerces supported types into a DateTime (Datetime, Date, datetime strings).
     * Preserves time component for accurate datetime comparisons.
     */
    private static Datetime coerceToDateTime(Object value) {
        if (value == null) return null;
        if (value instanceof Datetime) return (Datetime) value;
        if (value instanceof Date) return Datetime.newInstance((Date) value, Time.newInstance(0, 0, 0, 0));
        
        // Try parsing date/time strings
        if (value instanceof String) {
            String str = ((String) value).trim();
            if (String.isBlank(str)) return null;
            try {
                // Try full datetime first
                return Datetime.valueOf(str);
            } catch (Exception e) {
                try {
                    // Fall back to plain date, convert to datetime at midnight
                    Date d = Date.valueOf(str);
                    return Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
                } catch (Exception e2) {
                    return null;
                }
            }
        }
        return null;
    }

    /**
     * Compares two dates using the specified comparison operator.
     */
    private static Boolean compareDates(Date left, Date target, ComparisonOperator op) {
        switch on op {
            when EQUAL {
                return left == target;
            }
            when NOT_EQUAL {
                return left != target;
            }
            when GREATER {
                return left > target;
            }
            when GREATER_OR_EQUAL {
                return left >= target;
            }
            when LESS {
                return left < target;
            }
            when LESS_OR_EQUAL {
                return left <= target;
            }
        }

        throw new CustomConditionEvaluatorException('Unsupported operator for date comparison: ' + String.valueOf(op));
    }

    /**
     * Compares two datetimes using the specified comparison operator.
     */
    private static Boolean compareDateTimes(Datetime left, Datetime target, ComparisonOperator op) {
        switch on op {
            when EQUAL {
                return left == target;
            }
            when NOT_EQUAL {
                return left != target;
            }
            when GREATER {
                return left > target;
            }
            when GREATER_OR_EQUAL {
                return left >= target;
            }
            when LESS {
                return left < target;
            }
            when LESS_OR_EQUAL {
                return left <= target;
            }
        }

        throw new CustomConditionEvaluatorException('Unsupported operator for datetime comparison: ' + String.valueOf(op));
    }

    /**
     * Generic integer comparison helper (used for year/month checks).
     */
    private static Boolean compareInts(Integer left, Integer target, ComparisonOperator op, String context) {
        switch on op {
            when EQUAL {
                return left == target;
            }
            when NOT_EQUAL {
                return left != target;
            }
            when GREATER {
                return left > target;
            }
            when GREATER_OR_EQUAL {
                return left >= target;
            }
            when LESS {
                return left < target;
            }
            when LESS_OR_EQUAL {
                return left <= target;
            }
        }

        throw new CustomConditionEvaluatorException('Unsupported operator for ' + context + ' comparison: ' + String.valueOf(op));
    }

    /**
     * Removes redundant outer parentheses while preserving inner structure.
     */
    private static String stripOuterParentheses(String input) {
        input = input.trim();
        
        while (input.length() >= 2 && input.startsWith('(') && input.endsWith(')')) {
            Integer depth = 0;
            Boolean firstMatchesLast = false;
            StringState strState = new StringState();
            
            for (Integer i = 0; i < input.length(); i++) {
                String ch = input.substring(i, i + 1);
                
                // Handle string delimiters
                if (strState.updateState(ch, i, input)) {
                    continue;
                }
                
                if (!strState.inString) {
                    if (ch == '(') depth++;
                    else if (ch == ')') depth--;
                    
                    // Check if outer parentheses match
                    if (depth == 0 && i < input.length() - 1) {
                        // Outer pair isn't the sole wrapper; stop stripping
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

    /**
     * Strips surrounding single/double quotes if present.
     */
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

    /**
     * Converts supported types/strings to Decimal when possible.
     */
    private static Decimal toDecimal(Object value) {
        if (value == null) return null;
        
        if (value instanceof Decimal) return (Decimal) value;
        if (value instanceof Integer) return Decimal.valueOf((Integer) value);
        if (value instanceof Long) return Decimal.valueOf((Long) value);
        if (value instanceof Double) return Decimal.valueOf((Double) value);
        
        String str = String.valueOf(value).trim();
        
        try {
            if (str.startsWith('-')) {
                // Handle negative numbers
                str = str.substring(1);
                if (isValidNumberString(str)) {
                    return -Decimal.valueOf(str);
                }
            } else if (isValidNumberString(str)) {
                return Decimal.valueOf(str);
            }
        } catch (Exception e) {
            // Invalid number format
        }
        
        return null;
    }

    /**
     * Validates a numeric string (optional leading -, single dot).
     */
    private static Boolean isValidNumberString(String str) {
        if (String.isBlank(str)) return false;
        
        Boolean hasDecimal = false;
        for (Integer i = 0; i < str.length(); i++) {
            String ch = str.substring(i, i + 1);
            if (ch == '.') {
                if (hasDecimal) return false; // Multiple decimal points
                hasDecimal = true;
            } else if (!ch.isNumeric()) {
                return false;
            }
        }
        return true;
    }

    /**
     * Collapses consecutive spaces to single spaces.
     */
    private static String normalizeWhitespace(String input) {
        if (String.isBlank(input)) return input;
        
        while (input.contains('  ')) {
            input = input.replace('  ', ' ');
        }
        
        return input;
    }
}
