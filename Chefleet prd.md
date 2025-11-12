# **How users and vendors *interact* with Chefleet — detailed behavior & micro-interactions**

Below is a clear, actionable description of **how the app works** from the moment someone opens it through the common flows — for **both Buyer** and **Vendor** roles — including the exact map / scroll / fade behaviour you requested and implementation notes designers/engineers can use.

---

# **1\. Global UI rules (always-on)**

* **Map hero height:** 60% of vertical screen height on buyer Home (portrait).

* **Minimum map height when feed expanded:** 20% of vertical screen height (map must never be fully hidden).

* **Map fade rule:** As the user scrolls the feed upward, the map **smoothly fades out** (opacity from 1 → 0.15) and **animates** its height down from 60% → 20%. When the user scrolls back to the very top of the feed (or taps a “Show Map” affordance), the map **fades back in** (opacity to 1\) and animates height back to 60%.

* **Animation specs:** 160–280ms ease-out for opacity and height transitions; use hardware-accelerated compositing, avoid jank on map view.

* **Parallax & depth:** The feed should appear to scroll over the map (subtle parallax). Use a translucent glass overlay on the feed top to visually blend with the map below.

---

# **2\. Key interaction primitives (controls & gestures)**

* **Tap pin:** taps a vendor pin → anchored mini info card slides up from the lower edge of the map; map remains centered on selected pin. Mini card includes vendor name, top dish, CTAs: *View Menu*, *Call*, *Get Directions*.

* **Tap mini card / View Menu:** expands to Vendor Detail screen or slides feed to vendor’s dishes (with map still visible per rules).

* **Pan map:** dragging the map updates center/zoom. While user is actively panning, **feed updates are paused**; after map idle for 600ms (debounce), feed refreshes to reflect new bounds.

* **Address search (map):** typing triggers Places Autocomplete; selecting result recenters map \+ updates feed. If search result outside current radius, app shows small toast: “Showing dishes near \[place\].”

* **Feed scroll:** scroll up \= map shrinks & fades; scroll to very top \= map returns to full size \+ opacity. Swipe-down on feed when at top pulls the map into focus (pull-to-reveal).

* **Expand feed to full-screen:** drag handle at top of feed expands it; map animates to 20% height and low opacity. Tap map handle or scroll to top to restore.

---

# **3\. Buyer flows & interactions (step-by-step)**

### **A. First open (Journeyed onboarding)**

1. Splash → role selection → allow location.

2. If Buyer, app auto-centers map on user location and loads pins/dishes in view. Short tooltip overlays point to: Address Search, Pin Tap, Dish Card Order CTA.

### **B. Discover on Home**

* **Hero map visible (60%):** user sees pins.

* **Below:** feed of dishes in map bounds.

* **Interaction:** user can either:

  * Tap a pin → mini card → View menu or View dish.

  * Scroll feed → map fades & minimizes (but still shows a contextual area).

  * Use feed search (dish / restaurant toggle) — results highlight map pins and animate to vendor location on select.

### **C. Ordering a dish**

1. On Dish Detail: choose quantity \+ pickup time slot (near-term defaults).

2. Tap **Order for Pickup (Cash)** → confirmation modal with pickup code and ETA.

3. Order created (`pending`) and vendor receives immediate realtime notification.

4. Chat button becomes available on Order Detail (see Chat below).

5. Buyer receives push when vendor Accepts / Marks Ready. Map entry for vendor may display a small “Your order ready” badge.

### **D. Using Directions**

* From Order Detail or Vendor Detail: tap **Get Directions** → app displays route polyline overlay on the map with ETA & distance and a small step-summary. Option to **Open in Google Maps** for full navigation.

### **E. Using In-app Chat (post-order)**

* Chat button active once order exists.

* Chat opens as a modal bottom sheet or full screen (depending on context).

* Conversation is scoped to `order_id`. Buyer sees seller name, last message, and can send text.

* New incoming chat messages trigger FCM notification.

### **F. Offline / Error states (Buyer)**

* If offline, feed shows cached results and a banner: “Offline — showing cached dishes.” Ordering is blocked with a clear CTA: “Retry when online.” Chat shows queued messages with “pending” indicator and retries when online.

---

# **4\. Vendor flows & interactions (step-by-step)**

### **A. First open (Vendor onboarding)**

1. Role selected → business info entry → place pin on map (drag), add hours & upload first dish.

2. Quick tour of Vendor Dashboard: Orders list, Add Dish, Map pin editor.

### **B. Receiving & managing orders**

* New order arrives via realtime channel; vendor sees a card in **New** with buyer name, dish, qty, pickup time.

* Buttons: **Accept**, **Reject**. Accept sets `status = accepted`. Vendor sets ready time and taps **Mark Ready**; customer notified. Vendor then **Complete** when buyer collects.

### **C. Chat with buyer**

* Vendor accesses order → Chat button → same order-scoped thread. Vendor receives push notifications for incoming messages. Vendor can respond to coordinate pickup. Vendor UI includes simple templated replies (e.g., “Your order will be ready in 10 min”).

### **D. Map / Listing management**

* Vendor can edit pin by dragging marker on their map snippet; preview as customer shows where their pin appears. Changes propagate to buyer map in realtime.

### **E. Performance & safeguards**

* Vendor can toggle dish availability; toggling off immediately removes dish from buyer feed for visible map bounds.

* Vendors have moderation tools in Settings (block abusive users, flag chats to admin).

---

# **5\. Micro-interactions & UI details (polish)**

* **Map fade animation:** use `AnimatedOpacity` \+ `AnimatedSize` (or platform equivalent). Opacity animates 1 → 0.15; size animates 60% → 20% over 200ms with `Curves.easeOutCubic`.

* **Pin clusters:** on zoom out show cluster bubbles with count; tap cluster to zoom in. Cluster expansion should be animated.

* **Mini-card entry:** slide-up from bottom of map with a small shadow and glass blur. Close by swiping down.

* **Feed card press:** gentle scale animation (0.98) on press.

* **Order confirmation:** show pickup code in large bold with copy & show-on-map button. Include a short haptic feedback on successful create.

* **Chat send:** message enters with “sending” micro-state then slides into list with timestamp. Failed send shows red error icon & retry affordance.

* **Route overlay:** drawing polyline uses subtle drop shadow and a contrasting thin stroke so pins and overlays remain legible.

---

# **6\. System behaviors & debounce / throttling rules**

* **Map → feed update debounce:** when user pans zooms the map, wait 600ms after last movement before refreshing feed.

* **Feed → map fade:** map fades proportional to feed scroll offset up to the defined reduction (linear interpolation). When user scrolls downward quickly, restore map with 150ms ease-in to avoid “jump.”

* **Search throttle:** address autocomplete typed queries debounced at 300ms and rate-limited client-side to avoid API overuse.

* **Chat rate limit:** prevent more than 5 messages per 10 seconds per user (server-side enforcement).

* **Order creation:** prevent duplicate orders by disabling create button and showing a spinner; idempotency token used server-side.

---

# **7\. Accessibility & error handling**

* All interactive elements have accessible labels; map long-press reads out vendor name & distance.

* Color contrast: ensure map overlays and feed text meet WCAG AA.

* Keyboard handling: chat input above keyboard; ensure reply field remains visible with safe area insets.

* Errors: show clear, actionable messages (e.g., “Unable to load route — try Open in Google Maps”).

---

# **8\. Acceptance criteria (interactions)**

* When buyer scrolls up feed from top → map height reduces smoothly from 60% → 20% and opacity reduces from 1 → 0.15.

* Scrolling back to top restores map to 60% height and opacity 1\.

* Tapping a pin always opens a mini info card anchored to bottom of map and centers map on the pin.

* Panning the map pauses feed updates; feed updates automatically within 600ms after the map becomes idle.

* Selecting an address from autocomplete recenters map and updates the feed to the new bounds.

* Order creation unlocks chat UI scoped to that order and notifies vendor & buyer.

* Tapping Get Directions draws the route polyline on the map and shows ETA, with an option to open Google Maps.

---

# **9\. Implementation notes (Flutter guidance)**

* Use a **NestedScrollView** or **CustomScrollView** with a `SliverPersistentHeader` for the map hero; implement animated height with `SliverPersistentHeaderDelegate` where `maxExtent = 0.6 * screenHeight` and `minExtent = 0.2 * screenHeight`.

* Use `AnimatedOpacity` on the map container for fade. Combine with `Transform.translate` for parallax feel.

* Map widget: Google Maps Flutter plugin (native map view inside the header). Keep map widget mounted even when minimized to preserve state.

* Debounce map bounds updates with a 600ms timer and cancel on further moves.

* Chat: use Supabase Realtime or Websocket channel; store messages in `messages` table and render with a virtualized list.

---

# **10\. Suggested copy for UI hints / tooltips**

* Map tooltip (first use): “Drag the map or search an address to explore dishes around any area.”

* Feed tooltip: “Scroll dishes — the map will fade but remains visible. Tap a dish to order.”

* Chat banner (order screen): “Use chat to coordinate pickup. Chefleet is cash-only — do not share payment details.”

Perfect — here’s the expanded interaction and structural layer for Chefleet including your new bottom navigation, order status FAB, notifications, settings, and profile icon.

Everything below integrates seamlessly with the existing scroll/map fade architecture and defines precise behavior \+ layout rules for designers and Flutter engineers.

---

## **🧭 11\. Navigation & Global Layout Additions**

### **A. Bottom Navigation Bar (always visible)**

Tabs:

1. Home — Default screen (Map \+ Feed layout described earlier)

2. Favourites — Grid of saved dishes or vendors (same card style as feed)

3. Notifications — List of system and chat alerts

4. Settings — App preferences, help, about

FAB (Floating Action Button):

* Order Status FAB (center-docked) — persistent circular button sitting in the nav bar’s center notch.

* Shows live order badge (count or ring when active order exists).

* Tapping opens the Active Order modal → shows order details, pickup code, and chat shortcut.

* If no order active → shows message: “No active pickups yet.”

Behavior Notes:

* Navigation bar uses liquid glass / frosted blur effect (same design language you mentioned before).

* Icon \+ label fade slightly when inactive (opacity 0.6 → 1 on active).

* FAB elevation 6dp; subtle bounce animation when a new order becomes active.

* When keyboard is open (e.g., in Chat), bottom nav hides with 180ms fade \+ slide-down animation.

Implementation Guidance (Flutter):

Scaffold(  
  extendBody: true,  
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,  
  floatingActionButton: OrderStatusFAB(),  
  bottomNavigationBar: GlassBottomNavBar(  
    items: \[  
      NavItem(icon: Icons.home\_rounded, label: 'Home'),  
      NavItem(icon: Icons.favorite\_rounded, label: 'Favourites'),  
      SizedBox(width: 56), // spacing for FAB  
      NavItem(icon: Icons.notifications\_rounded, label: 'Alerts'),  
      NavItem(icon: Icons.settings\_rounded, label: 'Settings'),  
    \],  
  ),  
);  
---

### **B. Profile Icon (top-left)**

* Location: AppBar / overlay on map’s top left corner (over glass blur layer).

* Icon: Circular avatar with user’s initials or profile image.

* Action: Tap → opens Profile Drawer or full-screen Profile Sheet.

* Profile Drawer contents:

  * Edit Profile

  * My Orders

  * Payment preferences (future)

  * Help & Support

  * Logout

Behavior:

* Drawer slides from left with semi-transparent overlay.

* On scroll or map pan, profile icon stays pinned (safe area position).

* Light shadow to separate from map imagery.

---

## **⚙️ 12\. Navigation-aware Context Rules**

| Context | Map State | Bottom Nav | FAB | Profile Icon |
| ----- | ----- | ----- | ----- | ----- |
| Home (Map \+ Feed) | Visible (scroll reactive) | Visible | Active | Visible |
| Vendor Detail | Reduced (20%) | Visible | Active | Visible |
| Dish Detail | Hidden | Visible | Active | Visible |
| Chat Screen | Hidden | Hidden (keyboard overlap) | Hidden | Hidden |
| Order Detail | Reduced (20%) | Visible | Highlighted | Visible |
| Notifications / Settings / Favourites | Hidden | Visible | Inactive | Visible |

---

## **💬 13\. Micro-Interactions (New)**

* FAB Pulse: Small scale pulse (1.0 → 1.05) every 8s when an active order exists.

* Badge Animation: When new notification arrives, the Notifications icon animates upward 4px then settles.

* Tab Change: Fade-through transition (Material motion spec) between main tabs, preserving the map state in memory.

* Profile Avatar Load: Fade-in \+ 80ms scale for a smooth entrance after async image fetch.

---

## **🧩 14\. Implementation Notes (Flutter)**

* Use BottomAppBar with ClipPath notch for FAB cut-out (custom painter for liquid glass style).

* Wrap nav bar in a BackdropFilter for the blur.

* Use Provider or Riverpod to maintain global navigation state and active order count.

* Persist Map widget as a single instance in the navigation stack — switching tabs should not rebuild it.

* Profile icon overlay can live inside a Positioned widget above the NestedScrollView header.

---

## **✅ 15\. Acceptance Criteria (Navigation Layer)**

* Bottom nav always visible except during chat or keyboard entry.

* FAB center-docked and responsive; opens Active Order modal.

* Profile icon always visible in Home context and opens Profile Drawer.

* Notifications tab lists chat & order system notifications.

* Switching tabs doesn’t reset map or feed scroll position.

* Nav transitions use fade-through animation, 200–250ms.

---

Would you like me to now:

1. 🧱 Generate a Flutter scaffold layout code example showing this entire nav structure (FAB notch, glass effect, profile overlay, map \+ feed area),

    or

2. 🖼️ Create an annotated wireframe showing all new elements in their positions and how they animate together?

