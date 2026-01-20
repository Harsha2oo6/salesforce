/**
 * Local test runner for `evaluateCondition` / `filterOptionsByCondition`.
 * Run with:
 *   node scripts/testUtilityConditionEvaluator.js
 */

function evaluateCondition(condition, values) {
    if (!condition || typeof condition !== 'string') return false;
    if (condition.trim() === 'true') return true;
    if (condition.trim() === 'false') return false;

    try {
        // 1. Fix the LEFT side: values[FIELD] -> values['FIELD']
        let cleanCondition = condition.replace(
            /values\[\s*([a-zA-Z0-9_]+)\s*\]/g,
            "values['$1']"
        );

        // 2. Fix the RIGHT side: === some_value -> === 'some_value'
        // CHANGED: Added / ( ) to the allowed characters list at the end
        cleanCondition = cleanCondition.replace(
            /(===|!==|==|!=|>|<|>=|<=)\s+(?!true\b|false\b|null\b|undefined\b|[0-9])([a-zA-Z0-9_/\(\)]+)/g,
            "$1 '$2'"
        );

        // 3. Evaluate safely
        const func = new Function('values', `return ${cleanCondition}`);
        return Boolean(func(values));
    } catch (error) {
        console.warn('Condition evaluation failed:', condition, error);
        return false;
    }
}

function filterOptionsByCondition(options, values) {
    if (!Array.isArray(options)) {
        return [];
    }

    return options.filter((option) => {
        if (!option.condition) {
            return true;
        }
        return evaluateCondition(option.condition, values);
    });
}

// ---- Example tests ----

const values = {
    mobile_number: 995439,
    status: 'ACTIVE',
    age: 25,
    city: 'Mumbais',
    isStudent: true
};

const testConditions = [
    "values[mobile_number] === 995439",
    "values[mobile_number] === '995439'",
    "values[status] === ACTIVE",
    "values[status] !== INACTIVE",
    "values[age] >= 18",
    "values[city] === Mumbai && values[age] > 20",
    "values[isStudent] === true",
    "values[unknownField] === something",
    "true",
    "false"
];

console.log('--- Testing evaluateCondition ---');
for (const cond of testConditions) {
    const result = evaluateCondition(cond, values);
    console.log(`Condition: ${cond}  =>  ${result}`);
}

console.log('\n--- Testing filterOptionsByCondition ---');
const options = [
    { label: 'Option 1 - always', value: 'opt1' },
    { label: 'Option 2 - mobile match', value: 'opt2', condition: "values[mobile_number] === 995439" },
    { label: 'Option 3 - adult in Mumbai', value: 'opt3', condition: "values[age] >= 18 && values[city] === Mumbai" },
    { label: 'Option 4 - inactive only', value: 'opt4', condition: "values[status] === INACTIVE" }
];

const filtered = filterOptionsByCondition(options, values);
console.log('Filtered options:', filtered);

