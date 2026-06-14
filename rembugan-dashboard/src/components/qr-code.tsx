"use client"

import { useState, useEffect } from "react"
import QRCode from "qrcode"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Download, Copy } from "lucide-react"
import { toast } from "sonner"

interface QrCodeDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  data: string
  title: string
  description?: string
}

export function QrCodeDialog({ open, onOpenChange, data, title, description }: QrCodeDialogProps) {
  const [qrSrc, setQrSrc] = useState<string>("")

  useEffect(() => {
    if (open && data) {
      QRCode.toDataURL(data, { width: 280, margin: 2 })
        .then((url) => setQrSrc(url))
        .catch(() => toast.error("Gagal generate QR"))
    } else {
      setQrSrc("")
    }
  }, [open, data])

  async function handleDownload() {
    if (!qrSrc) return
    const a = document.createElement("a")
    a.href = qrSrc
    a.download = `${title.toLowerCase().replace(/\s+/g, "-")}.png`
    a.click()
  }

  async function handleCopyLink() {
    try {
      await navigator.clipboard.writeText(data)
      toast.success("Link copied to clipboard")
    } catch {
      toast.error("Failed to copy link")
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          {description && <DialogDescription>{description}</DialogDescription>}
        </DialogHeader>
        <div className="flex flex-col items-center gap-4 py-4">
          <div className="rounded-lg border bg-white p-4">
            {qrSrc ? (
              <img src={qrSrc} alt="QR Code" width={280} height={280} />
            ) : (
              <div className="flex h-[280px] w-[280px] items-center justify-center text-muted-foreground text-sm">
                Generating...
              </div>
            )}
          </div>
          <p className="max-w-[260px] truncate text-xs text-muted-foreground font-mono">{data}</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" className="flex-1" onClick={handleCopyLink}>
            <Copy className="mr-2 h-4 w-4" />
            Copy Link
          </Button>
          <Button variant="outline" className="flex-1" onClick={handleDownload} disabled={!qrSrc}>
            <Download className="mr-2 h-4 w-4" />
            Download
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
