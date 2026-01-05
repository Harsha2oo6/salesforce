# Child-Parent Communication in LWC - Detailed Explanation

## Component Hierarchy in Your Code

```
┌─────────────────────────────────────────┐
│  niatHighlightsPanel (Grandparent)     │
│  ┌───────────────────────────────────┐  │
│  │  commonPopupButton (Parent)       │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  niatCallSteps (Child)      │  │  │
│  │  │  [Slotted inside modal]    │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## Concept 1: Custom Events in LWC

### What is a Custom Event?
A **Custom Event** is a way for a child component to communicate with its parent component. It's like the child "shouting" something that the parent can "hear".

### Event Structure

```javascript
this.dispatchEvent(new CustomEvent('eventName', {
    bubbles: true,      // Event travels UP the DOM tree
    composed: true,     // Event crosses Shadow DOM boundaries
    detail: {           // Optional: Data to send with event
        // your data here
    }
}));
```

### Event Properties Explained

#### 1. **Event Name** (`'closemodal'`)
- This is the **identifier** of the event
- Parent listens for this specific name
- Convention: Use lowercase with hyphens (kebab-case)

#### 2. **bubbles: true**
- **What it means**: Event travels UP the DOM tree (child → parent → grandparent)
- **Without bubbles**: Event stays only in the component that dispatched it
- **With bubbles: true**: Event can be caught by parent components

#### 3. **composed: true**
- **What it means**: Event can cross Shadow DOM boundaries
- **Why needed**: LWC uses Shadow DOM (encapsulated components)
- **Without composed**: Event trapped inside child's Shadow DOM
- **With composed: true**: Event can reach parent's Shadow DOM

#### 4. **detail** (Optional)
- **What it means**: Data payload sent with the event
- **Structure**: Any JavaScript object
- **Access**: Parent receives it in `event.detail`

---

## Concept 2: Event Flow in Your Code

### Event 1: `closemodal` Event (No Payload)

**Location**: `niatCallSteps.js` (line 283-286)

```javascript
// CHILD DISPATCHES EVENT
this.dispatchEvent(new CustomEvent('closemodal', {
    bubbles: true,      // Travels up to parent
    composed: true      // Crosses Shadow DOM
}));
```

**Event Journey**:
```
niatCallSteps (Child)
    ↓ [dispatches 'closemodal' event]
    ↓ bubbles: true (travels UP)
    ↓ composed: true (crosses Shadow DOM)
commonPopupButton (Parent)
    ↓ [listens on <section> element]
    ↓ onclosemodal={handleCloseModalFromChild}
    ↓ [calls handleCloseModalFromChild()]
    ↓ [calls this.handleClose()]
    ↓ [sets showModal = false]
    ✅ Modal closes!
```

**Parent Listens**: `commonPopupButton.html` (line 4)
```html
<section onclosemodal={handleCloseModalFromChild}>
```

**Parent Handles**: `commonPopupButton.js` (line 15-17)
```javascript
handleCloseModalFromChild() {
    this.handleClose();  // Closes the modal
}
```

---

### Event 2: `payloadtosendtoparent` Event (With Payload)

**Location**: `niatCallSteps.js` (line 290-292)

```javascript
// CHILD DISPATCHES EVENT WITH DATA
this.dispatchEvent(new CustomEvent('payloadtosendtoparent', {
    detail: { formData }  // ← PAYLOAD/DATA HERE
}));
```

**Event Journey**:
```
niatCallSteps (Child)
    ↓ [dispatches 'payloadtosendtoparent' event]
    ↓ detail: { formData: { fullName: "...", phoneNumber: "..." } }
    ↓ bubbles: true (default)
    ↓ composed: true (default)
niatHighlightsPanel (Grandparent)
    ↓ [listens on <c-niat-call-steps>]
    ↓ onpayloadtosendtoparent={handlePayloadToSendToParent}
    ↓ [receives event.detail.formData]
    ✅ Data received!
```

**Grandparent Listens**: `niatHighlightsPanel.html` (line 5)
```html
<c-niat-call-steps 
    onpayloadtosendtoparent={handlePayloadToSendToParent}>
</c-niat-call-steps>
```

**Grandparent Receives Data**:
```javascript
handlePayloadToSendToParent(event) {
    const formData = event.detail.formData;
    // formData = { fullName: "...", phoneNumber: "..." }
}
```

---

## Concept 3: Event Listening Patterns

### Pattern 1: Listen on HTML Element (Your Current Approach)

```html
<!-- Parent listens on a specific element -->
<section onclosemodal={handleCloseModalFromChild}>
    <slot></slot>  <!-- Child is slotted here -->
</section>
```

**How it works**:
- Event bubbles up from child
- Parent's `<section>` element catches it
- Handler function is called

### Pattern 2: Listen on Component Tag (Alternative)

```html
<!-- Parent listens directly on child component -->
<c-niat-call-steps 
    onclosemodal={handleCloseModalFromChild}>
</c-niat-call-steps>
```

**When to use**:
- When child is directly nested (not slotted)
- When you want to listen on the component itself

---

## Concept 4: Shadow DOM and Event Composition

### Why `composed: true` is Critical

```
┌─────────────────────────────────────┐
│  Parent Component (Shadow DOM #1)   │
│  ┌───────────────────────────────┐  │
│  │  Child Component (Shadow DOM #2)│
│  │  [Event dispatched here]      │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Without `composed: true`**:
- Event trapped in Child's Shadow DOM
- Parent never receives it
- ❌ Communication fails

**With `composed: true`**:
- Event escapes Child's Shadow DOM
- Event reaches Parent's Shadow DOM
- ✅ Communication succeeds

---

## Your Specific Implementation Flow

### When "Submit" Button is Clicked:

```
1. User clicks "Submit" in niatCallSteps
   ↓
2. handleFormSubmit() is called
   ↓
3. Form data collected: { fullName, phoneNumber }
   ↓
4. sendPayloadToParent(formData) called
   ↓
   └─→ Dispatches 'payloadtosendtoparent' event
       └─→ niatHighlightsPanel receives it
   ↓
5. resetState() called (resets component state)
   ↓
6. Dispatches 'closemodal' event
   ↓
   └─→ Event bubbles up with bubbles: true
   └─→ Event crosses Shadow DOM with composed: true
   └─→ commonPopupButton's <section> catches it
   └─→ handleCloseModalFromChild() called
   └─→ this.handleClose() called
   └─→ showModal = false
   └─→ ✅ Modal closes!
```

---

## Key Differences Between Your Two Events

| Property | `closemodal` | `payloadtosendtoparent` |
|----------|-------------|------------------------|
| **Purpose** | Signal to close modal | Send form data |
| **Has Payload?** | ❌ No | ✅ Yes (`detail: { formData }`) |
| **Who Listens?** | `commonPopupButton` (parent) | `niatHighlightsPanel` (grandparent) |
| **Where Listens?** | On `<section>` element | On `<c-niat-call-steps>` tag |
| **What Happens?** | Modal closes | Data processed |

---

## Best Practices

### ✅ DO:
1. Use kebab-case for event names: `'closemodal'`, `'formsubmit'`
2. Always use `composed: true` for cross-component communication
3. Use `bubbles: true` when parent needs to catch the event
4. Put data in `detail` property (not directly on event)
5. Use descriptive event names

### ❌ DON'T:
1. Don't use camelCase: `'closeModal'` ❌
2. Don't forget `composed: true` for Shadow DOM crossing
3. Don't put data directly on event object (use `detail`)
4. Don't use generic names like `'click'` or `'change'`

---

## Summary

**Event Name**: `'closemodal'`
- **Type**: CustomEvent
- **Payload**: None (just a signal)
- **Properties**: 
  - `bubbles: true` → Travels up DOM tree
  - `composed: true` → Crosses Shadow DOM boundaries
- **Purpose**: Signal parent to close modal
- **Flow**: 
  - `niatCallSteps` (child) dispatches
  - `commonPopupButton` (parent) receives
  - Modal closes via `showModal = false`

This is a **one-way communication** from child to parent using the **Event Bubbling** pattern with **Shadow DOM composition**.

