const hello = require('./index');

test('greets the user by name', () => {
  expect(hello('Thiago')).toBe('Hello, Thiago!');
});