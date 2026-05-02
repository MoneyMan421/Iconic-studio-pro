// Frontend-first mock data. Once Supabase/Postgres is wired up, swap these
// shapes for live queries — the types here intentionally mirror the SQL
// schema in the brief (icon_packs, icons, users, special_effects).

import type { EffectId } from "./effects"

export type IconSize = "sm" | "md" | "lg" | "xl"

export interface IconRecord {
  id: string
  name: string
  /** Lucide icon name; resolved via `lib/icon-library`. */
  glyph: string
  effect: EffectId
  size: IconSize
  transparent: boolean
}

export interface IconPack {
  id: string
  name: string
  description: string
  iconCount: number
  cover: { glyph: string; effect: EffectId }
  updatedAt: string
  icons: IconRecord[]
}

export interface AdminUser {
  id: number
  email: string
  role: "user" | "admin"
  packs: number
  createdAt: string
}

const today = new Date()
const ago = (days: number) =>
  new Date(today.getTime() - days * 86400_000).toISOString()

export const mockPacks: IconPack[] = [
  {
    id: "aurora",
    name: "Aurora",
    description: "A jewel-toned set tuned for dark dashboards and premium products.",
    iconCount: 12,
    cover: { glyph: "Diamond", effect: "diamond" },
    updatedAt: ago(2),
    icons: [
      { id: "i1", name: "Diamond", glyph: "Diamond", effect: "diamond", size: "lg", transparent: true },
      { id: "i2", name: "Gem", glyph: "Gem", effect: "ruby", size: "lg", transparent: true },
      { id: "i3", name: "Crown", glyph: "Crown", effect: "diamond", size: "lg", transparent: true },
      { id: "i4", name: "Sparkles", glyph: "Sparkles", effect: "hologram", size: "lg", transparent: true },
      { id: "i5", name: "Star", glyph: "Star", effect: "chrome", size: "md", transparent: true },
      { id: "i6", name: "Trophy", glyph: "Trophy", effect: "diamond", size: "md", transparent: true },
      { id: "i7", name: "Hexagon", glyph: "Hexagon", effect: "glass", size: "md", transparent: true },
      { id: "i8", name: "Heart", glyph: "Heart", effect: "ruby", size: "md", transparent: true },
      { id: "i9", name: "Shield", glyph: "Shield", effect: "chrome", size: "md", transparent: true },
      { id: "i10", name: "Bolt", glyph: "Bolt", effect: "neon", size: "md", transparent: true },
      { id: "i11", name: "Compass", glyph: "Compass", effect: "glass", size: "md", transparent: true },
      { id: "i12", name: "Anchor", glyph: "Anchor", effect: "chrome", size: "md", transparent: true },
    ],
  },
  {
    id: "neon-arcade",
    name: "Neon Arcade",
    description: "Loud, glowing icons for gaming and entertainment surfaces.",
    iconCount: 8,
    cover: { glyph: "Zap", effect: "neon" },
    updatedAt: ago(5),
    icons: [
      { id: "n1", name: "Zap", glyph: "Zap", effect: "neon", size: "lg", transparent: true },
      { id: "n2", name: "Ghost", glyph: "Ghost", effect: "neon", size: "lg", transparent: true },
      { id: "n3", name: "Music", glyph: "Music", effect: "hologram", size: "md", transparent: true },
      { id: "n4", name: "Flame", glyph: "Flame", effect: "neon", size: "md", transparent: true },
      { id: "n5", name: "Target", glyph: "Target", effect: "neon", size: "md", transparent: true },
      { id: "n6", name: "Rocket", glyph: "Rocket", effect: "hologram", size: "md", transparent: true },
      { id: "n7", name: "Wand", glyph: "Wand", effect: "hologram", size: "md", transparent: true },
      { id: "n8", name: "Sword", glyph: "Sword", effect: "chrome", size: "md", transparent: true },
    ],
  },
  {
    id: "glasshouse",
    name: "Glasshouse",
    description: "Subtle frosted glassmorphism — perfect for marketing pages.",
    iconCount: 6,
    cover: { glyph: "Aperture", effect: "glass" },
    updatedAt: ago(11),
    icons: [
      { id: "g1", name: "Aperture", glyph: "Aperture", effect: "glass", size: "lg", transparent: true },
      { id: "g2", name: "Cloud", glyph: "Cloud", effect: "glass", size: "lg", transparent: true },
      { id: "g3", name: "Layers", glyph: "Layers", effect: "glass", size: "md", transparent: true },
      { id: "g4", name: "Wifi", glyph: "Wifi", effect: "glass", size: "md", transparent: true },
      { id: "g5", name: "Globe", glyph: "Globe", effect: "glass", size: "md", transparent: true },
      { id: "g6", name: "Orbit", glyph: "Orbit", effect: "glass", size: "md", transparent: true },
    ],
  },
  {
    id: "cardinal",
    name: "Cardinal",
    description: "Ruby and chrome accents inspired by editorial branding.",
    iconCount: 5,
    cover: { glyph: "Heart", effect: "ruby" },
    updatedAt: ago(18),
    icons: [
      { id: "c1", name: "Heart", glyph: "Heart", effect: "ruby", size: "lg", transparent: true },
      { id: "c2", name: "Crown", glyph: "Crown", effect: "ruby", size: "lg", transparent: true },
      { id: "c3", name: "Award", glyph: "Award", effect: "chrome", size: "md", transparent: true },
      { id: "c4", name: "Bookmark", glyph: "Bookmark", effect: "ruby", size: "md", transparent: true },
      { id: "c5", name: "Key", glyph: "Key", effect: "chrome", size: "md", transparent: true },
    ],
  },
]

export const mockUsers: AdminUser[] = [
  { id: 1, email: "ada@facet.studio", role: "admin", packs: 12, createdAt: ago(120) },
  { id: 2, email: "june@vercel.com", role: "admin", packs: 4, createdAt: ago(98) },
  { id: 3, email: "kai@oss.dev", role: "user", packs: 7, createdAt: ago(64) },
  { id: 4, email: "noor@studio.lab", role: "user", packs: 2, createdAt: ago(45) },
  { id: 5, email: "leo@brand.co", role: "user", packs: 9, createdAt: ago(31) },
  { id: 6, email: "mira@team.io", role: "user", packs: 1, createdAt: ago(12) },
  { id: 7, email: "sasha@indie.app", role: "user", packs: 3, createdAt: ago(7) },
  { id: 8, email: "rio@gallery.xyz", role: "user", packs: 0, createdAt: ago(2) },
]

export function findPack(id: string): IconPack | undefined {
  return mockPacks.find((p) => p.id === id)
}
