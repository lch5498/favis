import { createParkingRecord } from '../../../../../../../src/parking';
import { jsonFromError } from '../../../../../../../src/http';
import { authenticateMobileRequest } from '../../../../../../../src/mobile-auth';
import {
  optionalString,
  readJsonObject,
  requiredString,
} from '../../../../../../../src/validation';

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
    const vehicleId = requiredString(payload, 'vehicleId');
    const floorPresetId = optionalString(payload, 'floorPresetId');
    const spotPresetId = optionalString(payload, 'spotPresetId');
    const floorText = requiredString(payload, 'floorText', { maxLength: 40 });
    const spotText = requiredString(payload, 'spotText', { maxLength: 40 });
    const record = await createParkingRecord(userId, familyId, {
      vehicleId,
      floorPresetId,
      spotPresetId,
      floorText,
      spotText,
    });

    return Response.json({ record }, { status: 201 });
  } catch (error) {
    return jsonFromError(error, 'parking_record_create_failed');
  }
}
