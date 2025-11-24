# Rebranding Plan: Black & White (Monochrome)

## 1. Goal
Transform the entire application's visual identity from the current Green theme to a modern, high-contrast Black & White (Monochrome) theme.

## 2. Color Palette
**Primary Black:** `#1F2937` (Dark Charcoal)
**Shades:**
*   **Primary:** `#1F2937` (Main brand color, buttons, active states)
*   **Secondary/Accent:** `#374151` (Slightly lighter black for secondary actions)
*   **Border/Divider:** `#E5E7EB` (Light Grey)
*   **Surface:** `#FFFFFF` (White) or `#F9FAFB` (Very light grey)
*   **Background:** `#FFFFFF` (White)
*   **Text:**
    *   Primary: `#1F2937` (Almost Black)
    *   Secondary: `#6B7280` (Grey)

## 3. Implementation Strategy

### Step 1: Update Theme Definition (`lib/core/theme/app_theme.dart`)
*   Redefine `primaryGreen` to be the new Black (`#1F2937`). *Note: We will rename the variable or just change its value but keep the name if refactoring is too risky, but ideally we rename it to `primaryColor`.*
    *   *Decision:* To avoid breaking 145+ references immediately, I will change the **value** of `primaryGreen` to `#1F2937` and rename it to `primaryColor` using the IDE's refactoring capabilities (or manual search/replace if needed).
    *   Actually, simpler approach: Rename `primaryGreen` -> `primaryBlack` (or just `primaryColor`) and update the hex code.
    *   Update `secondaryGreen` -> `#374151` (Dark Grey).
    *   Update `surfaceGreen` -> `#F3F4F6` (Light Grey Surface).
    *   Update `borderGreen` -> `#E5E7EB` (Light Border).

### Step 2: Update Hardcoded Colors in Components
Some components have hardcoded colors or specific styling that needs to be adjusted.
*   **FABs:** Ensure they use the new primary black.
*   **Dish Cards:** Remove any green tints/backgrounds.
*   **Map Markers:** (If possible) change to black/dark markers.
*   **Badges:** Red for notifications is fine, but primary badges should be black.

### Step 3: Global Search & Replace
*   Search for `primaryGreen`, `secondaryGreen`, `surfaceGreen` and replace with `primaryColor`, `secondaryColor`, `surfaceColor`.
*   This will be done in batches to ensure correctness.

## 4. Execution List
1.  **Modify `lib/core/theme/app_theme.dart`**:
    *   Change color values.
    *   Update `GlassmorphismTokens` to be neutral (black/white shadows).
2.  **Modify `lib/features/feed/widgets/dish_card.dart`**:
    *   Update hardcoded colors if any.
3.  **Modify `lib/features/customer/customer_app_shell.dart`**:
    *   Update FAB colors.
4.  **Modify `lib/features/map/screens/map_screen.dart`**:
    *   Update search bar accents.

## 5. Verification
*   Run the app and verify the look.
*   Check specifically for "Green" remnants.
