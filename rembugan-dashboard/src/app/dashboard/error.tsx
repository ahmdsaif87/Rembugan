'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function DashboardError({
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
    <div className="flex min-h-[400px] flex-col items-center justify-center text-center p-6 border border-dashed rounded-2xl bg-card">
      <div className="max-w-md space-y-4">
        <h3 className="text-lg font-semibold tracking-tight text-destructive">Terjadi Kesalahan System</h3>
        <p className="text-muted-foreground text-sm">
          Dashboard mengalami kesalahan tidak terduga saat memproses data. Silakan coba muat ulang halaman.
        </p>
        <div className="flex justify-center gap-2">
          <Button onClick={() => reset()} variant="outline" size="sm">
            Coba Lagi
          </Button>
          <Button onClick={() => window.location.reload()} size="sm">
            Muat Ulang Halaman
          </Button>
        </div>
      </div>
    </div>
  )
}
