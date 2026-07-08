import { toggleScrapCommentLike } from '../../../../../../../../../../../../src/scraps';
import { jsonFromError } from '../../../../../../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../../../../../../src/mobile-auth';

export const runtime = 'nodejs';

type RouteContext = {
  params: Promise<{
    familyId: string;
    channelId: string;
    postId: string;
    commentId: string;
  }>;
};

export async function POST(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId, channelId, postId, commentId } = await context.params;
    const result = await toggleScrapCommentLike(
      userId,
      familyId,
      channelId,
      postId,
      commentId,
    );

    return Response.json(result);
  } catch (error) {
    return jsonFromError(error, 'scrap_comment_like_toggle_failed');
  }
}
