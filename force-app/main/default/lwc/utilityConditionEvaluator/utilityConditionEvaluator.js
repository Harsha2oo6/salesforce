/**
 * Main entry point: evaluates a condition string against a values map.
 */
export function evaluateCondition(condition, values) {
  if (!values) throw new Error("Values map cannot be null");
  if (!condition || typeof condition !== 'string' || !condition.trim()) {
      throw new Error("Condition is not a string or is empty");
  }

  // Normalize
  let normalized = condition.replace(/[\n\r]/g, ' ').trim();
  normalized = normalizeWhitespace(normalized);
  normalized = stripOuterParentheses(normalized);

  return evaluateExpression(values, normalized);
}

/**
* Recursively evaluates boolean expressions with !, &&, ||
*/
export function evaluateExpression(values, expr) {
  if (!expr || !expr.trim()) throw new Error("Empty expression");

  expr = stripOuterParentheses(expr.trim());

  // 1. Handle Negation (!)
  if (expr.startsWith('!')) {
      let innerExpr = expr.substring(1).trim();
      if (innerExpr.startsWith('(')) {
          innerExpr = stripOuterParentheses(innerExpr);
      }
      return !evaluateExpression(values, innerExpr);
  }

  // 2. Handle OR (||) - Lowest Precedence
  const orPositions = findTopLevelOperatorPositions(expr, '||');
  if (orPositions.length > 0) {
      let start = 0;
      for (let pos of orPositions) {
          const part = expr.substring(start, pos).trim();
          if (evaluateExpression(values, part)) {
              return true; // Short-circuit
          }
          start = pos + 2;
      }
      return evaluateExpression(values, expr.substring(start).trim());
  }

  // 3. Handle AND (&&) - Higher Precedence
  const andPositions = findTopLevelOperatorPositions(expr, '&&');
  if (andPositions.length > 0) {
      let start = 0;
      for (let pos of andPositions) {
          const part = expr.substring(start, pos).trim();
          if (!evaluateExpression(values, part)) {
              return false; // Short-circuit
          }
          start = pos + 2;
      }
      return evaluateExpression(values, expr.substring(start).trim());
  }

  // 4. Truthy Check
  if (isTruthyCheck(expr)) {
      return evaluateTruthy(values, expr);
  }

  // 5. Comparison
  return evalCondition(values, expr);
}

// ==========================================
// CORE EVALUATION LOGIC
// ==========================================

function evalCondition(values, condition) {
  condition = stripOuterParentheses(condition.trim());
  const opInfo = parseOperator(condition);

  if (!opInfo) {
      throw new Error(`No valid operator found in condition: "${condition}"`);
  }

  const lhsRaw = condition.substring(0, opInfo.position).trim();
  const rhsRaw = condition.substring(opInfo.position + opInfo.operator.length).trim();

  const leftValue = resolveValue(values, lhsRaw);
  const rightValue = resolveRightHandSide(values, rhsRaw);

  // Handle Date Literals (DATE_TODAY, etc)
  if (isDateLiteral(rightValue)) {
      return evaluateStandardDateTimeLiteral(leftValue, rightValue, opInfo.operator);
  }

  return compareValues(leftValue, rightValue, opInfo.operator);
}

function resolveRightHandSide(values, rhsRaw) {
  rhsRaw = rhsRaw.trim();
  if (rhsRaw.startsWith('values[')) {
      return resolveValue(values, rhsRaw);
  }
  return parseLiteral(rhsRaw);
}

function resolveValue(values, expression) {
  expression = expression.trim();
  if (!expression.startsWith('values[')) {
      throw new Error(`Invalid value expression. Expected "values[...]" but got: "${expression}"`);
  }

  // Remove "values["
  let inner = expression.substring(7);
  inner = stripOuterParentheses(inner.trim()); // rough cleanup

  const pathParts = parseValuePath(inner);
  if (pathParts.length === 0) throw new Error("Empty path in value expression");

  let current = values;

  // Iterate keys
  for (let i = 0; i < pathParts.length; i++) {
      if (current == null) return null;

      // Resolve nested keys if strictly needed, but usually simple map traversal
      // The Apex logic allowed for recursive resolution, simplistic approach here:
      const key = pathParts[i];
      current = current[key];
  }
  return current;
}

// ==========================================
// PARSING HELPERS (Paths & Operators)
// ==========================================

function parseValuePath(expression) {
  const parts = [];
  const firstBracket = expression.indexOf('[');

  if (firstBracket === -1) {
      let key = expression.trim();
      // Remove trailing ']' if present (artifact of recursive parsing)
      if (key.endsWith(']') && !key.includes('[')) {
          key = key.substring(0, key.length - 1).trim();
      }
      parts.push(key);
      return parts;
  }

  parts.push(expression.substring(0, firstBracket).trim());

  let remaining = expression.substring(firstBracket);
  let pos = 0;

  while (pos < remaining.length) {
      const start = remaining.indexOf('[', pos);
      if (start === -1) break;

      const endIdx = findMatchingBracket(remaining, start);
      if (endIdx === -1) break;

      let content = remaining.substring(start + 1, endIdx).trim();
      content = removeQuotes(content);

      if (content) parts.push(content);
      pos = endIdx + 1;
  }
  return parts;
}

function findMatchingBracket(str, openPos) {
  let depth = 0;
  let inString = false;
  let quoteChar = '';

  for (let i = openPos; i < str.length; i++) {
      const char = str[i];
      if ((char === '"' || char === "'") && str[i - 1] !== '\\') {
          if (!inString) { inString = true; quoteChar = char; }
          else if (char === quoteChar) { inString = false; }
      }
      if (inString) continue;

      if (char === '[') depth++;
      else if (char === ']') {
          depth--;
          if (depth === 0) return i;
      }
  }
  return -1;
}

function findTopLevelOperatorPositions(expr, operator) {
  const positions = [];
  let depth = 0;
  let inString = false;
  let quoteChar = '';

  for (let i = 0; i < expr.length - 1; i++) {
      const char = expr[i];

      if ((char === '"' || char === "'") && expr[i - 1] !== '\\') {
          if (!inString) { inString = true; quoteChar = char; }
          else if (char === quoteChar) { inString = false; }
      }
      if (inString) continue;

      if (char === '(') depth++;
      else if (char === ')') depth--;

      if (depth === 0 && i + operator.length <= expr.length) {
          if (expr.substring(i, i + operator.length) === operator) {
              positions.push(i);
              i += operator.length - 1;
          }
      }
  }
  return positions;
}

function parseOperator(condition) {
  const operators = ['!==', '===', '!=', '==', '>=', '<=', ' contains ', ' in ', '>', '<'];
  let depth = 0;
  let inString = false;
  let quoteChar = '';

  for (let i = 0; i < condition.length; i++) {
      const char = condition[i];

      if ((char === '"' || char === "'") && condition[i - 1] !== '\\') {
          if (!inString) { inString = true; quoteChar = char; }
          else if (char === quoteChar) { inString = false; }
      }
      if (inString) continue;

      if (char === '(' || char === '[') depth++;
      else if (char === ')' || char === ']') depth--;

      if (depth === 0) {
          for (let op of operators) {
              if (condition.substr(i, op.length) === op) {
                  return { operator: op.trim(), position: i };
              }
          }
      }
  }
  return null;
}

// ==========================================
// COMPARISON LOGIC
// ==========================================

function compareValues(left, right, operator) {
  if (operator === 'contains') {
      if (left == null || right == null) return false;
      return String(left).includes(String(right));
  }
  if (operator === 'in') {
      if (!Array.isArray(right)) throw new Error('Right side of "in" must be an array');
      return right.some(item => String(item) === String(left));
  }

  // Equality
  if (operator === '==' || operator === '===') return String(left) === String(right);
  if (operator === '!=' || operator === '!==') return String(left) !== String(right);

  // DateTime / Numeric Comparison
  // Try DateTime first
  const leftDt = coerceToDateTime(left);
  const rightDt = coerceToDateTime(right);

  if (leftDt && rightDt) {
      const lTime = leftDt.getTime();
      const rTime = rightDt.getTime();
      switch (operator) {
          case '>': return lTime > rTime;
          case '>=': return lTime >= rTime;
          case '<': return lTime < rTime;
          case '<=': return lTime <= rTime;
      }
  }

  // Numeric Fallback
  const lNum = Number(left);
  const rNum = Number(right);
  if (!isNaN(lNum) && !isNaN(rNum)) {
      switch (operator) {
          case '>': return lNum > rNum;
          case '>=': return lNum >= rNum;
          case '<': return lNum < rNum;
          case '<=': return lNum <= rNum;
      }
  }

  return false;
}

function evaluateStandardDateTimeLiteral(left, literal, operator) {
  const leftDate = coerceToDate(left);
  if (!leftDate) return false;

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Normalize left date to midnight for comparison
  const lDateOnly = new Date(leftDate);
  lDateOnly.setHours(0, 0, 0, 0);

  let targetDate = null;
  let compareMode = 'date'; // 'date', 'month', 'year'

  switch (literal) {
      case 'DATE_TODAY':
          targetDate = today;
          break;
      case 'DATE_TOMORROW':
          targetDate = new Date(today);
          targetDate.setDate(today.getDate() + 1);
          break;
      case 'DATE_THIS_MONTH':
          compareMode = 'month';
          break;
      case 'DATE_THIS_YEAR':
          compareMode = 'year';
          break;
      case 'DATE_NEXT_YEAR':
          compareMode = 'next_year';
          break;
  }

  if (compareMode === 'month') {
      // Simple int comparison YYYYMM
      const lVal = leftDate.getFullYear() * 100 + leftDate.getMonth();
      const rVal = today.getFullYear() * 100 + today.getMonth();
      return compareInts(lVal, rVal, operator);
  }
  if (compareMode === 'year') {
      return compareInts(leftDate.getFullYear(), today.getFullYear(), operator);
  }
  if (compareMode === 'next_year') {
      return compareInts(leftDate.getFullYear(), today.getFullYear() + 1, operator);
  }

  // Default Date Comparison
  return compareValues(lDateOnly, targetDate, operator);
}

function compareInts(left, right, op) {
  switch (op) {
      case '==': case '===': return left === right;
      case '!=': case '!==': return left !== right;
      case '>': return left > right;
      case '>=': return left >= right;
      case '<': return left < right;
      case '<=': return left <= right;
  }
  return false;
}

// ==========================================
// UTILITIES & TYPE COERCION
// ==========================================

function evaluateTruthy(values, expr) {
  if (expr.startsWith('!')) {
      return !evaluateTruthy(values, expr.substring(1).trim());
  }
  if (expr.startsWith('values[')) {
      const val = resolveValue(values, expr);
      return isTruthy(val);
  }
  const val = parseLiteral(expr);
  return isTruthy(val);
}

function isTruthy(value) {
  if (value == null) return false;
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') return value.trim() !== '';
  if (typeof value === 'number') return value !== 0;
  if (Array.isArray(value)) return value.length > 0;
  return true;
}

function isTruthyCheck(expr) {
  return parseOperator(expr) === null;
}

function isDateLiteral(val) {
  return ['DATE_TODAY', 'DATE_TOMORROW', 'DATE_THIS_MONTH', 'DATE_THIS_YEAR', 'DATE_NEXT_YEAR'].includes(val);
}

function parseLiteral(raw) {
  raw = raw.trim();
  if (raw === 'null') return null;
  if (raw.toLowerCase() === 'true') return true;
  if (raw.toLowerCase() === 'false') return false;

  // Array [a,b]
  if (raw.startsWith('[') && raw.endsWith(']')) {
      return raw.substring(1, raw.length - 1).split(',').map(s => parseLiteral(s));
  }
  // Quoted Strings
  if ((raw.startsWith("'") && raw.endsWith("'")) || (raw.startsWith('"') && raw.endsWith('"'))) {
      return raw.substring(1, raw.length - 1);
  }
  // Numbers
  if (!isNaN(raw) && raw !== '') return Number(raw);

  // Standard Date Literals or Unquoted Strings
  return raw;
}

function coerceToDate(val) {
  if (!val) return null;
  if (val instanceof Date) return val;
  const d = new Date(val);
  return isNaN(d.getTime()) ? null : d;
}

function coerceToDateTime(val) {
  return coerceToDate(val);
}

function stripOuterParentheses(str) {
  while (str.startsWith('(') && str.endsWith(')')) {
      let depth = 0;
      let matchIndex = -1;
      for (let i = 0; i < str.length; i++) {
          if (str[i] === '(') depth++;
          if (str[i] === ')') depth--;
          if (depth === 0) {
              matchIndex = i;
              break;
          }
      }
      if (matchIndex === str.length - 1) {
          str = str.substring(1, str.length - 1).trim();
      } else {
          break;
      }
  }
  return str;
}

function removeQuotes(str) {
  str = str.trim();
  if (str.length >= 2) {
      const first = str[0];
      const last = str[str.length - 1];
      if ((first === "'" && last === "'") || (first === '"' && last === '"')) {
          return str.substring(1, str.length - 1);
      }
  }
  return str;
}

function normalizeWhitespace(str) {
  return str ? str.replace(/\s+/g, ' ') : str;
}