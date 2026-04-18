---
description: Generate and maintain Next.js 16 API routes with consistent patterns, validation, Prisma queries, and CORS headers for Chrome Extension access. Use when creating or editing files in src/app/api/.
auto_execution_mode: 1
---

# Next.js API Route Patterns

## Standard Response Shape
```typescript
{ success: boolean, data?: T, error?: string }
```

## Route Template
```typescript
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// CORS headers for Chrome Extension access
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    // Extract params...
    const data = await prisma.model.findMany();
    return NextResponse.json({ success: true, data }, { headers: corsHeaders });
  } catch (error) {
    console.error('[API] Error:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to fetch' },
      { status: 500, headers: corsHeaders }
    );
  }
}
```

## Rules
- Always include CORS headers (Chrome Extensions need them)
- Always wrap in try/catch with console.error logging
- Use Prisma for all DB operations — no raw SQL unless necessary
- Validate input before processing
- Return consistent `{ success, data, error }` shape
- Images: local `/uploads/` only, no external URLs
- Data: from database only, no hardcode

## Reference
- TanStack Query patterns: `<storage-project>/resources/skill-library/tanstack-query/SKILL.md`
- Security: `<storage-project>/resources/skill-library/security-nextjs/` (if exists in external-skills)
