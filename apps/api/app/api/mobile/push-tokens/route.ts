import { jsonFromError } from '../../../../src/http';
import { authenticateMobileRequest } from '../../../../src/mobile-auth';
import {
  deletePushToken,
  normalizePushPlatform,
  upsertPushToken,
} from '../../../../src/push-tokens';
import { readJsonObject, requiredString } from '../../../../src/validation';

export const runtime = 'nodejs';

export async function POST(request: Request) {
  try {
    const userId = authenticateMobileRequest(request);
    const payload = await readJsonObject(request);
    const token = requiredString(payload, 'token', { maxLength: 4096 });
    const platform = normalizePushPlatform(
      requiredString(payload, 'platform', { maxLength: 20 }),
    );

    await upsertPushToken(userId, { token, platform });
    return Response.json({ ok: true });
  } catch (error) {
    return jsonFromError(error, 'push_token_save_failed');
  }
}

export async function DELETE(request: Request) {
  try {
    const userId = authenticateMobileRequest(request);
    const payload = await readJsonObject(request);
    const token = requiredString(payload, 'token', { maxLength: 4096 });

    await deletePushToken(userId, token);
    return new Response(null, { status: 204 });
  } catch (error) {
    return jsonFromError(error, 'push_token_delete_failed');
  }
}
