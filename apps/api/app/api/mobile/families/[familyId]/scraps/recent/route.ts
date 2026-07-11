import { getRecentScrapActivities } from '../../../../../../../src/scraps';
import { jsonFromError } from '../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../src/mobile-auth';

export const runtime = 'nodejs';

type RouteContext = {
  params: Promise<{
    familyId: string;
  }>;
};

export async function GET(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId } = await context.params;
    const recentActivities = await getRecentScrapActivities(userId, familyId);

    return Response.json(recentActivities);
  } catch (error) {
    return jsonFromError(error, 'scrap_recent_activities_fetch_failed');
  }
}
