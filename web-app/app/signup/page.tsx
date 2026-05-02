import Link from "next/link"
import { AuthShell } from "@/components/auth/auth-shell"
import { SignupForm } from "@/components/auth/signup-form"

export default function SignupPage() {
  return (
    <AuthShell
      title="Create your studio"
      subtitle={"Start with the free tier — upgrade whenever you're ready to ship."}
      footer={
        <>
          Already have an account?{" "}
          <Link href="/login" className="font-medium text-foreground hover:text-primary">
            Sign in
          </Link>
        </>
      }
    >
      <SignupForm />
    </AuthShell>
  )
}
