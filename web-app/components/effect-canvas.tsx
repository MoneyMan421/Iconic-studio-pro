"use client"

import { cn } from "@/lib/utils"
import { getEffect, type EffectId } from "@/lib/effects"
import { findIcon } from "@/lib/icon-library"
import { useIconTexture } from "@/lib/use-icon-texture"
import { useShaderRenderer } from "@/lib/use-shader-renderer"

interface EffectCanvasProps {
  glyph: string
  effect: EffectId
  /** Pixel size of the rendered canvas (square). */
  size?: number
  /** Stroke width passed to the Lucide icon when rasterizing. */
  strokeWidth?: number
  className?: string
}

/**
 * Renders a Lucide icon to an offscreen SVG, rasterizes it to a bitmap, and
 * draws it through the chosen WebGL fragment shader. While the texture is
 * still loading we render a soft skeleton so the layout stays steady.
 */
export function EffectCanvas({
  glyph,
  effect,
  size = 192,
  strokeWidth = 2,
  className,
}: EffectCanvasProps) {
  const lib = findIcon(glyph)
  const eff = getEffect(effect)
  const image = useIconTexture(lib?.Icon, { size, strokeWidth })
  const canvasRef = useShaderRenderer(eff.fragmentShader, image, {
    timeUniform: eff.animated,
  })

  return (
    <div
      className={cn(
        "relative grid place-items-center overflow-hidden rounded-2xl bg-muted/40",
        className,
      )}
      style={{ width: size, height: size }}
    >
      <canvas
        ref={canvasRef}
        width={size}
        height={size}
        aria-label={`${lib?.name ?? glyph} icon with ${eff.name} effect`}
        role="img"
        className={cn(
          "h-full w-full transition-opacity duration-300",
          image ? "opacity-100" : "opacity-0",
        )}
      />
      {!image ? (
        <div className="absolute inset-0 grid place-items-center">
          <div className="size-8 rounded-full border border-border/60 border-t-primary animate-spin" />
        </div>
      ) : null}
    </div>
  )
}
