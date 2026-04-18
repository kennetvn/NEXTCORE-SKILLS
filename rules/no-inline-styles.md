# No Inline Styles + Mandatory nextcore-ext-* Classes

## Rule 1: No Inline Styles
KHÔNG dùng `style={{}}` trong JSX/TSX cho dashboard/admin pages.

## Rule 2: Mandatory `nextcore-ext-*` Class Prefix
Mọi className trong dashboard/admin pages PHẢI có prefix `nextcore-ext-`.
KHÔNG dùng Tailwind utility classes (`px-4`, `text-sm`, `flex`, `rounded-xl`, etc.) làm styling chính.
Nếu element có className mà KHÔNG chứa `nextcore-ext-` → đó là **lỗi cần fix ngay**.

## Why
CTO directive:
- Inline styles khiến debug cực khó — không target được bằng DevTools
- Tailwind utilities không search được bằng class name, không rõ mục đích
- `nextcore-ext-*` classes tự mô tả: nhìn class biết ngay element thuộc component nào
- Đồng nhất design system toàn bộ dashboard

## How
1. Mỗi page tạo CSS file riêng hoặc dùng `extensions-shared.css`
2. Naming convention BEM: `.nextcore-ext-{block}__{element}--{modifier}`
   - Block = tên component/page: `txn`, `vip`, `renewal`, `dropdown`
   - Element = phần con: `header`, `card`, `btn`, `input`
   - Modifier = trạng thái: `active`, `expanded`, `income`, `vip`
3. Khi sửa page cũ có Tailwind/inline styles → **migrate sang CSS class luôn** (progressive cleanup)
4. Khi tạo page mới → **PHẢI dùng nextcore-ext-* từ đầu**, không dùng Tailwind

## Allowed Exceptions
- Dynamic computed values: `style={{ width: \`\${percent}%\` }}`
- Source-specific colors from config: `style={{ color: srcConf.color, background: srcConf.bg }}`
- One-off flex container in skeleton: `style={{ flex: 1, display: "flex" }}`

## ❌ NOT Allowed
```tsx
// BAD — Tailwind utilities
className="px-4 py-2 rounded-xl text-sm font-medium"
className="flex items-center gap-3 p-4"
className="text-[10px] font-bold uppercase"

// BAD — No prefix
className="transaction-card"
className="card-header"
```

## ✅ Correct
```tsx
// GOOD — nextcore-ext-* with BEM
className="nextcore-ext-txn-card"
className="nextcore-ext-txn-card__header"
className="nextcore-ext-txn-card--expanded"
className="nextcore-ext-dropdown__trigger--open"
```

## Pre-commit Check
Run before committing dashboard/admin TSX files:
```bash
grep -rn 'className="[^"]*"' src/app/dashboard/ src/app/admin/ | grep -v 'nextcore-ext-' | grep -v 'animate-' | head -20
```
If results found → fix before commit.

## Applies To
- `src/app/dashboard/**/*.tsx`
- `src/app/admin/**/*.tsx`
- `src/components/admin/**/*.tsx`
- `src/components/extensions/**/*.tsx`
- Any page importing `extensions-shared.css`
