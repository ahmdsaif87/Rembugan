const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"

async function getPrivacyPolicy(): Promise<string> {
  try {
    const res = await fetch(`${API_BASE_URL}/privacy-policy`, {
      cache: "no-store",
    })
    const json = await res.json()
    return json?.data?.content || ""
  } catch {
    return ""
  }
}

export default async function PrivacyPolicyPage() {
  const content = await getPrivacyPolicy()

  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto max-w-3xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">Privacy Policy</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            Kebijakan Privasi Aplikasi Rembugan
          </p>
        </div>

        {content ? (
          <div className="prose prose-sm dark:prose-invert max-w-none whitespace-pre-wrap font-sans leading-relaxed">
            {content}
          </div>
        ) : (
          <div className="rounded-lg border border-dashed p-8 text-center text-muted-foreground">
            <p>Kebijakan privasi belum tersedia.</p>
          </div>
        )}

        <div className="mt-12 border-t pt-6 text-center text-xs text-muted-foreground">
          &copy; {new Date().getFullYear()} Rembugan. All rights reserved.
        </div>
      </div>
    </div>
  )
}
