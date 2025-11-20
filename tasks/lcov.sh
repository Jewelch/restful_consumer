flutter test --coverage

# Exclude request_performer_ext.dart from coverage
lcov --remove coverage/lcov.info '**/request_performer_ext.dart' -o coverage/lcov.info

# Generate HTML report
# Note: on macOS you need to have lcov installed on your system (`brew install lcov`) to use this:
genhtml coverage/lcov.info -o coverage/html
# Open the report
open coverage/html/index.html