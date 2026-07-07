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
        <h3 className="text-lg font-semibold tracking-tight text-destructive">Gagal Memuat Data</h3>
        <p className="text-muted-foreground text-sm">
          Terjadi kesalahan saat mengambil atau menampilkan data pada panel ini.
        </p>
        <div className="flex justify-center gap-2">
          <Button onClick={() => reset()} variant="outline" size="sm">
            Coba Lagi
          </Button>
        </div>
      </div>
    </div>
  )
}
