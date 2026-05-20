"use client";

import { useEffect, useState } from "react";

export default function Home() {
  const [ready, setReady] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function init() {
      try {
        const wasm = await import(/* webpackIgnore: true */ "/wasm/iconic.js");
        if (typeof wasm.default === "function") {
          await wasm.default();
        }
        setReady(true);
      } catch (e) {
        console.error(e);
        setError(e?.message || "Failed to load WASM engine");
      }
    }
    init();
  }, []);

  if (error) {
    return <main style={{ padding: 20 }}>Error loading engine: {error}</main>;
  }

  if (!ready) {
    return <main style={{ padding: 20 }}>Loading WASM engine…</main>;
  }

  return (
    <main style={{ padding: 20 }}>
      <h1 style={{ fontSize: 32, fontWeight: 700 }}>Iconic Studio Pro</h1>
      <p>WASM engine loaded successfully.</p>
      <div
        style={{
          width: 640,
          height: 360,
          borderRadius: 16,
          border: "1px solid #333",
          marginTop: 20
        }}
      />
    </main>
  );
}
