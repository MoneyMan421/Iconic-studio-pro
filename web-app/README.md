# Iconic Studio Pro — Web App

The official **web client** for Iconic Studio Pro: a Next.js 16 + React 19
dashboard for creating, editing, and publishing icon packs and shader effects.

This is a sibling of the Flutter mobile app that lives at the repository root
(`lib/`, `pubspec.yaml`). The two apps are independent — touching one will not
affect the other.

## What's inside

- `app/` — Next.js App Router pages
  - `app/login`, `app/signup` — auth screens
  - `app/dashboard` — user dashboard and pack editor (`/dashboard/packs/[id]`)
  - `app/admin` — admin area (users, effects manager)
- `components/` — UI (Radix UI + shadcn/ui) and feature components
  (`pack-editor`, `effects-manager`, `effect-canvas`, `app-shell`, …)
- `lib/` — shared logic (`effects.ts`, `icon-library.ts`, `mock-data.ts`,
  `use-shader-renderer.ts`, `use-icon-texture.ts`, `utils.ts`)
- `hooks/`, `styles/`, `public/` — standard Next.js folders

## Stack

- Next.js `16.2.4` (App Router) on React `19`
- TypeScript `5.7`
- Tailwind CSS `4` + `tw-animate-css`
- Radix UI primitives via shadcn/ui patterns
- `react-hook-form` + `zod` for forms, `recharts` for charts, `sonner` for toasts

## Local development

```bash
cd web-app
pnpm install        # lockfile is pnpm-lock.yaml
pnpm dev            # http://localhost:3000
```

Other scripts: `pnpm build`, `pnpm start`, `pnpm lint`.

## Deployment

The app is intended for deployment to the production domain (e.g. Vercel).
Set environment variables via `.env.local` (ignored by git) or your hosting
provider's dashboard.
