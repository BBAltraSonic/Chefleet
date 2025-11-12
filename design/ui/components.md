# Chefleet UI Component Library

## Design System Overview

The Chefleet design system uses glass morphism as the primary visual language, combining translucent backgrounds with backdrop filters to create depth and hierarchy. All components follow consistent spacing, typography, and animation patterns.

## Core Components

### 1. ChefleetCard
**Purpose**: Standard container for displaying dish information, vendor details, and content cards.

**Dimensions & Layout**:
- Width: 100% of container
- Height: 120dp (auto for content)
- Border Radius: 16dp
- Padding: 16dp
- Margin: 8dp vertical

**Visual Properties**:
- Background: rgba(255, 255, 255, 0.1)
- Border: 1dp rgba(255, 255, 255, 0.2)
- Backdrop Filter: blur(10dp)
- Elevation: 8dp
- Shadow: 0 4dp 12dp rgba(0, 0, 0, 0.15)

**States**:
- Default: scale 1.0, opacity 1.0
- Pressed: scale 0.98, opacity 0.9 (100ms easeOut)
- Disabled: opacity 0.5

**Content Structure**:
- Image: 80dp x 80dp, border radius 8dp
- Title: 16dp semibold, #FFFFFF
- Subtitle: 14dp regular, rgba(255, 255, 255, 0.8)
- Price: 16dp bold, #FF6B35
- Meta information: 12dp regular, rgba(255, 255, 255, 0.6)

### 2. ChefleetFAB
**Purpose**: Primary action button for creating orders and accessing active orders.

**Dimensions & Position**:
- Size: 56dp x 56dp
- Border Radius: 28dp (circular)
- Default Position: right 24dp, bottom 24dp
- Active Order Position: center-x, bottom 100dp

**Visual Properties**:
- Background: #FF6B35 (primary brand color)
- Elevation: 12dp
- Shadow: 0 4dp 12dp rgba(0, 0, 0, 0.3)
- Icon: 24dp, #FFFFFF

**States**:
- Default: scale 1.0, rotation 0°
- Active: scale 1.05, rotation 5°, pulse animation
- Pressed: scale 0.95 (100ms easeOut)
- Disabled: opacity 0.5

**Animations**:
- Show: scale 0→1, rotation 180°→0° (300ms bounceOut)
- Pulse: 1.0→1.1 scale every 2s (when active order exists)

### 3. ChefleetMapHero
**Purpose**: Full-width map container for vendor and dish discovery.

**Dimensions**:
- Width: 100% of screen width
- Height: 60% (default), 20% (scrolled)
- Transition: 400ms easeInOutCubic

**Visual Properties**:
- Background: #F5F5F5 (map placeholder)
- Border Radius: bottom-left 24dp, bottom-right 24dp
- Opacity: 1.0 (default), 0.7 (scrolled)

**Interactions**:
- Pan: 600ms debounce after idle
- Zoom: pinch gesture support
- Tap on markers: show mini info card
- Scroll coordination: works with NestedScrollView

### 4. ChefleetChatBubble
**Purpose**: Message container for vendor-buyer communication.

**Sent Messages**:
- Alignment: right
- Max Width: 80% of container
- Background: #FF6B35
- Text Color: #FFFFFF
- Border Radius: top-left 16dp, top-right 16dp, bottom-left 16dp, bottom-right 4dp

**Received Messages**:
- Alignment: left
- Max Width: 80% of container
- Background: rgba(255, 255, 255, 0.9)
- Text Color: #333333
- Border Radius: top-left 16dp, top-right 16dp, bottom-right 16dp, bottom-left 4dp
- Backdrop Filter: blur(10dp)

**Common Properties**:
- Padding: 16dp horizontal, 12dp vertical
- Margin: 8dp horizontal, 4dp vertical
- Font: 14dp regular
- Shadow: 0 2dp 8dp rgba(0, 0, 0, 0.1)

**Animations**:
- Send: fade in 0→1, slide up 20→0 (200ms easeOut)
- Receive: fade in 0→1, slide up -20→0, scale 0.8→1.0 (300ms easeOutBack)

### 5. ChefleetButton
**Purpose**: Primary and secondary action buttons throughout the app.

**Primary Variant**:
- Height: 48dp
- Border Radius: 12dp
- Background: #FF6B35
- Text Color: #FFFFFF
- Padding: 24dp horizontal
- Elevation: 4dp

**Secondary Variant**:
- Height: 48dp
- Border Radius: 12dp
- Background: transparent
- Border: 2dp #FF6B35
- Text Color: #FF6B35
- Padding: 24dp horizontal

**Glass Variant**:
- Height: 48dp
- Border Radius: 12dp
- Background: rgba(255, 255, 255, 0.1)
- Border: 1dp rgba(255, 255, 255, 0.3)
- Text Color: #FFFFFF
- Backdrop Filter: blur(10dp)

**States**:
- Default: scale 1.0, elevation 4dp
- Pressed: scale 0.98, elevation 8dp (200ms easeOut)
- Disabled: opacity 0.5

### 6. ChefleetInput
**Purpose**: Text input fields for forms, search, and user input.

**Dimensions**:
- Height: 56dp
- Border Radius: 12dp
- Padding: 16dp horizontal, 8dp vertical
- Border: 1dp

**Visual States**:
- Default: background rgba(255, 255, 255, 0.1), border rgba(255, 255, 255, 0.3)
- Focused: border #FF6B35, border-width 2dp, elevation 4dp
- Error: border #FF4444, background rgba(255, 68, 68, 0.1)

**Typography**:
- Input: 16dp regular, #FFFFFF
- Placeholder: 16dp regular, rgba(255, 255, 255, 0.6)

## Screen-Specific Components

### 7. Buyer Home Screen
**Layout Structure**:
- Map Hero: 60% height (default)
- Glass Navigation Overlay: 80dp height
- Feed Grid: 2 columns, 12dp spacing
- Search Bar: top safe area + 16dp
- Filter Chips: horizontal scroll

**Responsive Behavior**:
- Small screens (< 360dp): 1 column grid
- Medium screens (360-414dp): 2 columns
- Large screens (> 414dp): 3 columns

### 8. Dish Detail Screen
**Image Hero**:
- Height: 40% of screen
- Border Radius: bottom 24dp
- Backdrop Filter: blur(20)

**Content Card**:
- Glass morphism background
- Title: 24dp bold, #FFFFFF
- Price: 20dp bold, #FF6B35
- Description: 16dp regular, rgba(255, 255, 255, 0.9)
- Vendor Info: horizontal scroll

**Action Buttons**:
- Add to Cart: primary ChefleetButton
- Contact Vendor: secondary ChefleetButton

### 9. Checkout Flow
**Progress Indicator**:
- Steps: Cart → Details → Confirm → Success
- Active step: #FF6B35 color
- Completed: checkmark icon

**Form Sections**:
- Contact Info: glass cards with ChefleetInput
- Pickup Time: time selector with custom buttons
- Special Instructions: multi-line ChefleetInput

**Price Summary**:
- Glass card at bottom
- Fixed position while scrolling
- Confirm button: primary ChefleetButton

### 10. Active Order Modal
**Trigger**: FAB tap when active order exists
**Animation**: FAB transforms to modal (300ms easeOutCubic)

**Content Structure**:
- Order Status: large icon + text
- Vendor Info: ChefleetCard variant
- Pickup Code: 6-digit code, large typography
- Action Buttons: Cancel, Contact, Complete

**Position**: Bottom sheet, 80% max height

### 11. Vendor Dashboard
**Stats Cards**:
- Today's Orders, Revenue, Rating
- 2x2 grid on tablets, 1x4 on phones
- Glass morphism with gradient backgrounds

**Order Queue**:
- List of active orders
- Accept/Reject buttons
- Real-time updates

**Quick Actions**:
- Add Dish: primary button
- Toggle Availability: toggle switch
- View Analytics: secondary button

### 12. Vendor Chat Interface
**Message List**:
- Standard ChefleetChatBubble
- Typing indicators
- Read receipts

**Input Area**:
- Multi-line ChefleetInput
- Send button: primary ChefleetFAB variant
- Photo attachment: icon button

**Order Context**:
- Related order info at top
- Quick responses: chip buttons

### 13. Profile Drawer
**Header**:
- User avatar: 80dp circular
- Name: 20dp bold
- Email: 16dp regular, rgba(255, 255, 255, 0.7)

**Menu Items**:
- Icon + text format
- Glass card background
- Chevron indicators
- Active state: background highlight

**Footer**:
- Sign Out button
- App version info

### 14. Settings Screen
**Sections**:
- Account, Notifications, Privacy, About
- Section headers: 14dp semibold
- Glass card containers for settings

**Setting Items**:
- Toggle switches for preferences
- Navigation arrows for detail screens
- Description text below title

## Accessibility Specifications

### Color Contrast
- All text: minimum 4.5:1 ratio
- Large text (18dp+): minimum 3:1 ratio
- Interactive elements: 3:1 ratio

### Touch Targets
- Minimum 44dp x 44dp for all interactive elements
- 8dp spacing between touch targets
- Focus indicators for keyboard navigation

### Typography Scale
- Headline 1: 32dp bold
- Headline 2: 24dp bold
- Headline 3: 20dp semibold
- Body 1: 16dp regular
- Body 2: 14dp regular
- Caption: 12dp regular

### Spacing System
- XS: 4dp
- SM: 8dp
- MD: 16dp
- LG: 24dp
- XL: 32dp
- XXL: 48dp

## Implementation Guidelines

### Flutter Translation
- Use Transform.scale for animations instead of changing width/height
- Prefer AnimatedOpacity over opacity changes
- Use ClipRRect for border radius
- Implement proper controller disposal for animations

### Performance Considerations
- Use RepaintBoundary wisely for complex widgets
- Implement image caching for network images
- Use ListView.builder for long lists
- Debounce expensive operations

### Theming
- All colors should be theme-aware
- Support light/dark modes
- Use semantic colors (primary, secondary, surface)
- Maintain consistent elevation patterns