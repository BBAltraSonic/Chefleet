# UI Modernization & Fix Plan

## 1. Critical Fixes (Overflow)
**Problem:** The `DishCard` content overflows because it is constrained by a fixed aspect ratio in a `SliverGrid`.
**Solution:** Switch from `SliverGrid` to `SliverList` in `MapScreen`. This allows the cards to size themselves vertically based on their content, preventing overflow on small screens and allowing for dynamic content lengths (e.g., long descriptions).

## 2. Visual Modernization

### A. Dish Card Redesign (`DishCard`)
*   **Layout:** Clean vertical layout with full-width image.
*   **Image:** Increase image height slightly (180px), add a gradient overlay for text legibility if we overlay text, or keep text below. Let's keep text below for clarity but clean up the spacing.
*   **Typography:**
    *   Title: Bold, larger (18px).
    *   Description: Grey, legible (14px).
    *   Price: prominent, primary color.
*   **Actions:**
    *   Make the "Add" button larger and more touch-friendly, perhaps a pill-shaped "Add" button or a larger circular FAB-style button inside the card.
*   **Styling:**
    *   Remove heavy borders. Use soft shadows (elevation).
    *   Rounded corners (20px).
    *   Background: White (or off-white) to stand out against the grey sheet.

### B. Header & Navigation (`MapScreen`, `PersonalizedHeader`)
*   **Personalized Header:**
    *   Make the greeting more prominent.
    *   Style the avatar with a cleaner ring.
*   **Category Filter:**
    *   Update chips to be more modern (Capsule shape, better active state).
    *   Add icons to categories if possible (dynamic icons based on label).

### C. Bottom Sheet (`MapScreen`)
*   **Shape:** Increase corner radius (32px).
*   **Handle:** Make it wider and softer.
*   **Background:** Ensure it contrasts well with the cards.

## 3. Implementation Steps

1.  **Modify `lib/features/map/screens/map_screen.dart`**:
    *   Replace `SliverGrid` with `SliverList`.
    *   Remove `childAspectRatio`.

2.  **Modify `lib/features/feed/widgets/dish_card.dart`**:
    *   Remove fixed container heights where possible.
    *   Update visual styling (shadows, radius, colors).
    *   Improve the "Add" button.

3.  **Modify `lib/features/map/widgets/category_filter_bar.dart`**:
    *   Update chip styling.

4.  **Modify `lib/features/map/widgets/personalized_header.dart`**:
    *   Polish typography and spacing.

## 4. Verification
*   Check for overflow on small devices.
*   Verify aesthetic alignment with "Glass" / Modern Clean style.
