---
name: unit-tests
description: >
  Create unit tests that cover a given class. TRIGGER when the user asks to create unit tests,
  write tests, add test coverage, or says "unit-tests" / "UT" for a class or method.
---

# unit-tests -- Create Verified Unit Tests

Create unit tests that thoroughly cover the specified class. Every test must be verified
red/green before it is considered done.

## Workflow

For each test you write, follow this strict cycle:

### 1. Write the test

Create a test that exercises a specific behavior of the class under test. One test per
behavior -- keep tests focused and independent.

### 2. Add diagnostic traces

Add `ITestOutputHelper` traces (xUnit), `Console.WriteLine`, or the appropriate test
framework output mechanism to the test so you can observe what is happening when the test
runs. This is essential for understanding failures.

Example (xUnit):

```csharp
_output.WriteLine($"Input: {input}, Expected: {expected}, Actual: {actual}");
```

### 3. Verify red -- make the test fail

Comment out or temporarily disable the specific line(s) of production code that this test
is meant to cover. Then run the test and confirm it **fails**. This proves the test
actually exercises that code path.

If the test still passes with the code commented out, the test is not covering what you
think it is -- fix the test before moving on.

### 4. Verify green -- restore and pass

Uncomment / restore the production code. Run the test again and confirm it **passes**.

### 5. Clean up traces

Remove all diagnostic `WriteLine` / trace output you added in step 2. The final test
should be clean -- no debug logging left behind.

### 6. Repeat

Move on to the next behavior and repeat from step 1.

## Guidelines

- **One behavior per test.** Don't test multiple things in a single test method.
- **Name tests clearly.** Use a pattern like `MethodName_Scenario_ExpectedResult` or
  `Should_ExpectedBehavior_When_Condition`.
- **Red first, always.** Never consider a test done unless you have seen it fail with
  the relevant code commented out. This is non-negotiable.
- **Clean tests at the end.** No trace output, no commented-out code, no TODOs left behind
  in the final version.
- **Follow existing conventions.** Look at existing tests in the project for patterns,
  base classes, helper utilities, and naming conventions. Reuse them.
