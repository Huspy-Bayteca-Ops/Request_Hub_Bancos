import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

// Root page: redirect to /home if logged in, else /login.
export default async function RootPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  redirect(user ? '/home' : '/login')
}
