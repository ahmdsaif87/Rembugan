import subprocess
result = subprocess.run(["npx", "prisma", "--version"], capture_output=True, text=True)
print(result.stdout)
print(result.stderr)
