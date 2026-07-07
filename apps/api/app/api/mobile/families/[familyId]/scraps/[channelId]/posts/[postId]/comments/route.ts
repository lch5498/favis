import { createScrapComment } from '../../../../../../../../../../src/scraps';
import { jsonFromError } from '../../../../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../../../../src/mobile-auth';
import { readJsonObject, requiredString } from '../../../../../../../../../../src/validation';

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
    const payload = await readJsonObject(request);
    const comment = await createScrapComment(
      userId,
      familyId,
      channelId,
      postId,
      {
        content: requiredString(payload, 'content', { maxLength: 1000 }),
      },
    );

    return Response.json(comment, { status: 201 });
  } catch (error) {
    return jsonFromError(error, 'scrap_comment_create_failed');
  }
}
