---
description: NextCore Design System tokens, NextCore CSS class convention, shadcn/ui theming, and responsive design patterns. Auto-loads when editing TSX/CSS files for consistent styling across all projects.
auto_execution_mode: 1
---

# NextCore Design System

## CSS Class Convention (MANDATORY)
All custom CSS classes MUST use NextCore prefix:
```
nextcore-{area}-{component}-{element}-{modifier}
```

Area prefixes:
- `nextcore-admin-*` → Admin dashboard
- `nextcore-auth-*` → Authentication
- `nextcore-ext-*` → Extensions dashboard
- `nextcore-acl-*` → Accordion Card List
- `nextcore-sto-*` → Search Transition Overlay

Tailwind utility classes do NOT need prefix. Shadcn/UI internal classes unchanged.

## Debug Attributes
Add `data-nextcore-*` for easier debugging:
```html
<div data-nextcore-page="admin-bookings" data-nextcore-component="booking-table">
```

## Design References
- Full design system: `<storage-project>/resources/skill-library/aka-design-system/SKILL.md`
- Class convention: `<storage-project>/resources/skill-library/nextcore-class-convention/SKILL.md`
- Shadcn theme: `<storage-project>/resources/skill-library/shadcn-homestay/SKILL.md`
- Responsive: `<storage-project>/resources/skill-library/responsive-design/SKILL.md`
- UI patterns: `<storage-project>/resources/skill-library/ui-ux-patterns/SKILL.md`
- CSS architecture: `<storage-project>/resources/skill-library/css-architecture/SKILL.md`

## Rules
- Images: local `/uploads/` only
- CSS files must be ≤500 lines
- Use design system palette/spacing/typography only
- No generic class names (container, header, card) without nextcore prefix
