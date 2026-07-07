'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error(error)
  }, [error])

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-background text-foreground p-4">
      <div className="w-full max-w-md text-center space-y-6">
        <div className="inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-destructive/10 text-destructive mb-2">
          <svg
            className="h-8 w-8"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth={2}
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
        </div>
        <h2 className="text-2xl font-bold tracking-tight">Terjadi Kesalahan System</h2>
        <p className="text-muted-foreground text-sm leading-relaxed">
          Dashboard mengalami kesalahan tidak terduga saat memproses data. Silakan coba muat ulang halaman.
        </p>
        <div className="flex justify-center gap-4">
          <Button onClick={() => reset()} variant="default">
            Coba Lagi
          </Button>
          <Button onClick={() => window.location.reload()} variant="outline">
            Muat Ulang Halaman
          </Button>
        </div>
      </div>
    </div>
  )
}
