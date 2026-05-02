import Link from "next/link"
import { AuthShell } from "@/components/auth/auth-shell"
import { LoginForm } from "@/components/auth/login-form"

export default function LoginPage() {
  return (
    <AuthShell
      title="Welcome back"
      subtitle="Sign in to keep designing your icon packs."
      footer={
        <>
          New to Facet?{" "}
          <Link href="/signup" className="font-medium text-foreground hover:text-primary">
            Create an account
          </Link>
        </>
      }
    >
      <LoginForm />
    </AuthShell>
  )
}
