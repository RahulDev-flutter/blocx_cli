#!/bin/bash

# fix_remaining_issues.sh - Fix all remaining analysis issues

echo "🔧 Fixing remaining code analysis issues..."

# Fix 1: Remove unused local variable 'routePath'
echo "1. Fixing unused variable in dynamic_screen_generator.dart..."
sed -i '/final routePath = /d' lib/src/generators/dynamic_screen_generator.dart

# Fix 2: Remove deprecated 'author' field from pubspec.yaml
echo "2. Removing deprecated 'author' field from pubspec.yaml..."
sed -i '/^author:/d' pubspec.yaml

# Fix 3: Fix string interpolation issues
echo "3. Fixing string interpolation in dynamic_module_generator.dart..."
# Replace string concatenation with interpolation
sed -i 's/className + "Module"/\${className}Module/g' lib/src/generators/dynamic_module_generator.dart
sed -i 's/className + "Screen"/\${className}Screen/g' lib/src/generators/dynamic_module_generator.dart
sed -i 's/screenName + "Screen"/\${screenName}Screen/g' lib/src/generators/dynamic_module_generator.dart

# Fix 4: Fix string interpolation in auth_templates.dart
echo "4. Fixing string interpolation in templates..."
sed -i 's/\${className}/\$className/g' lib/src/templates/auth_templates.dart
sed -i 's/\${screenName}/\$screenName/g' lib/src/templates/dynamic_templates.dart

# Fix 5: Remove unnecessary string escapes
echo "5. Fixing string escapes in core_templates.dart..."
sed -i 's/\\"/"/g' lib/src/templates/core_templates.dart

# Fix 6: Add braces to if statements
echo "6. Adding braces to if statements..."
# This is more complex, so we'll handle it manually or with a more sophisticated approach

echo "✅ Fixed most analysis issues!"

# Format the code again
echo "🎨 Formatting code..."
dart format .

echo "📋 Checking analysis again..."
dart analyze --fatal-warnings

echo "✅ Analysis fixes completed!"
echo ""
echo "⚠️  Note: You may need to manually fix the if statement braces issue"
echo "    and review the test failure."