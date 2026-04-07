# Accessibility Reference

## accessibility-check.sh

> Script: [`scripts/accessibility-check.sh`](scripts/accessibility-check.sh)

## Playwright AXE Test Fixture

```typescript
// tests/helpers/a11y.ts
import AxeBuilder from '@axe-core/playwright';
import type { Page, TestInfo } from '@playwright/test';

export interface A11yOptions {
  /** CSS selectors to include in scan */
  include?: string[];
  /** CSS selectors to exclude from scan */
  exclude?: string[];
  /** Specific rules to disable */
  disableRules?: string[];
  /** WCAG tags to check (defaults to WCAG 2.1 AA) */
  tags?: string[];
}

export async function checkA11y(
  page: Page,
  testInfo: TestInfo,
  options: A11yOptions = {},
) {
  const {
    include,
    exclude,
    disableRules,
    tags = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'],
  } = options;

  let builder = new AxeBuilder({ page }).withTags(tags);

  if (include) {
    for (const selector of include) {
      builder = builder.include(selector);
    }
  }

  if (exclude) {
    for (const selector of exclude) {
      builder = builder.exclude(selector);
    }
  }

  if (disableRules) {
    builder = builder.disableRules(disableRules);
  }

  const results = await builder.analyze();

  // Attach full results for debugging
  await testInfo.attach('accessibility-scan-results', {
    body: JSON.stringify(results, null, 2),
    contentType: 'application/json',
  });

  return results;
}
```

```typescript
import { test, expect } from '@playwright/test';
import { checkA11y } from './helpers/a11y';

test.describe('Accessibility', () => {
  test('homepage passes WCAG 2.1 AA', async ({ page }, testInfo) => {
    await page.goto('/');
    const results = await checkA11y(page, testInfo);
    expect(results.violations).toEqual([]);
  });

  test('navigation menu passes after opening', async ({ page }, testInfo) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Menu' }).click();
    await page.locator('#nav-flyout').waitFor();

    const results = await checkA11y(page, testInfo, {
      include: ['#nav-flyout'],
    });
    expect(results.violations).toEqual([]);
  });

  test('form passes with known issue excluded', async ({ page }, testInfo) => {
    await page.goto('/signup');
    const results = await checkA11y(page, testInfo, {
      exclude: ['#third-party-captcha'],
      disableRules: ['color-contrast'], // vendor widget
    });
    expect(results.violations).toEqual([]);
  });

  test('component scan — combobox', async ({ page }, testInfo) => {
    await page.goto('/components/combobox');
    const results = await checkA11y(page, testInfo, {
      include: ['[role="combobox"]', '[role="listbox"]'],
    });
    expect(results.violations).toEqual([]);
  });
});
```

---

## ARIA Patterns Quick Reference

### Combobox

```tsx
<label htmlFor="state-input">State</label>
<div className="combobox-wrapper">
  <input
    id="state-input"
    type="text"
    role="combobox"
    aria-autocomplete="both"
    aria-expanded={isOpen}
    aria-controls="state-listbox"
    aria-activedescendant={activeOptionId ?? undefined}
  />
  <button
    type="button"
    tabIndex={-1}
    aria-label="States"
    aria-expanded={isOpen}
    aria-controls="state-listbox"
    onClick={toggleListbox}
  >
    <ChevronDownIcon aria-hidden="true" />
  </button>
</div>
<ul
  id="state-listbox"
  role="listbox"
  aria-label="States"
  hidden={!isOpen}
>
  {filteredOptions.map((option) => (
    <li
      key={option.id}
      id={`option-${option.id}`}
      role="option"
      aria-selected={option.id === activeOptionId}
      onClick={() => selectOption(option)}
    >
      {option.label}
    </li>
  ))}
</ul>
```

**Keyboard:** Down/Up arrows navigate options, Enter selects, Escape closes, Home/End to textbox.

---

### Tabs

```tsx
<div role="tablist" aria-label="Settings">
  <button
    role="tab"
    id="tab-general"
    aria-selected={activeTab === 'general'}
    aria-controls="panel-general"
    tabIndex={activeTab === 'general' ? 0 : -1}
  >
    General
  </button>
  <button
    role="tab"
    id="tab-security"
    aria-selected={activeTab === 'security'}
    aria-controls="panel-security"
    tabIndex={activeTab === 'security' ? 0 : -1}
  >
    Security
  </button>
</div>

<div
  role="tabpanel"
  id="panel-general"
  aria-labelledby="tab-general"
  hidden={activeTab !== 'general'}
>
  General settings...
</div>
<div
  role="tabpanel"
  id="panel-security"
  aria-labelledby="tab-security"
  hidden={activeTab !== 'security'}
>
  Security settings...
</div>
```

**Keyboard:** Arrow Left/Right between tabs, Tab into panel, Home/End to first/last tab.

Active tab: `tabIndex={0}`, `aria-selected="true"`. Others: `tabIndex={-1}`.

---

### Dialog (Modal)

```tsx
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
>
  <h2 id="dialog-title">Delete Item</h2>
  <p id="dialog-desc">This action cannot be undone.</p>
  <button onClick={onConfirm}>Delete</button>
  <button onClick={onClose}>Cancel</button>
</div>
```

Focus trapped inside, Escape closes, focus returns to trigger on close.

---

### Accordion

```tsx
<div>
  <h3>
    <button
      aria-expanded={isOpen}
      aria-controls="section-1-content"
      id="section-1-header"
    >
      Section Title
    </button>
  </h3>
  <div
    id="section-1-content"
    role="region"
    aria-labelledby="section-1-header"
    hidden={!isOpen}
  >
    Section content...
  </div>
</div>
```

**Keyboard:** Enter/Space toggles section. Optionally: Up/Down between headers, Home/End to first/last.

---

### Alert

```tsx
<div role="alert">
  Form submitted successfully.
</div>
```

`role="alert"` = assertive live region. For non-urgent info use `role="status"` (polite).

---

### Listbox

```tsx
<label id="label-fruits">Favorite Fruit</label>
<ul
  role="listbox"
  aria-labelledby="label-fruits"
  tabIndex={0}
>
  <li role="option" aria-selected={selected === 'apple'}>Apple</li>
  <li role="option" aria-selected={selected === 'banana'}>Banana</li>
  <li role="option" aria-selected={selected === 'cherry'}>Cherry</li>
</ul>
```

**Multi-select:** add `aria-multiselectable="true"` to the listbox.

**Keyboard:** Up/Down to navigate, Enter/Space to select, Home/End, type-ahead.

---

### Switch

```tsx
<button
  role="switch"
  aria-checked={isEnabled}
  onClick={() => setIsEnabled(!isEnabled)}
>
  Dark Mode
</button>
```

**Keyboard:** Enter or Space toggles between on/off.

---

### Slider

```tsx
<label id="volume-label">Volume</label>
<div
  role="slider"
  tabIndex={0}
  aria-labelledby="volume-label"
  aria-valuemin={0}
  aria-valuemax={100}
  aria-valuenow={currentVolume}
  aria-valuetext={`${currentVolume}%`}
>
  <div className="thumb" style={{ left: `${currentVolume}%` }} />
</div>
```

**Keyboard:** Left/Down decrease, Right/Up increase, Home min, End max, Page Up/Down large steps.

---

### Radio Group

```tsx
<div role="radiogroup" aria-labelledby="group-label">
  <span id="group-label">Notification Preference</span>
  <div
    role="radio"
    aria-checked={preference === 'email'}
    tabIndex={preference === 'email' ? 0 : -1}
    onClick={() => setPreference('email')}
    onKeyDown={handleArrowKeys}
  >
    Email
  </div>
  <div
    role="radio"
    aria-checked={preference === 'sms'}
    tabIndex={preference === 'sms' ? 0 : -1}
    onClick={() => setPreference('sms')}
    onKeyDown={handleArrowKeys}
  >
    SMS
  </div>
</div>
```

**Keyboard:** Arrow keys move between options and select. Tab moves to/from the group.

---

## Common WCAG 2.1 AA Rules

| Rule | WCAG | Description |
|------|------|-------------|
| **1.1.1** | A | Non-text content has text alternative |
| **1.3.1** | A | Info and relationships conveyed through structure |
| **1.4.3** | AA | Contrast ratio at least 4.5:1 (3:1 for large text) |
| **1.4.11** | AA | Non-text contrast at least 3:1 (UI components, focus indicators) |
| **2.1.1** | A | All functionality available from keyboard |
| **2.1.2** | A | No keyboard trap |
| **2.4.3** | A | Focus order is meaningful |
| **2.4.6** | AA | Headings and labels describe topic or purpose |
| **2.4.7** | AA | Focus indicator is visible |
| **2.5.3** | A | Accessible name matches visible label |
| **4.1.2** | A | Name, role, value available for all UI components |
| **4.1.3** | AA | Status messages conveyed without receiving focus |

---

## Visual Accessibility Checklist

- [ ] Focus rings visible on all interactive elements (min 2px, contrasting color)
- [ ] Hover and focus styles match (no mouse-only affordances)
- [ ] Color is not the only means of conveying information
- [ ] Touch targets at least 44x44 CSS pixels (WCAG 2.5.8 AAA, but recommended for AA)
- [ ] `prefers-reduced-motion` respected for animations
- [ ] `forced-colors` / high-contrast mode: use `currentcolor` for SVG fills
- [ ] Text resizable to 200% without loss of content (WCAG 1.4.4)
