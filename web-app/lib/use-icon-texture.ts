"use client"

import { useEffect, useState } from "react"
import { renderToStaticMarkup } from "react-dom/server"
import React from "react"
import type { LucideIcon } from "lucide-react"

/**
 * Rasterizes a Lucide icon component to an HTMLImageElement so it can be used
 * as a WebGL texture source. Uses ReactDOMServer.renderToStaticMarkup to
 * serialize the SVG, then loads it via a blob URL.
 *
 * Returns `null` while loading. The caller should branch on this and skip
 * rendering until the texture is ready.
 */
export function useIconTexture(
  Icon: LucideIcon | undefined,
  options: { size?: number; strokeWidth?: number; fill?: boolean } = {},
) {
  const { size = 256, strokeWidth = 2, fill = false } = options
  const [image, setImage] = useState<HTMLImageElement | null>(null)

  useEffect(() => {
    if (!Icon) {
      setImage(null)
      return
    }
    let cancelled = false
    let url: string | null = null

    try {
      const element = React.createElement(Icon, {
        size,
        strokeWidth,
        color: "white",
        fill: fill ? "white" : "none",
        absoluteStrokeWidth: false,
      })
      const markup = renderToStaticMarkup(element)
      const blob = new Blob([markup], { type: "image/svg+xml;charset=utf-8" })
      url = URL.createObjectURL(blob)
      const img = new Image()
      img.crossOrigin = "anonymous"
      img.onload = () => {
        if (cancelled) return
        setImage(img)
      }
      img.onerror = (e) => {
        console.error("[v0] icon image load failed", e)
      }
      img.src = url
    } catch (err) {
      console.error("[v0] icon rasterize failed", err)
    }

    return () => {
      cancelled = true
      if (url) URL.revokeObjectURL(url)
    }
  }, [Icon, size, strokeWidth, fill])

  return image
}
