#!/bin/bash
FILES=(
  lib/frontend/screens/gym/gym_attendance_screen.dart
  lib/frontend/screens/gym/gym_payments_screen.dart
  lib/frontend/screens/gym/gym_plans_screen.dart
  lib/frontend/screens/gym/gym_reports_screen.dart
  lib/frontend/screens/gym/gym_schedules_screen.dart
  lib/frontend/screens/gym/gym_trainers_screen.dart
  lib/frontend/screens/gym/gym_workouts_screen.dart
)

for f in "${FILES[@]}"; do
  echo "Fixing $f..."
  
  # 1. Remove the drawer line (various patterns)
  sed -i '/drawer: isMobile ? const Drawer/d' "$f"
  sed -i '/drawer: const Drawer/d' "$f"
  
  # 2. Remove the body: Row wrapper and ErpSidebar + ErpTopbar + Expanded nesting
  # Replace "body: Row(\n...children: [...if (!isMobile) const ErpSidebar...Expanded(\nchild: Column(\nchildren: [\nconst ErpTopbar(),\nExpanded(\nchild: RefreshIndicator(" 
  # with "body: RefreshIndicator("
  perl -0777 -i -pe 's/body: Row\(\s*children: \[\s*(?:if \(!isMobile\) const ErpSidebar\([^)]*\),?\s*)?Expanded\(\s*child: Column\(\s*children: \[\s*const ErpTopbar\(\),?\s*Expanded\(\s*child: RefreshIndicator\(/body: RefreshIndicator(/gs' "$f"
  
  # 3. Remove the matching closing brackets: ], ), ), ], ), )  
  # These correspond to: Column children, Column, Expanded, Row children, Row
  # Pattern: ],\n            ),\n          ),\n        ],\n      ),\n    ),
  perl -0777 -i -pe 's/\n\s*\],\n\s*\),\n\s*\),\n\s*\],\n\s*\),\n\s*\),/\n      )/gs' "$f"
  
  # 4. Remove duplicate title headers (fontSize: 26)
  perl -0777 -i -pe "s/\s*\/\/ Header\s*\n\s*const Column\(\s*\n\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*\n\s*children: \[\s*\n\s*Text\(\s*\n\s*'[^']*',\s*\n\s*style: TextStyle\(\s*\n\s*fontSize: 26,\s*\n\s*fontWeight: FontWeight\.w800,\s*\n\s*color: Color\(0xFF2563EB\),\s*\n\s*letterSpacing: -0\.5,\s*\n\s*\),\s*\n\s*\),\s*\n\s*SizedBox\(height: 4\),\s*\n\s*Text\('[^']*',\s*\n\s*style: TextStyle\(fontSize: 13, color: Color\(0xFF64748B\)\)\s*\n\s*\),\s*\n\s*\],\s*\n\s*\),\s*\n\s*const SizedBox\(height: 20\),/const SizedBox(height: 4),/gs" "$f"
  
done
echo "Done fixing all gym screens"
