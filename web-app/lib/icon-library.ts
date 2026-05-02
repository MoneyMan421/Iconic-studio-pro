// Curated set of Lucide icons exposed as the in-app icon library.
// Lucide is MIT licensed and ships with Next.js starter; this module just
// defines the searchable catalog used by the icon editor.

import {
  Anchor,
  Aperture,
  Award,
  Bell,
  Bolt,
  Bookmark,
  Camera,
  Cloud,
  Code,
  Compass,
  Cpu,
  Crown,
  Diamond,
  Feather,
  Flame,
  Flower,
  Gem,
  Ghost,
  Globe,
  Heart,
  Hexagon,
  Home,
  Infinity as InfinityIcon,
  Key,
  Layers,
  Leaf,
  Lightbulb,
  Lock,
  type LucideIcon,
  Map,
  MessageCircle,
  Moon,
  Music,
  Orbit,
  Package,
  Palette,
  Rocket,
  Shield,
  ShoppingBag,
  Sparkles,
  Star,
  Sun,
  Sword,
  Target,
  Trophy,
  Wand2,
  Waves,
  Wifi,
  Wind,
  Zap,
} from "lucide-react"

export interface LibraryIcon {
  name: string
  Icon: LucideIcon
  /** Loose category used for filtering. */
  category: "object" | "nature" | "tech" | "symbol" | "ui"
}

export const iconLibrary: LibraryIcon[] = [
  { name: "Diamond", Icon: Diamond, category: "symbol" },
  { name: "Gem", Icon: Gem, category: "symbol" },
  { name: "Crown", Icon: Crown, category: "symbol" },
  { name: "Star", Icon: Star, category: "symbol" },
  { name: "Sparkles", Icon: Sparkles, category: "symbol" },
  { name: "Heart", Icon: Heart, category: "symbol" },
  { name: "Trophy", Icon: Trophy, category: "symbol" },
  { name: "Award", Icon: Award, category: "symbol" },
  { name: "Hexagon", Icon: Hexagon, category: "symbol" },
  { name: "Infinity", Icon: InfinityIcon, category: "symbol" },

  { name: "Rocket", Icon: Rocket, category: "object" },
  { name: "Lightbulb", Icon: Lightbulb, category: "object" },
  { name: "Wand", Icon: Wand2, category: "object" },
  { name: "Sword", Icon: Sword, category: "object" },
  { name: "Shield", Icon: Shield, category: "object" },
  { name: "Key", Icon: Key, category: "object" },
  { name: "Lock", Icon: Lock, category: "object" },
  { name: "Bell", Icon: Bell, category: "object" },
  { name: "Bookmark", Icon: Bookmark, category: "object" },
  { name: "Camera", Icon: Camera, category: "object" },
  { name: "Anchor", Icon: Anchor, category: "object" },
  { name: "Compass", Icon: Compass, category: "object" },
  { name: "Map", Icon: Map, category: "object" },
  { name: "Package", Icon: Package, category: "object" },
  { name: "Bag", Icon: ShoppingBag, category: "object" },
  { name: "Palette", Icon: Palette, category: "object" },

  { name: "Cpu", Icon: Cpu, category: "tech" },
  { name: "Code", Icon: Code, category: "tech" },
  { name: "Wifi", Icon: Wifi, category: "tech" },
  { name: "Layers", Icon: Layers, category: "tech" },
  { name: "Aperture", Icon: Aperture, category: "tech" },
  { name: "Bolt", Icon: Bolt, category: "tech" },
  { name: "Zap", Icon: Zap, category: "tech" },
  { name: "Target", Icon: Target, category: "tech" },

  { name: "Sun", Icon: Sun, category: "nature" },
  { name: "Moon", Icon: Moon, category: "nature" },
  { name: "Cloud", Icon: Cloud, category: "nature" },
  { name: "Flame", Icon: Flame, category: "nature" },
  { name: "Leaf", Icon: Leaf, category: "nature" },
  { name: "Flower", Icon: Flower, category: "nature" },
  { name: "Feather", Icon: Feather, category: "nature" },
  { name: "Wind", Icon: Wind, category: "nature" },
  { name: "Waves", Icon: Waves, category: "nature" },
  { name: "Globe", Icon: Globe, category: "nature" },
  { name: "Orbit", Icon: Orbit, category: "nature" },

  { name: "Home", Icon: Home, category: "ui" },
  { name: "Message", Icon: MessageCircle, category: "ui" },
  { name: "Music", Icon: Music, category: "ui" },
  { name: "Ghost", Icon: Ghost, category: "ui" },
]

export function findIcon(name: string): LibraryIcon | undefined {
  return iconLibrary.find((i) => i.name.toLowerCase() === name.toLowerCase())
}
