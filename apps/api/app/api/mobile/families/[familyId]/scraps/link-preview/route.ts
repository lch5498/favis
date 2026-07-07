import { previewScrapLink } from '../../../../../../../src/scraps';
import { jsonFromError } from '../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../src/mobile-auth';
import { readJsonObject, requiredString } from '../../../../../../../src/validation';

export const runtime = 'nodejs';

type RouteContext = {
  params: Promise<{
    familyId: string;
  }>;
};

export async function POST(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId } = await context.params;
    const payload = await readJsonObject(request);
    const preview = await previewScrapLink(userId, familyId, {
      content: requiredString(payload, 'content', { maxLength: 2000 }),
    });

    return Response.json(preview);
  } catch (error) {
    return jsonFromError(error, 'scrap_link_preview_failed');
  }
}
