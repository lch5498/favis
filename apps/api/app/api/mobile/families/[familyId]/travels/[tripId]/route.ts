import {
  deleteTravelTrip,
  getTravelTripDetail,
  updateTravelTrip,
} from '../../../../../../../src/travels';
import { jsonFromError } from '../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../src/mobile-auth';
import { readJsonObject, requiredString } from '../../../../../../../src/validation';

export const runtime = 'nodejs';

type RouteContext = {
  params: Promise<{
    familyId: string;
    tripId: string;
  }>;
};

export async function GET(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId, tripId } = await context.params;
    const detail = await getTravelTripDetail(userId, familyId, tripId);

    return Response.json(detail);
  } catch (error) {
    return jsonFromError(error, 'travel_trip_fetch_failed');
  }
}

export async function PATCH(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId, tripId } = await context.params;
    const payload = await readJsonObject(request);
    const trip = await updateTravelTrip(userId, familyId, tripId, {
      title: requiredString(payload, 'title', { maxLength: 80 }),
      startsOn: requiredString(payload, 'startsOn'),
      endsOn: requiredString(payload, 'endsOn'),
    });

    return Response.json(trip);
  } catch (error) {
    return jsonFromError(error, 'travel_trip_update_failed');
  }
}

export async function DELETE(request: Request, context: RouteContext) {
  try {
    const userId = authenticateMobileRequest(request);
    const { familyId, tripId } = await context.params;
    await deleteTravelTrip(userId, familyId, tripId);

    return Response.json({ ok: true });
  } catch (error) {
    return jsonFromError(error, 'travel_trip_delete_failed');
  }
}
