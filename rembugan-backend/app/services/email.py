import os
import random
import hashlib
import resend

resend.api_key = os.getenv("RESEND_API_KEY")
RESEND_FROM = os.getenv("RESEND_FROM", "Rembugan <noreply@ahmadsaif.web.id>")


def generate_otp() -> str:
    return f"{random.randint(100000, 999999)}"


def hash_otp(otp: str) -> str:
    return hashlib.sha256(otp.encode()).hexdigest()


def render_otp_template(otp: str, expiry_minutes: int = 5) -> str:
    return f"""
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:#f5f5f5;">

  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="padding:40px 20px;background:#f5f5f5;">
    <tr>
      <td align="center">

        <table role="presentation" width="520" cellpadding="0" cellspacing="0"
          style="background:#ffffff;border:1px solid #e5e5e5;border-radius:16px;overflow:hidden;">

          <!-- Header -->
          <tr>
            <td style="background:#111111;padding:40px 32px;text-align:center;">
              <h1 style="margin:0;font-size:28px;font-weight:700;color:#ffffff;letter-spacing:2px;">
                REMBUGAN
              </h1>

              <p style="margin:10px 0 0 0;font-size:14px;color:#a3a3a3;">
                Verifikasi Alamat Email
              </p>
            </td>
          </tr>

          <!-- Content -->
          <tr>
            <td style="padding:40px 32px;">

              <h2 style="margin:0 0 16px 0;font-size:22px;color:#111111;font-weight:600;">
                Kode Verifikasi
              </h2>

              <p style="margin:0 0 28px 0;font-size:15px;line-height:1.7;color:#525252;">
                Gunakan kode berikut untuk menyelesaikan proses verifikasi email kamu.
              </p>

              <!-- OTP -->
              <div style="
                background:#fafafa;
                border:2px solid #e5e5e5;
                border-radius:12px;
                padding:28px;
                text-align:center;
                margin-bottom:24px;
              ">
                <span style="
                  font-family:monospace;
                  font-size:40px;
                  font-weight:700;
                  letter-spacing:12px;
                  color:#111111;
                ">
                  {otp}
                </span>
              </div>

              <p style="margin:0 0 16px 0;font-size:14px;line-height:1.7;color:#525252;">
                Kode ini berlaku selama
                <strong style="color:#111111;">{expiry_minutes} menit</strong>.
              </p>

              <div style="
                background:#fafafa;
                border-left:4px solid #111111;
                padding:14px 16px;
                border-radius:6px;
              ">
                <p style="margin:0;font-size:13px;line-height:1.6;color:#525252;">
                  Demi keamanan akun, jangan bagikan kode ini kepada siapa pun.
                </p>
              </div>

            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="
              border-top:1px solid #e5e5e5;
              padding:24px 32px;
              text-align:center;
            ">
              <p style="margin:0;font-size:12px;color:#a3a3a3;">
                Jika kamu tidak melakukan permintaan ini, email ini dapat diabaikan.
              </p>

              <p style="margin:10px 0 0 0;font-size:12px;color:#737373;">
                © Rembugan — Platform Kolaborasi Proyek
              </p>
            </td>
          </tr>

        </table>

      </td>
    </tr>
  </table>

</body>
</html>"""


def send_otp_email(to_email: str, otp: str):
    html = render_otp_template(otp)
    sent = False
    try:
        resend.Emails.send({
            "from": RESEND_FROM,
            "to": [to_email],
            "subject": "Kode OTP Verifikasi Email - Rembugan",
            "html": html,
        })
        sent = True
    except Exception as e:
        print(f"[EMAIL] Resend gagal ke {to_email}: {e}")
    if not sent:
        print(f"\n===== OTP DEV FALLBACK =====")
        print(f"  Email: {to_email}")
        print(f"  OTP:   {otp}")
        print(f"=============================\n")
