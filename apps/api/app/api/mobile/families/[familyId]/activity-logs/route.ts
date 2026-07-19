import {
  listGroupActivities,
  type GroupActivityType,
} from '../../../../../../src/group-activity-logs';
import { HttpError, jsonFromError } from '../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../src/mobile-auth';

export const runtime = 'nodejs';

type RouteContext = {
  params: Promise<{ familyId: string }>;
};

export async function GET(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId } = await context.params;
    const type = activityTypeFromRequest(new URL(request.url).searchParams.get('type'));
    const activities = await listGroupActivities(userId, familyId, type);

    return Response.json({ activities });
  } catch (error) {
    return jsonFromError(error, 'group_activity_logs_fetch_failed');
  }
}

function activityTypeFromRequest(value: string | null) {
  if (value === null || value === 'all') {
    return undefined;
  }

  if (value === 'schedule' || value === 'parking' || value === 'scrap' || value === 'travel') {
    return value satisfies GroupActivityType;
  }

  throw new HttpError(400, { error: 'invalid_payload', field: 'type' });
}
