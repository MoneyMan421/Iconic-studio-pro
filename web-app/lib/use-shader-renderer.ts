"use client"

import { useEffect, useRef } from "react"

/**
 * useShaderRenderer
 *
 * Compiles a fragment shader and renders the supplied texture source to a
 * canvas via WebGL. Handles cleanup, animation when `timeUniform` is true,
 * and recompiles when the shader source changes. Accepts either an
 * HTMLImageElement or HTMLCanvasElement as the texture source so callers can
 * rasterize SVG icons onto a 2D canvas first if needed.
 */
export function useShaderRenderer(
  fragmentShader: string,
  source: HTMLImageElement | HTMLCanvasElement | null,
  options: { timeUniform?: boolean } = {},
) {
  const { timeUniform = false } = options
  const canvasRef = useRef<HTMLCanvasElement | null>(null)
  const rafRef = useRef<number | null>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas || !source) return

    const gl = canvas.getContext("webgl", { premultipliedAlpha: false, antialias: true })
    if (!gl) {
      console.warn("[v0] WebGL not available")
      return
    }

    const vertexSrc = `
      attribute vec2 aPos;
      attribute vec2 aUv;
      varying vec2 vUv;
      void main() {
        vUv = aUv;
        gl_Position = vec4(aPos, 0.0, 1.0);
      }
    `

    const compile = (type: number, src: string) => {
      const sh = gl.createShader(type)
      if (!sh) return null
      gl.shaderSource(sh, src)
      gl.compileShader(sh)
      if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) {
        console.error("[v0] shader compile error:", gl.getShaderInfoLog(sh))
        gl.deleteShader(sh)
        return null
      }
      return sh
    }

    const vs = compile(gl.VERTEX_SHADER, vertexSrc)
    const fs = compile(gl.FRAGMENT_SHADER, fragmentShader)
    if (!vs || !fs) return

    const program = gl.createProgram()
    if (!program) return
    gl.attachShader(program, vs)
    gl.attachShader(program, fs)
    gl.linkProgram(program)
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      console.error("[v0] program link error:", gl.getProgramInfoLog(program))
      return
    }
    gl.useProgram(program)

    // Two triangles forming a fullscreen quad. UVs are flipped vertically so
    // textures render upright (WebGL's coordinate system has Y pointing up).
    const vertices = new Float32Array([
      -1, -1, 0, 1,
       1, -1, 1, 1,
      -1,  1, 0, 0,
       1,  1, 1, 0,
    ])

    const buffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW)

    const stride = 4 * 4
    const aPos = gl.getAttribLocation(program, "aPos")
    gl.vertexAttribPointer(aPos, 2, gl.FLOAT, false, stride, 0)
    gl.enableVertexAttribArray(aPos)

    const aUv = gl.getAttribLocation(program, "aUv")
    gl.vertexAttribPointer(aUv, 2, gl.FLOAT, false, stride, 8)
    gl.enableVertexAttribArray(aUv)

    const texture = gl.createTexture()
    gl.activeTexture(gl.TEXTURE0)
    gl.bindTexture(gl.TEXTURE_2D, texture)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    try {
      gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        source,
      )
    } catch (err) {
      console.error("[v0] texImage2D failed:", err)
      return
    }

    const uTexture = gl.getUniformLocation(program, "uTexture")
    gl.uniform1i(uTexture, 0)

    const uTime = timeUniform ? gl.getUniformLocation(program, "uTime") : null

    gl.enable(gl.BLEND)
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

    const draw = (t: number) => {
      gl.viewport(0, 0, canvas.width, canvas.height)
      gl.clearColor(0, 0, 0, 0)
      gl.clear(gl.COLOR_BUFFER_BIT)
      if (uTime) gl.uniform1f(uTime, t * 0.001)
      gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
      if (timeUniform) {
        rafRef.current = requestAnimationFrame(draw)
      }
    }

    if (timeUniform) {
      rafRef.current = requestAnimationFrame(draw)
    } else {
      draw(0)
    }

    return () => {
      if (rafRef.current != null) cancelAnimationFrame(rafRef.current)
      gl.deleteProgram(program)
      gl.deleteShader(vs)
      gl.deleteShader(fs)
      gl.deleteTexture(texture)
      gl.deleteBuffer(buffer)
    }
  }, [fragmentShader, source, timeUniform])

  return canvasRef
}
