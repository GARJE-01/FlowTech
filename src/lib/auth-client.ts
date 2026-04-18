import { createAuthClient } from "better-auth/react"

// baseURL is intentionally omitted — better-auth/react auto-detects the current origin.
// This works correctly on both localhost and the Vercel production domain.
export const authClient = createAuthClient({})

