import { forwardToCommandCenter } from '@/lib/alma'

export const dynamic = 'force-dynamic'

/** Regenerar dossier: botón que Alma propone y la persona pulsa; reenvía al Command Center. */
export async function POST(req: Request) {
  return forwardToCommandCenter('dossier', req)
}
