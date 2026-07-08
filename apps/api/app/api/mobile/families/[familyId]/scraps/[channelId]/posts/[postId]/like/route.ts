import { toggleScrapPostLike } from '../../../../../../../../../../src/scraps';
import { jsonFromError } from '../../../../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../../../../src/mobile-auth';

export const runtime = 'nodejs';

type RouteContext = {
  params: Promise<{
    familyId: string;
    channelId: string;
    postId: string;
  }>;
};

export async function POST(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId, channelId, postId } = await context.params;
    const result = await toggleScrapPostLike(userId, familyId, channelId, postId);

    return Response.json(result);
  } catch (error) {
    return jsonFromError(error, 'scrap_post_like_toggle_failed');
  }
}
